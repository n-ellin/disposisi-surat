import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filterdatebar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filter_date.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/dummy.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';

// TODO: aktifkan kalau BE sudah ready
// import 'package:ta_mobile_disposisi_surat/data/repositories/surat_repository.dart';

class HistoryKepsekPage extends StatefulWidget {
  const HistoryKepsekPage({super.key});

  @override
  State<HistoryKepsekPage> createState() => _HistoryKepsekPageState();
}

class _HistoryKepsekPageState extends State<HistoryKepsekPage> {
  DateTime _parseTanggal(String tanggal) {
    const bulan = {
      'januari': 1, 'jan': 1,
      'februari': 2, 'feb': 2,
      'maret': 3, 'mar': 3,
      'april': 4, 'apr': 4,
      'mei': 5,
      'juni': 6, 'jun': 6,
      'juli': 7, 'jul': 7,
      'agustus': 8, 'agu': 8,
      'september': 9, 'sep': 9,
      'oktober': 10, 'okt': 10,
      'november': 11, 'nov': 11,
      'desember': 12, 'des': 12,
    };
    try {
      final parts = tanggal.toLowerCase().split(' ');
      final day = int.parse(parts[0]);
      final month = bulan[parts[1]] ?? 1;
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime(1970);
    }
  }

  List<Map<String, dynamic>> get _historySurat {
    final masuk = SuratDummy.masuk
        .where((s) => s['status'] == 'disetujui' || s['status'] == 'ditolak')
        .map((s) => {...s, 'jenisSurat': 'Surat Masuk'})
        .toList();

    final keluar = SuratDummy.keluar
        .where((s) => s['status'] == 'disetujui' || s['status'] == 'ditolak')
        .map((s) => {...s, 'jenisSurat': 'Surat Keluar'})
        .toList();

    final result = [...masuk, ...keluar];
    result.sort((a, b) {
      final dateA = _parseTanggal(a['tanggal'] ?? '');
      final dateB = _parseTanggal(b['tanggal'] ?? '');
      return dateB.compareTo(dateA);
    });
    return result;
  }

  List<Map<String, dynamic>> get _filteredSurat {
    return _historySurat.where((s) {
      final status = s['status'].toString().toLowerCase();
      if (status != 'disetujui' && status != 'ditolak') return false;

      final query = Session.kepsekSearchQuery.toLowerCase();
      final jenis = s['jenisSurat'].toString().toLowerCase();
      final tanggal = s['tanggal'].toString().toLowerCase();
      final dari = s['data']['Dari'].toString().toLowerCase();
      final perihal = s['data']['Perihal'].toString().toLowerCase();

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

      bool matchDate = true;
      try {
        final suratDate = _parseTanggal(s['tanggal'] ?? '');
        if (Session.kepsekStartDate != null && Session.kepsekEndDate != null) {
          final start = DateTime(
            Session.kepsekStartDate!.year,
            Session.kepsekStartDate!.month,
            Session.kepsekStartDate!.day,
          );
          final end = DateTime(
            Session.kepsekEndDate!.year,
            Session.kepsekEndDate!.month,
            Session.kepsekEndDate!.day,
            23, 59, 59,
          );
          matchDate =
              suratDate.isAfter(start.subtract(const Duration(days: 1))) &&
              suratDate.isBefore(end.add(const Duration(seconds: 1)));
        }
      } catch (_) {
        matchDate = true;
      }

      return matchSearch && matchJenis && matchDate;
    }).toList();
  }

  void _showDateFilter() async {
    final result = await DateRangeFilterBottomSheet.show(
      context: context,
      initialStartDate: Session.kepsekStartDate,
      initialEndDate: Session.kepsekEndDate,
      initialChip: Session.kepsekActiveChip,
    );
    if (result == null) return;
    setState(() {
      Session.kepsekStartDate = result.startDate;
      Session.kepsekEndDate = result.endDate;
      Session.kepsekActiveChip = result.activeChip;
      Session.kepsekDateFilter = result.dateFilterLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    double rf(double size) {
      return (w * (size / 375)).clamp(size * 0.9, size * 1.15);
    }

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
                    "Riwayat",
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
                      Expanded(child: _filterChip("semua", "Semua")),
                      SizedBox(width: w * 0.02),
                      Expanded(child: _filterChip("masuk", "Masuk")),
                      SizedBox(width: w * 0.02),
                      Expanded(child: _filterChip("keluar", "Keluar")),
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

            Expanded(
              child: _filteredSurat.isEmpty
                  ? Center(
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
                            "Belum ada riwayat surat",
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
                      padding: EdgeInsets.fromLTRB(
                        w * 0.04,
                        0,
                        w * 0.04,
                        h * 0.02,
                      ),
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
                                        isApproved: surat['status'] == 'disetujui',
                                        catatan: surat['catatan'] ?? '-',
                                        jabatanWaka: surat['jabatanWaka'] ?? '-',
                                        isReadOnly: true,
                                        showWaka: false,
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
            ),
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
              onTap: (index) {
                handleNavbarTap(
                  context,
                  index,
                  Role.kepsek,
                  "Kepala Sekolah",
                  "kepsek@gmail.com",
                  "Kepala Sekolah",
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
    );
  }

  Widget _filterChip(String value, String label) {
    final w = MediaQuery.of(context).size.width;

    double rf(double size) {
      return (w * (size / 375)).clamp(size * 0.9, size * 1.1);
    }

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