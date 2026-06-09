import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/dummy.dart';

import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';

import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/disposisi_suratmasuk.dart';
import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/pengajuan_suratkeluar.dart';

class KepsekDashboardPage extends StatefulWidget {
  final String jenisSurat;

  const KepsekDashboardPage({super.key, required this.jenisSurat});

  @override
  State<KepsekDashboardPage> createState() => _KepsekDashboardPageState();
}

class _KepsekDashboardPageState extends State<KepsekDashboardPage> {
  List<Map<String, dynamic>> _suratList = [];
  bool _isLoading = true;
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
      _suratList = widget.jenisSurat == 'Surat Masuk'
          ? List<Map<String, dynamic>>.from(SuratDummy.masuk)
          : List<Map<String, dynamic>>.from(SuratDummy.keluar);

      _isLoading = false;
    });
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

  List<Map<String, dynamic>> get _filteredSurat {
    List<Map<String, dynamic>> result = [..._suratList];

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      result = result.where((s) {
        final tanggal = (s['tanggal'] ?? '').toString().toLowerCase();

        final dari = (s['data']?['Dari'] ?? '').toString().toLowerCase();

        final perihal = (s['data']?['Perihal'] ?? '').toString().toLowerCase();

        return tanggal.contains(query) ||
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disposisi Surat',
              style: TextStyle(
                fontSize: (w * 0.055).clamp(18.0, 24.0),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: h * 0.015),

            SearchBarInput(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            SizedBox(height: h * 0.015),

            Expanded(child: _buildBody(w, h)),
          ],
        ),
      ),
    );
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
      padding: EdgeInsets.only(bottom: h * 0.03),
      itemCount: _filteredSurat.length,
      itemBuilder: (context, index) {
        final surat = _filteredSurat[index];

        final isMasuk = widget.jenisSurat == 'Surat Masuk';

        return Padding(
          padding: EdgeInsets.only(bottom: h * 0.01),
          child: SuratCard(
            jenisSurat: widget.jenisSurat,
            tanggal: surat['tanggal']?.toString() ?? '-',
            status: surat['status']?.toString(),

            data: {
              'No Surat': surat['data']?['No. Surat']?.toString() ?? '-',

              'Perihal': surat['data']?['Perihal']?.toString() ?? '-',

              'Dari': surat['data']?['Dari']?.toString() ?? '-',
            },

            role: CardRole.kepsek,
            type: CardType.menu,

            onDetail: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isMasuk
                      ? InputSuratMasuk(surat: surat)
                      : InputSuratKeluar(surat: surat),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
