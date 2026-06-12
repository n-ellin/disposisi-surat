import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_masuk.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_keluar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filterdatebar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filter_date.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_keluar_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';

class HistoryTUPage extends StatefulWidget {
  const HistoryTUPage({super.key});

  @override
  State<HistoryTUPage> createState() => _HistoryTUPageState();
}

class _HistoryTUPageState extends State<HistoryTUPage> {
  final _repoMasuk = SuratMasukRepository();
  final _repoKeluar = SuratKeluarRepository();

  List<Map<String, dynamic>> _historySurat = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  String? get _dateFrom => Session.historyStartDate?.toIso8601String().substring(0, 10);

  String? get _dateTo => Session.historyEndDate?.toIso8601String().substring(0, 10);

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Pegawai (TU) fetch kedua endpoint — sama seperti admin/kepsek di web
      final results = await Future.wait([
        _repoMasuk.getHistory(dateFrom: _dateFrom, dateTo: _dateTo),
        _repoKeluar.getHistory(tanggalAwal: _dateFrom, tanggalAkhir: _dateTo),
      ]);

      final masukList = results[0] as List<SuratMasuk>;
      final keluarList = results[1] as List<SuratKeluar>;

      final masuk = masukList
          .map(
            (s) => {
              'id': s.id,
              'jenisSurat': 'Surat Masuk',
              'tanggal': s.createdAt.toIso8601String().substring(0, 10),
              'status': s.status,
              'catatan': s.catatanVerifikasi ?? s.catatan ?? '',
              'lampiran': s.lampiranUrls.isNotEmpty
                  ? s.lampiranUrls
                  : (s.previewUrl.isNotEmpty ? [s.previewUrl] : <String>[]),
              'data': {
                'Dari': s.asalSurat,
                'Perihal': s.perihal,
                'No. Surat': s.noSurat,
              },
              '_raw': s,
            },
          )
          .toList();

      final keluar = keluarList
          .map(
            (s) => {
              'id': s.id,
              'jenisSurat': 'Surat Keluar',
              'tanggal': s.createdAt.toIso8601String().substring(0, 10),
              'status': s.status,
              'catatan': s.catatanVerifikasi ?? s.catatan ?? '',
              'lampiran': s.lampiranUrls.isNotEmpty
                  ? s.lampiranUrls
                  : (s.previewUrl.isNotEmpty ? [s.previewUrl] : <String>[]),
              'data': {
                'Dari': s.tujuan,
                'Perihal': s.perihal,
                'No. Surat': s.noSurat,
              },
              '_raw': s,
            },
          )
          .toList();

      final result = [...masuk, ...keluar];
      // Sort terbaru dulu berdasarkan tanggal ISO string
      result.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['tanggal'] as String) ?? DateTime(1970);
        final dateB =
            DateTime.tryParse(b['tanggal'] as String) ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;
      setState(() {
        _historySurat = result;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = parseError(e);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        
        _error = 'Terjadi kesalahan. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  // ── Filter client-side (search + status + tanggal) ──────────────────────
  List<Map<String, dynamic>> get _filteredSurat {
    return _historySurat.where((s) {
      // Search
      final query = Session.historySearchQuery.toLowerCase();
      final matchSearch =
          query.isEmpty ||
          s['data']['No. Surat'].toString().toLowerCase().contains(query) ||
          s['data']['Perihal'].toString().toLowerCase().contains(query) ||
          s['data']['Dari'].toString().toLowerCase().contains(query) ||
          s['jenisSurat'].toString().toLowerCase().contains(query) ||
          s['tanggal'].toString().contains(query);

      // Status filter
      final matchStatus =
          Session.historyStatusFilter == 'semua' ||
          s['status'].toString().toLowerCase() == Session.historyStatusFilter;

      // Tanggal filter — sudah dikirim ke backend, ini hanya fallback UI
      bool matchDate = true;
      if (Session.historyStartDate != null && Session.historyEndDate != null) {
        final suratDate = DateTime.tryParse(s['tanggal'] as String);
        if (suratDate != null) {
          final start = DateTime(
            Session.historyStartDate!.year,
            Session.historyStartDate!.month,
            Session.historyStartDate!.day,
          );
          final end = DateTime(
            Session.historyEndDate!.year,
            Session.historyEndDate!.month,
            Session.historyEndDate!.day,
            23,
            59,
            59,
          );
          matchDate = !suratDate.isBefore(start) && !suratDate.isAfter(end);
        }
      }

      return matchSearch && matchStatus && matchDate;
    }).toList();
  }

  void _showDateFilter() async {
    final result = await DateRangeFilterBottomSheet.show(
      context: context,
      initialStartDate: Session.historyStartDate,
      initialEndDate: Session.historyEndDate,
      initialChip: Session.historyActiveChip,
    );
    if (result == null) return;
    setState(() {
      Session.historyStartDate = result.startDate;
      Session.historyEndDate = result.endDate;
      Session.historyActiveChip = result.activeChip;
      Session.historyDateFilter = result.dateFilterLabel;
    });
    // Re-fetch dengan tanggal baru
    _fetchHistory();
  }

  void _openDetail(Map<String, dynamic> surat) {
    final isMasuk = surat['jenisSurat'] == 'Surat Masuk';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isMasuk
            ? OutputSuratmasuk(
                isApproved: surat['status'] == 'disetujui',
                catatan: surat['catatan'] ?? '-',
                wakaList: const [],
                isReadOnly: true,
                showWaka: false,
                lampiranUrls: List<String>.from(surat['lampiran'] ?? []),
                suratId: surat['id'] as int,
              )
            : OutputSuratkeluar(
                catatan: surat['catatan'] ?? '-',
                isReadOnly: true,
                lampiranUrls: List<String>.from(surat['lampiran'] ?? []),
              ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
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
              padding: EdgeInsets.fromLTRB(w * 0.04, h * 0.018, w * 0.04, 0),
              child: Column(
                children: [
                  Text(
                    'Riwayat',
                    style: TextStyle(
                      fontSize: rf(24),
                      fontWeight: FontWeight.w800,
                      color: AppColors.bluePrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: h * 0.016),
                  SearchBarInput(
                    onChanged: (value) =>
                        setState(() => Session.historySearchQuery = value),
                  ),
                  SizedBox(height: h * 0.014),
                  // Filter chip: Semua / Disetujui / Ditolak
                  Wrap(
                    spacing: w * 0.02,
                    runSpacing: h * 0.01,
                    children: [
                      SizedBox(
                        width: (w - (w * 0.12)) / 3,
                        child: _filterChip('semua'),
                      ),
                      SizedBox(
                        width: (w - (w * 0.12)) / 3,
                        child: _filterChip('disetujui'),
                      ),
                      SizedBox(
                        width: (w - (w * 0.12)) / 3,
                        child: _filterChip('ditolak'),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.012),
                  DateFilterBar(
                    label: Session.historyDateFilter,
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
              role: Role.pegawai,
              currentIndex: 1,
              onTap: (index) => handleNavbarTap(
                context,
                index,
                Role.pegawai,
                Session.nama,
                Session.email,
                Session.jabatan,
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _fetchHistory,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredSurat.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: w * 0.2,
              height: w * 0.2,
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
              'Belum ada riwayat surat',
              style: TextStyle(
                fontSize: rf(15),
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(w * 0.04, 0, w * 0.04, h * 0.02),
        itemCount: _filteredSurat.length,
        itemBuilder: (context, index) {
          final surat = _filteredSurat[index];
          return SuratCard(
            jenisSurat: surat['jenisSurat'] ?? '',
            tanggal: surat['tanggal'] ?? '-',
            data: Map<String, String>.from(surat['data'] ?? {}),
            role: CardRole.pegawai,
            type: CardType.history,
            status: surat['status'],
            onDetail: () => _openDetail(surat),
          );
        },
      ),
    );
  }

  Widget _filterChip(String label) {
    final w = MediaQuery.of(context).size.width;
    double rf(double size) => (w * (size / 375)).clamp(size * 0.9, size * 1.1);

    final isActive = Session.historyStatusFilter == label;
    final Color activeColor;
    switch (label) {
      case 'disetujui':
        activeColor = const Color(0xFF3F9142);
        break;
      case 'ditolak':
        activeColor = const Color(0xFFB63A3A);
        break;
      default:
        activeColor = AppColors.bluePrimary;
    }
    final displayLabel = label[0].toUpperCase() + label.substring(1);

    return GestureDetector(
      onTap: () => setState(() => Session.historyStatusFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(w * 0.05),
          border: Border.all(
            color: isActive ? activeColor : const Color(0xFFD1D5DB),
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          displayLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rf(13),
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
