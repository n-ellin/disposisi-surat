import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';

import 'package:ta_mobile_disposisi_surat/shared/widgets/process_dialog.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_keluar_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/notification_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/dashboard_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/user_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_masuk.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_keluar.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';

import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/features/notifications/notification_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';

import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/disposisi_suratmasuk.dart';
import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/menu_kepsek_page.dart';
import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/pengajuan_suratkeluar.dart'
    show InputSuratKeluarKepsek;

import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/menu_tu.dart';

class Home extends StatefulWidget {
  final Role role;
  final String nama;
  final String email;
  final String jabatan;
  final String? namaWaka;

  const Home({
    super.key,
    required this.role,
    required this.nama,
    required this.email,
    required this.jabatan,
    this.namaWaka,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // =========================
  // REPOSITORIES
  // =========================
  final _suratMasukRepo = SuratMasukRepository();
  final _suratKeluarRepo = SuratKeluarRepository();
  final _notifRepo = NotificationRepository();
  final _dashboardRepo = DashboardRepository();
  final _userRepo = UserRepository();

  // =========================
  // STATE
  // =========================
  List<SuratMasuk> _suratMasukList = [];
  List<SuratKeluar> _suratKeluarList = [];
  List<Map<String, dynamic>> notifications = [];
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = true;
  String? _error;

  Timer? _refreshTimer;
  Timer? _notifTimer;

  // =========================
  // LIFECYCLE
  // =========================
  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchNotifications();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchData(),
    );
    _notifTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchNotifications(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _notifTimer?.cancel();
    super.dispose();
  }

  // =========================
  // DIALOG
  // =========================
  void _showProcessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Surat Dalam Proses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Surat masih dalam proses pengajuan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // NOTIFICATION
  // =========================

  // FIX #1: catch tidak lagi menelan error diam-diam.
  // Sebelumnya: catch (_) {} — error dibuang tanpa jejak,
  // sehingga jika request gagal (token, jaringan, dll) tidak ada indikasi apapun.
  Future<void> _fetchNotifications() async {
    try {
      final result = await _notifRepo.getList();
      if (!mounted) return;
      setState(() => notifications = result);
    } catch (e) {
      // Error dicatat di log agar mudah di-debug, tapi tidak mengganggu UI.
      // Badge notif tetap menampilkan data terakhir yang berhasil dimuat.
      debugPrint('[Notif] Gagal fetch notifikasi: $e');
    }
  }

  int get notifCount => notifications.where((e) => e['isRead'] == false).length;

  // FIX #2: markAllRead dihapus dari sini.
  // Sebelumnya markAllRead() dipanggil otomatis setelah keluar dari halaman notif,
  // sehingga semua notif langsung berubah jadi sudah-dibaca meski user belum membacanya.
  // Sekarang markAsRead hanya dipanggil per-item di NotificationPage saat user tap notif.
  Future<void> openNotification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationPage(role: widget.role)),
    );
    // Refresh badge setelah kembali dari halaman notif
    // agar count di icon bell terupdate sesuai yang sudah ditap user.
    await _fetchNotifications();
  }

  // =========================
  // FETCH DATA
  // =========================
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _suratMasukRepo.getList(),
        _suratKeluarRepo.getList(),
        _dashboardRepo.getStats(),
      ]);

      if (!mounted) return;
      setState(() {
        _suratMasukList = List<SuratMasuk>.from(results[0] as List);
        _suratKeluarList = List<SuratKeluar>.from(results[1] as List);
        _dashboardStats = results[2] as Map<String, dynamic>;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _error = parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =========================
  // FORMAT TANGGAL
  // =========================
  String _formatTanggal(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return rawDate;
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
        bulan[parts[1]] ?? 1,
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(2000);
    }
  }

  // =========================
  // HELPER STATUS
  // =========================
  bool _isDisposisiDone(String? status) {
    if (status == null) return false;
    final s = status.toLowerCase();
    return s == 'disetujui' ||
        s == 'ditolak' ||
        s == 'selesai' ||
        s == 'diteruskan' ||
        s == 'dikonfirmasi';
  }

  // =========================
  // DATA GETTERS
  // =========================
  List<Map<String, dynamic>> get allSurat {
    final masuk = _suratMasukList
        .map(
          (s) => {
            'jenisSurat': 'Surat Masuk',
            'tanggal': _formatTanggal(s.createdAt.toIso8601String()),
            'status': s.status,
            'lampiran': s.lampiranUrls,
            'data': {
              'No Surat': s.noSurat,
              'Perihal': s.perihal,
              'Dari': s.asalSurat,
            },
            '_raw': s,
          },
        )
        .toList();

    final keluar = _suratKeluarList
        .map(
          (s) => {
            'jenisSurat': 'Surat Keluar',
            'tanggal': _formatTanggal(s.createdAt.toIso8601String()),
            'status': s.status,
            'kode_surat': s.kodeSurat.toString(),
            'lampiran': s.lampiranUrls,
            'data': {
              'No Surat': s.noSurat,
              'Perihal': s.perihal,
              'Dari': s.tujuan,
            },
            '_raw': s,
          },
        )
        .toList();

    return [...masuk, ...keluar];
  }

  List<Map<String, dynamic>> get suratTerbaru {
    final sorted = [...allSurat];
    sorted.sort((a, b) {
      final dateA = _parseDate(a['tanggal'] ?? '');
      final dateB = _parseDate(b['tanggal'] ?? '');
      return dateB.compareTo(dateA);
    });
    return sorted.take(5).toList();
  }

  int get jumlahSuratMasuk {
    final fromApi = _dashboardStats['total_surat_masuk'];
    if (fromApi != null) return (fromApi as num).toInt();
    return _suratMasukList.length;
  }

  int get jumlahSuratKeluar {
    final fromApi = _dashboardStats['total_surat_keluar'];
    if (fromApi != null) return (fromApi as num).toInt();
    return _suratKeluarList.length;
  }

  // =========================
  // OPEN DETAIL PEGAWAI/TU
  // =========================
  Future<void> _openDetailPegawai(Map<String, dynamic> surat) async {
    final isMasuk = surat['jenisSurat'] == 'Surat Masuk';
    final raw = surat['_raw'];

    try {
      if (isMasuk) {
        final detail = await _suratMasukRepo.getDetail((raw as SuratMasuk).id);

        List<Map<String, dynamic>> wakaListData = [];
        try {
          wakaListData = await _suratMasukRepo.getWakaList();
          debugPrint('WAKA LIST: $wakaListData');
        } catch (e) {
          debugPrint('Error fetch waka: $e');
        }

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OutputSuratmasuk(
              isApproved: detail.status?.toLowerCase() == 'disetujui',
              catatan: detail.catatanVerifikasi ?? detail.catatan ?? '',
              wakaList: wakaListData,
              isReadOnly: false,
              showWaka: true,
              lampiranUrls: detail.lampiranUrls,
              suratId: detail.id,
              namaWaka: detail.namaWaka,
              jabatanWaka: detail.jabatanWaka,
            ),
          ),
        );
      } else {
        final detail = await _suratKeluarRepo.getDetail(
          (raw as SuratKeluar).id,
        );
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OutputSuratkeluar(
              catatan: detail.catatanVerifikasi ?? detail.catatan ?? '',
              isReadOnly: false,
              lampiranUrls: detail.lampiranUrls ?? [],
            ),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(parseError(e))));
    }
  }

  // =========================
  // RESPONSIVE
  // =========================
  double rf(
    BuildContext context,
    double size, {
    double min = 0.85,
    double max = 1.10,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 375).clamp(min, max);
    return size * scale;
  }

  // =========================
  // NAVIGATION
  // =========================
  void openDashboard(String jenisSurat) {
    if (widget.role == Role.pegawai) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TuDashboardPage(jenisSurat: jenisSurat),
        ),
      );
    } else if (widget.role == Role.kepsek) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KepsekDashboardPage(jenisSurat: jenisSurat),
        ),
      );
    }
  }

  void openDetail(Map<String, dynamic> surat) async {
    final statusCheck = (surat['status'] ?? '').toString().toLowerCase();
    if ((statusCheck == 'diproses' || statusCheck == 'menunggu') &&
        widget.role != Role.kepsek) {
      showProcessDialog(context);
      return;
    }

    if (widget.role == Role.kepsek) {
      final isMasuk = surat['jenisSurat'] == 'Surat Masuk';
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => isMasuk
              ? InputSuratMasuk(surat: surat)
              : InputSuratKeluarKepsek(surat: surat),
        ),
      );
      if (result != null && mounted) _fetchData();
      return;
    }
    await _openDetailPegawai(surat);
  }

  // =========================
  // BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomNavbar(
            role: widget.role,
            currentIndex: 0,
            onTap: (index) => handleNavbarTap(
              context,
              index,
              widget.role,
              widget.nama,
              widget.email,
              widget.jabatan,
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: rf(context, 20)),

                  // Logo + Notifikasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/logosmk.jpg",
                        width: rf(context, 42),
                        height: rf(context, 42),
                      ),
                      GestureDetector(
                        onTap: openNotification,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, right: 4),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: rf(context, 28),
                                color: AppColors.bluePrimary,
                              ),
                              if (notifCount > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE53935),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        notifCount > 9
                                            ? '9+'
                                            : notifCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
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
                      ),
                    ],
                  ),

                  SizedBox(height: rf(context, 18)),

                  Text(
                    "Disposisi Surat",
                    style: TextStyle(
                      fontSize: rf(context, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: rf(context, 22)),

                  // Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          onTap: () => openDashboard('Surat Masuk'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6DA8B4), Color(0xFF0F6E7A)],
                          ),
                          iconPath: "assets/icons/ic_inmail.svg",
                          jumlah: jumlahSuratMasuk.toString(),
                          label: "Masuk",
                        ),
                      ),
                      SizedBox(width: rf(context, 14)),
                      Expanded(
                        child: _StatCard(
                          onTap: () => openDashboard('Surat Keluar'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD6A66B), Color(0xFFDA7B17)],
                          ),
                          iconPath: "assets/icons/ic_outmail.svg",
                          jumlah: jumlahSuratKeluar.toString(),
                          label: "Keluar",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: rf(context, 26)),

                  Text(
                    "Surat Terbaru",
                    style: TextStyle(
                      fontSize: rf(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: rf(context, 14)),
                ],
              ),
            ),

            Expanded(child: _buildBody()),

            SizedBox(height: rf(context, 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (allSurat.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Belum ada surat',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: suratTerbaru.length,
          itemBuilder: (context, index) {
            final surat = suratTerbaru[index];
            return SuratCard(
              jenisSurat: surat['jenisSurat'] ?? '',
              tanggal: surat['tanggal'] ?? '-',
              data: Map<String, String>.from(surat['data'] ?? {}),
              role: widget.role == Role.kepsek
                  ? CardRole.kepsek
                  : CardRole.pegawai,
              type: CardType.home,
              status: widget.role == Role.kepsek ? null : surat['status'],
              onDetail: () => openDetail(surat),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================
class _StatCard extends StatelessWidget {
  final VoidCallback onTap;
  final LinearGradient gradient;
  final String iconPath;
  final String jumlah;
  final String label;

  const _StatCard({
    required this.onTap,
    required this.gradient,
    required this.iconPath,
    required this.jumlah,
    required this.label,
  });

  double rf(
    BuildContext context,
    double size, {
    double min = 0.85,
    double max = 1.10,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 375).clamp(min, max);
    return size * scale;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: rf(context, 72)),
        padding: EdgeInsets.symmetric(
          horizontal: rf(context, 12),
          vertical: rf(context, 10),
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(rf(context, 16)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: rf(context, 17),
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              child: SvgPicture.asset(
                iconPath,
                width: rf(context, 18),
                height: rf(context, 18),
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: rf(context, 9)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      jumlah,
                      style: TextStyle(
                        fontSize: rf(context, 17),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: rf(context, 2)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: rf(context, 12),
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
