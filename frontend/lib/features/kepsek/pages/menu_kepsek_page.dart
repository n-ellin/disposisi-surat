import 'package:flutter/material.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/data/repositories/surat_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/role.dart';
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
  final _repo = SuratRepository();
  List<Map<String, dynamic>> _suratList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurat();
  }

  Future<void> _fetchSurat() async {
    setState(() => _isLoading = true);
    try {
      final isMasuk = widget.jenisSurat == 'Surat Masuk';
      final raw = isMasuk
          ? await _repo.getSuratMasukList()
          : await _repo.getSuratKeluarList();

      if (!mounted) return;
      setState(() {
        _suratList = raw.map((item) => _mapToCard(item, isMasuk)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTanggal(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
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
      return isoDate;
    }
  }

  Map<String, dynamic> _mapToCard(dynamic item, bool isMasuk) {
    final tanggal = _formatTanggal(item['tanggal_surat']?.toString() ?? '');
    return {
      'id': item['id'],
      'jenisSurat': widget.jenisSurat,
      'tanggal': tanggal,
      'status': item['status_verifikasi']?.toString() ?? 'menunggu',
      'lampiran': item['lampiran'] ?? [],
      'no_surat': item['no_surat'],
      'perihal_surat': item['perihal_surat'],
      'perihal': item['perihal'],
      'asal_surat': item['asal_surat'],
      'tujuan': item['tujuan'],
      'kode_surat': item['kode_surat'],
      'data': {
        'No Surat': item['no_surat']?.toString() ?? '-',
        'Perihal': isMasuk
            ? (item['perihal_surat']?.toString() ?? '-')
            : (item['perihal']?.toString() ?? '-'),
        'Dari': isMasuk
            ? (item['asal_surat']?.toString() ?? '-')
            : (item['tujuan']?.toString() ?? '-'),
      },
    };
  }

  List<Map<String, dynamic>> get _filteredSurat {
    if (_searchQuery.isEmpty) return _suratList;
    final query = _searchQuery.toLowerCase();
    return _suratList.where((s) {
      final dari = (s['data']?['Dari'] ?? '').toString().toLowerCase();
      final perihal = (s['data']?['Perihal'] ?? '').toString().toLowerCase();
      return dari.contains(query) || perihal.contains(query);
    }).toList();
  }

  String _searchQuery = '';

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
