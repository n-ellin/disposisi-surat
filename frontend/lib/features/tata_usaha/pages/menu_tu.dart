import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/dummy.dart';

import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/process_dialog.dart';

import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';

//import 'package:ta_mobile_disposisi_surat/data/repositories/surat_repository.dart';

class TuDashboardPage extends StatefulWidget {
  final String jenisSurat;

  const TuDashboardPage({super.key, required this.jenisSurat});

  @override
  State<TuDashboardPage> createState() => _TuDashboardPageState();
}

class _TuDashboardPageState extends State<TuDashboardPage> {
  //final _repo = SuratRepository();

  List<Map<String, dynamic>> _suratList = [];
  bool _isLoading = true;
  String _selectedFilter = 'semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSurat();
  }

  Future<void> _fetchSurat() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _suratList =
          (widget.jenisSurat == 'Surat Masuk'
                  ? SuratDummy.masuk
                  : SuratDummy.keluar)
              .map(
                (s) => {
                  ...s,
                  'status': s['status'] == 'menunggu'
                      ? 'diproses'
                      : s['status'],
                },
              )
              .toList();

      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _allSurat => _suratList;

  List<Map<String, dynamic>> get _filteredSurat {
    List<Map<String, dynamic>> result = List.from(_allSurat);

    if (_selectedFilter != 'semua') {
      result = result.where((s) {
        return (s['status'] ?? '').toString().toLowerCase() ==
            _selectedFilter.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((s) {
        final query = _searchQuery.toLowerCase();

        final tanggal = (s['tanggal'] ?? '').toString().toLowerCase();

        final status = (s['status'] ?? '').toString().toLowerCase();

        final dari = (s['data']?['Dari'] ?? '').toString().toLowerCase();

        final perihal = (s['data']?['Perihal'] ?? '').toString().toLowerCase();

        return tanggal.contains(query) ||
            status.contains(query) ||
            dari.contains(query) ||
            perihal.contains(query);
      }).toList();
    }

    result.sort((a, b) {
      final dateA = _parseDate(a['tanggal'] ?? '');
      final dateB = _parseDate(b['tanggal'] ?? '');

      return dateB.compareTo(dateA);
    });

    return result;
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

  final Map<String, Color> filterColors = {
    'semua': const Color(0xFF6F7A83),
    'diproses': const Color(0xFFC59B36),
    'disetujui': const Color(0xFF3F9142),
    'ditolak': const Color(0xFFB63A3A),
  };

  String _label(String key) {
    switch (key) {
      case 'semua':
        return 'Semua';
      case 'diproses':
        return 'Diproses';
      case 'disetujui':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      default:
        return key;
    }
  }

  Widget _buildBody(double w, double h) {
    if (_filteredSurat.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada surat ditemukan.',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: h * 0.12),
      itemCount: _filteredSurat.length,
      itemBuilder: (context, index) {
        final surat = _filteredSurat[index];

        return SuratCard(
          jenisSurat: surat['jenisSurat'].toString(),
          tanggal: surat['tanggal'].toString(),
          status: surat['status']?.toString(),
          role: CardRole.pegawai,
          type: CardType.menu,
          data: Map<String, String>.from(surat['data']),
          onDetail: () {
            final status = surat['status']?.toString().toLowerCase();
            final isMasuk = surat['jenisSurat'] == 'Surat Masuk';

            if (status == 'diproses' || status == 'menunggu') {
              showProcessDialog(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isMasuk
                      ? OutputSuratmasuk(
                          isApproved: status == 'disetujui',
                          catatan: surat['catatan'] ?? '',
                          jabatanWaka: surat['jabatanWaka'] ?? '',
                          lampiranUrls: List<String>.from(
                            surat['lampiran'] ?? [],
                          ),
                          isReadOnly: true,
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
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: w * 0.04),
            child: SizedBox(
              width: w * 0.1,
              height: w * 0.1,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logosmk.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Disposisi Surat',
                style: TextStyle(
                  fontSize: (w * 0.055).clamp(18.0, 24.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: h * 0.015),
            SearchBarInput(
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            SizedBox(height: h * 0.015),
            Row(
              children: filterColors.keys.map((key) {
                final isSelected = _selectedFilter == key;
                final color = filterColors[key]!;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: color, width: 1.3),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                _label(key),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : color,
                                  fontSize: w * 0.026,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: h * 0.02),
            Expanded(child: _buildBody(w, h)),
          ],
        ),
      ),
    );
  }
}
