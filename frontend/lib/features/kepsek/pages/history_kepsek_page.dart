import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_masuk.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_keluar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filterdatebar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filter_date.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_keluar_repository.dart';

class HistoryKepsekPage extends StatefulWidget {
  const HistoryKepsekPage({super.key});

  @override
  State<HistoryKepsekPage> createState() => _HistoryKepsekPageState();
}

class _HistoryKepsekPageState extends State<HistoryKepsekPage> {
  bool _isLoadingHistory = true;
  String? _error;
  List<Map<String, dynamic>> _historySuratList = [];

  final _suratMasukRepo = SuratMasukRepository();
  final _suratKeluarRepo = SuratKeluarRepository();

  @override
  void initState() {
    super.initState();
    if (Session.kepsekStartDate == null) {
      final now = DateTime.now();
      Session.kepsekStartDate = DateTime(now.year, now.month, now.day);
      Session.kepsekEndDate = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      );
      Session.kepsekActiveChip = 'Hari ini';
      Session.kepsekDateFilter = 'Hari ini';
    }
    _loadHistory();
  }

  // ── Fetch history dari BE (BE filter otomatis berdasarkan role kepsek) ──
  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = true;
      _error = null;
    });

    try {
      // Kirim date filter ke BE supaya tidak fetch semua data
      final dateFrom = Session.kepsekStartDate?.toIso8601String().substring(
        0,
        10,
      );
      final dateTo = Session.kepsekEndDate?.toIso8601String().substring(0, 10);

      // Fetch paralel — lebih cepat daripada sequential
      final results = await Future.wait([
        _suratMasukRepo.getHistory(dateFrom: dateFrom, dateTo: dateTo),
        _suratKeluarRepo.getHistory(
          tanggalAwal: dateFrom,
          tanggalAkhir: dateTo,
        ),
      ]);

      final masukList = results[0] as List<SuratMasuk>;
      final keluarList = results[1] as List<SuratKeluar>;

      // Tidak perlu filter .where(status) di sini — BE /history sudah
      // mengembalikan hanya yang sudah diputuskan (disetujui/ditolak)
      final masuk = masukList
          .map(
            (s) => {
              'id': s.id,
              'jenisSurat': 'Surat Masuk',
              'tanggal': s.createdAt.toIso8601String().substring(0, 10),
              'status': s.status,
              'catatan': s.catatanVerifikasi ?? '',
              'lampiran': s.lampiranUrls.isNotEmpty
                  ? s.lampiranUrls
                  : <String>[s.previewUrl],
              'data': {
                'Dari': s.asalSurat,
                'Perihal': s.perihal,
                'No. Surat': s.noSurat,
              },
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
              'catatan': s.catatanVerifikasi ?? '',
              'lampiran': (s.lampiranUrls != null && s.lampiranUrls!.isNotEmpty)
                  ? s.lampiranUrls!
                  : <String>[s.previewUrl],
              'data': {
                'Dari': s.tujuan,
                'Perihal': s.perihal,
                'No. Surat': s.noSurat,
              },
            },
          )
          .toList();

      final combined = [...masuk, ...keluar]
        ..sort((a, b) {
          final dateA =
              DateTime.tryParse(a['tanggal'] as String) ?? DateTime(1970);
          final dateB =
              DateTime.tryParse(b['tanggal'] as String) ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });

      if (!mounted) return;
      setState(() {
        _historySuratList = combined;
        _isLoadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat riwayat. Coba lagi.';
        _historySuratList = [];
        _isLoadingHistory = false;
      });
    }
  }

  // ── Filter client-side: search + jenis surat + date (fallback UI) ──
  List<Map<String, dynamic>> get _filteredSurat {
    return _historySuratList.where((s) {
      final query = Session.kepsekSearchQuery.toLowerCase();
      final jenis = s['jenisSurat'].toString().toLowerCase();
      final tanggal = s['tanggal'].toString().toLowerCase();
      final dari = (s['data']?['Dari'] ?? '').toString().toLowerCase();
      final perihal = (s['data']?['Perihal'] ?? '').toString().toLowerCase();

      final matchSearch =
          Session.kepsekSearchQuery.isEmpty ||
          jenis.contains(query) ||
          tanggal.contains(query) ||
          dari.contains(query) ||
          perihal.contains(query);

      final matchJenis =
          Session.kepsekJenisFilter == 'semua' ||
          (Session.kepsekJenisFilter == 'masuk' && jenis.contains('masuk')) ||
          (Session.kepsekJenisFilter == 'keluar' && jenis.contains('keluar'));

      // Date fallback — data dari BE sudah difilter, ini hanya pengaman UI
      bool matchDate = true;
      if (Session.kepsekStartDate != null && Session.kepsekEndDate != null) {
        final suratDate = DateTime.tryParse(s['tanggal'] ?? '');
        if (suratDate != null) {
          final start = DateTime(
            Session.kepsekStartDate!.year,
            Session.kepsekStartDate!.month,
            Session.kepsekStartDate!.day,
          );
          final end = DateTime(
            Session.kepsekEndDate!.year,
            Session.kepsekEndDate!.month,
            Session.kepsekEndDate!.day,
            23,
            59,
            59,
          );
          matchDate = !suratDate.isBefore(start) && !suratDate.isAfter(end);
        }
      }

      return matchSearch && matchJenis && matchDate;
    }).toList();
  }

  // ── Date filter bottom sheet — re-fetch setelah pilih ──
  void _showDateFilter() async {
    final result = await DateRangeFilterBottomSheet.show(
      context: context,
      initialStartDate: Session.kepsekStartDate,
      initialEndDate: Session.kepsekEndDate,
      initialChip: Session.kepsekActiveChip,
    );
    if (result == null) return;

    debugPrint('START: ${result.startDate}'); // ← TAMBAH INI
    debugPrint('END: ${result.endDate}'); // ← TAMBAH INI

    setState(() {
      Session.kepsekStartDate = result.startDate;
      Session.kepsekEndDate = result.endDate;
      Session.kepsekActiveChip = result.activeChip;
      Session.kepsekDateFilter = result.dateFilterLabel;
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
                        setState(() => Session.kepsekSearchQuery = value),
                  ),
                  SizedBox(height: h * 0.014),
                  Row(
                    children: [
                      Expanded(child: _filterChip('semua', 'Semua')),
                      SizedBox(width: w * 0.02),
                      Expanded(child: _filterChip('masuk', 'Masuk')),
                      SizedBox(width: w * 0.02),
                      Expanded(child: _filterChip('keluar', 'Keluar')),
                    ],
                  ),
                  SizedBox(height: h * 0.012),
                  DateFilterBar(
                    label: Session.kepsekDateFilter,
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
              role: Role.kepsek,
              currentIndex: 1,
              onTap: (index) => handleNavbarTap(
                context,
                index,
                Role.kepsek,
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
    if (_isLoadingHistory) {
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
              onPressed: _loadHistory,
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
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(w * 0.04, 0, w * 0.04, h * 0.02),
        itemCount: _filteredSurat.length,
        itemBuilder: (context, index) {
          final surat = _filteredSurat[index];
          final isMasuk = surat['jenisSurat'] == 'Surat Masuk';

          return SuratCard(
            jenisSurat: surat['jenisSurat'] ?? '',
            tanggal: surat['tanggal'] ?? '-',
            data: Map<String, String>.from(surat['data'] ?? {}),
            role: CardRole.kepsek,
            type: CardType.history,
            status: surat['status'],
            onDetail: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isMasuk
                      ? OutputSuratmasuk(
                          suratId: surat['id'] as int? ?? 0,
                          isApproved: surat['status'] == 'disetujui',
                          catatan: surat['catatan'] ?? '-',
                          wakaList: const [],
                          isReadOnly: true,
                          showWaka: false,
                          lampiranUrls: List<String>.from(
                            surat['lampiran'] ?? [],
                          ),
                        )
                      : OutputSuratkeluar(
                          catatan: surat['catatan'] ?? '-',
                          isReadOnly: true,
                          lampiranUrls: List<String>.from(
                            surat['lampiran'] ?? [],
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final w = MediaQuery.of(context).size.width;
    double rf(double size) => (w * (size / 375)).clamp(size * 0.9, size * 1.1);

    final isActive = Session.kepsekJenisFilter == value;
    const activeColor = AppColors.bluePrimary;

    return GestureDetector(
      onTap: () => setState(() => Session.kepsekJenisFilter = value),
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
          label,
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
