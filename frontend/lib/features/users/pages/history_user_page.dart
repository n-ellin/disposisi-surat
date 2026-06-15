import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filterdatebar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filter_date.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/user/detail_surat_user.dart';
import 'package:ta_mobile_disposisi_surat/features/users/pages/waka/detail_surat_waka.dart';

class HistoryUsersPage extends StatefulWidget {
  final Role role;
  final String nama;
  final String email;
  final String jabatan;

  const HistoryUsersPage({
    super.key,
    required this.role,
    required this.nama,
    required this.email,
    required this.jabatan,
  });

  @override
  State<HistoryUsersPage> createState() => _HistoryUsersPageState();
}

class _HistoryUsersPageState extends State<HistoryUsersPage> {
  final _suratMasukRepo = SuratMasukRepository();

  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (Session.userHistoryStartDate == null) {
      final now = DateTime.now();
      Session.userHistoryStartDate = DateTime(now.year, now.month, now.day);
      Session.userHistoryEndDate = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      );
      Session.userHistoryActiveChip = 'Hari ini';
      Session.userHistoryDateFilter = 'Hari ini';
    }
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dateFrom = Session.userHistoryStartDate
          ?.toIso8601String()
          .substring(0, 10);
      final dateTo = Session.userHistoryEndDate?.toIso8601String().substring(
        0,
        10,
      );

      final result = await _suratMasukRepo.getHistory(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      if (!mounted) return;
      setState(() {
        _historyList = result.map((s) => s.toMenuMap()).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat riwayat. Coba lagi.';
        _historyList = [];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _historyList.where((s) {
      final data = s['data'] as Map<String, dynamic>? ?? {};
      final q = Session.userHistorySearchQuery.toLowerCase();

      final matchSearch =
          Session.userHistorySearchQuery.isEmpty ||
          (data['Perihal'] ?? '').toString().toLowerCase().contains(q) ||
          (data['Dari'] ?? '').toString().toLowerCase().contains(q) ||
          (data['Nomor Surat'] ?? '').toString().toLowerCase().contains(q);

      bool matchDate = true;
      if (Session.userHistoryStartDate != null &&
          Session.userHistoryEndDate != null) {
        final suratDate = _parseTanggal(s['tanggal']?.toString() ?? '');
        if (suratDate.year > 1970) {
          final start = DateTime(
            Session.userHistoryStartDate!.year,
            Session.userHistoryStartDate!.month,
            Session.userHistoryStartDate!.day,
          );
          final end = DateTime(
            Session.userHistoryEndDate!.year,
            Session.userHistoryEndDate!.month,
            Session.userHistoryEndDate!.day,
            23,
            59,
            59,
          );
          matchDate = !suratDate.isBefore(start) && !suratDate.isAfter(end);
        }
      }

      return matchSearch && matchDate;
    }).toList();
  }

  DateTime _parseTanggal(String tanggal) {
    const bulan = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'mei': 5,
      'jun': 6,
      'jul': 7,
      'agu': 8,
      'sep': 9,
      'okt': 10,
      'nov': 11,
      'des': 12,
    };
    try {
      final parts = tanggal.toLowerCase().trim().split(' ');
      return DateTime(
        int.parse(parts[2]),
        bulan[parts[1]] ?? 1,
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(1970);
    }
  }

  void _showDateFilter() async {
    final result = await DateRangeFilterBottomSheet.show(
      context: context,
      initialStartDate: Session.userHistoryStartDate,
      initialEndDate: Session.userHistoryEndDate,
      initialChip: Session.userHistoryActiveChip,
    );
    if (result == null) return;
    setState(() {
      Session.userHistoryStartDate = result.startDate;
      Session.userHistoryEndDate = result.endDate;
      Session.userHistoryActiveChip = result.activeChip;
      Session.userHistoryDateFilter = result.dateFilterLabel;
    });
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    double rf(double size) => (w * (size / 375)).clamp(size * 0.9, size * 1.15);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: h * 0.025,
                left: w * 0.05,
                right: w * 0.05,
                bottom: h * 0.015,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Riwayat',
                    style: TextStyle(
                      fontSize: w * 0.048,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bluePrimary,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.bluePrimary,
                        size: w * 0.055,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(w * 0.05, 0, w * 0.05, 0),
              child: Column(
                children: [
                  SearchBarInput(
                    onChanged: (val) =>
                        setState(() => Session.userHistorySearchQuery = val),
                  ),
                  SizedBox(height: h * 0.012),
                  DateFilterBar(
                    label: Session.userHistoryDateFilter,
                    onTap: _showDateFilter,
                  ),
                  SizedBox(height: h * 0.016),
                ],
              ),
            ),
            Expanded(child: _buildBody(w, h, rf)),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: w * 0.03,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: CustomNavbar(
              role: widget.role,
              currentIndex: 1,
              onTap: (index) => handleNavbarTap(
                context,
                index,
                widget.role,
                widget.nama,
                widget.email,
                widget.jabatan,
              ),
            ),
          ),
          ColoredBox(
            color: AppColors.bg,
            child: SizedBox(height: bottomPadding, width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(double w, double h, double Function(double) rf) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.bluePrimary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
            SizedBox(height: h * 0.01),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: h * 0.01),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
            SizedBox(height: h * 0.015),
            Text(
              'Belum ada riwayat surat',
              style: TextStyle(color: Colors.grey.shade500, fontSize: w * 0.04),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.bluePrimary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.01),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final surat = _filtered[index];
          return Padding(
            padding: EdgeInsets.only(bottom: h * 0.012),
            child: SuratCard(
              jenisSurat: surat['jenisSurat']?.toString() ?? 'Surat Masuk',
              tanggal: surat['tanggal']?.toString() ?? '-',
              data: Map<String, String>.from(surat['data'] ?? {}),
              role: widget.role == Role.waka ? CardRole.waka : CardRole.Users,
              type: CardType.history,
              status: surat['status']?.toString() ?? '-',
              onDetail: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => widget.role == Role.waka
                        ? DetailSuratWaka(
                            surat: surat,
                            isReadOnly: true, // ← READ-ONLY dari history
                          )
                        : DetailSuratUsers(surat: surat),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
