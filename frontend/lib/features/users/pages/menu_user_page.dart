import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/notification_template.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
// import removed: dummy data no longer used
import 'package:ta_mobile_disposisi_surat/core/repositories/notification_repository.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/features/notifications/notification_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/user/detail_surat_user.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/waka/detail_surat_waka.dart';

class MenuUser extends StatefulWidget {
  final String nama;
  final String email;
  final Role role;

  const MenuUser({
    super.key,
    required this.nama,
    required this.email,
    required this.role,
    required String jabatan,
  });

  @override
  State<MenuUser> createState() => _MenuUserState();
}

class _MenuUserState extends State<MenuUser> {
  final _suratMasukRepo = SuratMasukRepository();
  String searchQuery = '';

  final _notifRepo = NotificationRepository();
  List<Map<String, dynamic>> notifications = [];
  bool _isLoadingNotif = true;

  List<Map<String, dynamic>> _suratList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final result = await _notifRepo.getList();
      if (!mounted) return;
      setState(() {
        notifications = result;
        _isLoadingNotif = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingNotif = false;
        notifications = [];
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
    final result = await _suratMasukRepo.getList();
      if (!mounted) return;
      setState(() {
        _suratList = result.map((s) => s.toMenuMap()).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _suratList = [];
        _isLoading = false;
      });
    }
  }

  DateTime _parseDate(String tanggal) {
    const bulan = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'Mei': 5,
      'Jun': 6,
      'Jul': 7,
      'Agu': 8,
      'Sep': 9,
      'Okt': 10,
      'Nov': 11,
      'Des': 12,
    };

    try {
      final parts = tanggal.trim().split(' ');
      return DateTime(
        int.parse(parts[2]),
        bulan[parts[1]]!,
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(2000);
    }
  }

  List<Map<String, dynamic>> get filteredSurat {
    List<Map<String, dynamic>> result = [..._suratList];

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((surat) {
        final jenis = surat['jenisSurat'].toString().toLowerCase();
        final tanggal = surat['tanggal'].toString().toLowerCase();
        final status = surat['status'].toString().toLowerCase();
        final dari = (surat['data']?['Dari'] ?? '').toString().toLowerCase();
        final perihal = (surat['data']?['Perihal'] ?? '')
            .toString()
            .toLowerCase();

        return jenis.contains(query) ||
            tanggal.contains(query) ||
            status.contains(query) ||
            dari.contains(query) ||
            perihal.contains(query);
      }).toList();
    }

    result.sort((a, b) {
      final dateA = _parseDate(a['tanggal']?.toString() ?? '');
      final dateB = _parseDate(b['tanggal']?.toString() ?? '');
      return dateB.compareTo(dateA);
    });

    return result;
  }

  int get notifCount => notifications.where((n) => n['isRead'] == false).length;

  Future<void> _openNotification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationPage(
          role: widget.role, // ✅ hapus notifications:
        ),
      ),
    );

    try {
      await _notifRepo.markAllRead();
      await _loadNotifications();
    } catch (e) {
      setState(() {
        for (var notif in notifications) {
          notif['isRead'] = true;
        }
      });
    }
  }

  String get _pageTitle {
    return widget.role == Role.waka ? 'Disposisi Masuk' : 'Disposisi Surat';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final h = screenSize.height;
    final w = screenSize.width > 500 ? 500.0 : screenSize.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    double rf(double size) {
      return (w * (size / 375)).clamp(size * 0.85, size * 1.2);
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomNavbar(
              role: widget.role,
              currentIndex: 0,
              onTap: (index) {
                handleNavbarTap(
                  context,
                  index,
                  widget.role,
                  widget.nama,
                  widget.email,
                  Session.jabatan,
                );
              },
            ),
          ),
          ColoredBox(
            color: AppColors.bg,
            child: SizedBox(height: bottomPadding, width: double.infinity),
          ),
        ],
      ),

      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: (h * 0.03).clamp(16.0, 32.0)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/logosmk.jpg',
                        width: (w * 0.12).clamp(40.0, 60.0),
                        height: (w * 0.12).clamp(40.0, 60.0),
                        fit: BoxFit.cover,
                      ),
                      GestureDetector(
                        onTap: _openNotification,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: (w * 0.075).clamp(28.0, 40.0),
                              color: AppColors.bluePrimary,
                            ),
                            if (notifCount > 0)
                              Positioned(
                                right: -(w * 0.008),
                                top: -(w * 0.008),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE53935),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      notifCount > 9
                                          ? '9+'
                                          : notifCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: rf(9),
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: (h * 0.02).clamp(12.0, 24.0)),

                  Text(
                    _pageTitle,
                    style: TextStyle(
                      fontSize: rf(22),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: (h * 0.025).clamp(16.0, 28.0)),

                  SearchBarInput(
                    hintText: 'Cari surat...',
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),

                  SizedBox(height: (h * 0.012).clamp(8.0, 16.0)),

                  Expanded(
                    child: filteredSurat.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: (w * 0.2).clamp(70.0, 100.0),
                                  height: (w * 0.2).clamp(70.0, 100.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.inbox_outlined,
                                    size: (w * 0.1).clamp(36, 60),
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                SizedBox(height: h * 0.016),
                                Text(
                                  'Belum ada surat',
                                  style: TextStyle(
                                    fontSize: rf(15),
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: h * 0.015),
                            itemCount: filteredSurat.length,
                            itemBuilder: (context, index) {
                              final surat = filteredSurat[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: h * 0.002),
                                child: SuratCard(
                                  jenisSurat: surat['jenisSurat'].toString(),
                                  tanggal: surat['tanggal'].toString(),
                                  status: surat['status']?.toString(),
                                  role: widget.role == Role.waka
                                      ? CardRole.waka
                                      : CardRole.Users,
                                  type: CardType.menu,
                                  data: Map<String, String>.from(surat['data']),
                                  diteruskanKe: surat['diteruskanKe']
                                      ?.toString(),
                                  onDetail: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => widget.role == Role.waka
                                            ? DetailSuratWaka(surat: surat)
                                            : DetailSuratUsers(surat: surat),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
