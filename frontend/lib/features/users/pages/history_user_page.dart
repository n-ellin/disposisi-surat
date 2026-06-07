import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filterdatebar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/custom_navbar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
import 'package:ta_mobile_disposisi_surat/core/helpers/navigation_helper.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/session.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/dummy.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/filter_date.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';

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
  DateTime _parseTanggal(String tanggal) {
    const bulan = {
      'jan': 1, 'januari': 1,
      'feb': 2, 'februari': 2,
      'mar': 3, 'maret': 3,
      'apr': 4, 'april': 4,
      'mei': 5,
      'jun': 6, 'juni': 6,
      'jul': 7, 'juli': 7,
      'agu': 8, 'agustus': 8,
      'sep': 9, 'september': 9,
      'okt': 10, 'oktober': 10,
      'nov': 11, 'november': 11,
      'des': 12, 'desember': 12,
    };

    try {
      final parts = tanggal.toLowerCase().trim().split(' ');
      final day = int.parse(parts[0]);
      final month = bulan[parts[1]] ?? 1;
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime(1970);
    }
  }

  List<Map<String, dynamic>> get _historySurat {
    final suratRole = SuratDummy.suratUntukRole(
      widget.role,
      jabatan: widget.jabatan,
    );

    return suratRole
        .where((s) => s['status'] == 'disetujui' || s['status'] == 'ditolak')
        .map((s) => {...s, 'jenisSurat': 'Surat Masuk'})
        .toList()
      ..sort((a, b) {
        final dateA = _parseTanggal(a['tanggal'] ?? '');
        final dateB = _parseTanggal(b['tanggal'] ?? '');
        return dateB.compareTo(dateA);
      });
  }

  List<Map<String, dynamic>> get _filteredSurat {
    return _historySurat.where((s) {
      final query = Session.userHistorySearchQuery.toLowerCase();
      final jenis = s['jenisSurat'].toString().toLowerCase();
      final tanggal = s['tanggal'].toString().toLowerCase();
      final dari = (s['data']?['Dari'] ?? '').toString().toLowerCase();
      final perihal = (s['data']?['Perihal'] ?? '').toString().toLowerCase();

      final matchSearch =
          Session.userHistorySearchQuery.isEmpty ||
          jenis.contains(query) ||
          tanggal.contains(query) ||
          dari.contains(query) ||
          perihal.contains(query);

      bool matchDate = true;
      try {
        final suratDate = _parseTanggal(s['tanggal'] ?? '');
        if (Session.userHistoryStartDate != null &&
            Session.userHistoryEndDate != null) {
          final start = DateTime(
            Session.userHistoryStartDate!.year,
            Session.userHistoryStartDate!.month,
            Session.userHistoryStartDate!.day,
          );
          final end = DateTime(
            Session.userHistoryEndDate!.year,
            Session.userHistoryEndDate!.month,
            Session.userHistoryEndDate!.day,
            23, 59, 59,
          );
          matchDate =
              suratDate.isAfter(start.subtract(const Duration(days: 1))) &&
              suratDate.isBefore(end.add(const Duration(seconds: 1)));
        }
      } catch (_) {
        matchDate = true;
      }

      return matchSearch && matchDate;
    }).toList();
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
  }

  void _openLampiran(BuildContext context, Map<String, dynamic> surat) {
    final List<String> lampiran = List<String>.from(surat['lampiran'] ?? []);
    if (lampiran.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Tidak ada lampiran"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FullScreenImageViewer(imageUrls: lampiran, initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    double rf(double size) =>
        (w * (size / 375)).clamp(size * 0.9, size * 1.15);

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
                    onChanged: (value) => setState(
                      () => Session.userHistorySearchQuery = value,
                    ),
                  ),

                  SizedBox(height: h * 0.014),

                  DateFilterBar(
                    label: Session.userHistoryDateFilter,
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
                        w * 0.04, 0, w * 0.04, h * 0.02,
                      ),
                      itemCount: _filteredSurat.length,
                      itemBuilder: (context, index) {
                        final surat = _filteredSurat[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: rf(8)),
                          child: SuratCard(
                            jenisSurat: surat['jenisSurat'].toString(),
                            tanggal: surat['tanggal'].toString(),
                            role: CardRole.Users,
                            type: CardType.history,
                            status: surat['status']?.toString(),
                            data: Map<String, String>.from(surat['data']),
                            diteruskanKe: surat['diteruskanKe']?.toString(),
                            onDetail: () => _openLampiran(context, surat),
                          ),
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
              role: widget.role,
              currentIndex: 1,
              onTap: (index) => handleNavbarTap(
                context, index, widget.role,
                widget.nama, widget.email, widget.jabatan,
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
}