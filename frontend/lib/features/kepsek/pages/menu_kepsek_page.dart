import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/dummy.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
// import 'package:ta_mobile_disposisi_surat/data/repositories/surat_repository.dart';
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
  // TODO: aktifkan kalau BE sudah ready
  // final _repo = SuratRepository();

  String _searchQuery = '';

  // ── Dummy data ────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _suratList {
    final isMasuk = widget.jenisSurat == 'Surat Masuk';
    final raw = isMasuk ? SuratDummy.masuk : SuratDummy.keluar;

    // Sort terbaru di atas
    final sorted = [...raw];
    sorted.sort((a, b) {
      final dateA = _parseTanggal(a['tanggal'] ?? '');
      final dateB = _parseTanggal(b['tanggal'] ?? '');
      return dateB.compareTo(dateA);
    });

    return sorted;
  }

  DateTime _parseTanggal(String tanggal) {
    const bulan = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'mei': 5,
      'jun': 6, 'jul': 7, 'agu': 8, 'sep': 9, 'okt': 10,
      'nov': 11, 'des': 12,
      'januari': 1, 'februari': 2, 'maret': 3, 'april': 4,
      'juni': 6, 'juli': 7, 'agustus': 8, 'september': 9,
      'oktober': 10, 'november': 11, 'desember': 12,
    };
    try {
      final parts = tanggal.toLowerCase().split(' ');
      return DateTime(
        int.parse(parts[2]),
        bulan[parts[1]] ?? 1,
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime(1970);
    }
  }
  // ─────────────────────────────────────────────────────────────────────────

  // TODO: aktifkan kalau BE sudah ready
  // Future<void> _fetchSurat() async {
  //   setState(() { _isLoading = true; _errorMessage = null; });
  //   try {
  //     final isMasuk = widget.jenisSurat == 'Surat Masuk';
  //     final raw = isMasuk
  //         ? await _repo.getSuratMasukList()
  //         : await _repo.getSuratKeluarList();
  //     setState(() {
  //       _suratList = raw.map((item) => _mapToCard(item, isMasuk)).toList();
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() { _errorMessage = 'Gagal memuat data. Periksa koneksi.'; _isLoading = false; });
  //   }
  // }
  //
  // String _formatTanggal(String isoDate) {
  //   try {
  //     final dt = DateTime.parse(isoDate);
  //     const months = ['','Januari','Februari','Maret','April','Mei','Juni',
  //         'Juli','Agustus','September','Oktober','November','Desember'];
  //     return '${dt.day} ${months[dt.month]} ${dt.year}';
  //   } catch (_) { return isoDate; }
  // }
  //
  // Map<String, dynamic> _mapToCard(dynamic item, bool isMasuk) {
  //   final tanggalRaw = item['tanggal_surat'] ?? '';
  //   final tanggal = tanggalRaw.isNotEmpty ? _formatTanggal(tanggalRaw.toString()) : '-';
  //   return {
  //     'id': item['id'],
  //     'jenisSurat': widget.jenisSurat,
  //     'tanggal': tanggal,
  //     'status': item['status_verifikasi'] ?? '',
  //     'raw': item,
  //     'data': {
  //       'No Surat': item['no_surat'] ?? '-',
  //       'Tanggal': tanggal,
  //       'Perihal': isMasuk ? (item['perihal_surat'] ?? '-') : (item['perihal'] ?? '-'),
  //       'Dari': isMasuk ? (item['asal_surat'] ?? '-') : (item['tujuan'] ?? '-'),
  //     },
  //   };
  // }

  List<Map<String, dynamic>> get _filteredSurat {
    if (_searchQuery.isEmpty) return _suratList;
    final query = _searchQuery.toLowerCase();
    return _suratList.where((s) {
      final dari = (s['data']?['Dari'] ?? '').toString().toLowerCase();
      final perihal = (s['data']?['Perihal'] ?? '').toString().toLowerCase();
      return dari.contains(query) || perihal.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF2F2F2),
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
              onChanged: (value) => setState(() => _searchQuery = value),
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
        return Padding(
          padding: EdgeInsets.only(bottom: h * 0.01),
          child: SuratCard(
            jenisSurat: surat['jenisSurat'],
            tanggal: surat['tanggal'],
            status: surat['status'],
            data: Map<String, String>.from(surat['data']),
            role: CardRole.kepsek,
            type: CardType.menu,
            onDetail: () {
              final isMasuk = surat['jenisSurat'] == 'Surat Masuk';
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