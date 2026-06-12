import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_keluar_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_masuk.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_keluar.dart';

import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';

import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/disposisi_suratmasuk.dart';
import 'package:ta_mobile_disposisi_surat/features/kepsek/pages/pengajuan_suratkeluar.dart'
    show InputSuratKeluarKepsek;

class KepsekDashboardPage extends StatefulWidget {
  final String jenisSurat;
  const KepsekDashboardPage({super.key, required this.jenisSurat});

  @override
  State<KepsekDashboardPage> createState() => _KepsekDashboardPageState();
}

class _KepsekDashboardPageState extends State<KepsekDashboardPage> {
  final _suratMasukRepo = SuratMasukRepository();
  final _suratKeluarRepo = SuratKeluarRepository();

  List<Map<String, dynamic>> _suratList = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSurat();
  }

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

  // Kepsek hanya lihat surat yang BELUM diproses (menunggu keputusannya)
  bool _isKepsekDone(SuratMasuk s) {
    final statusAlur = s.statusAlur?.toLowerCase() ?? '';
    // Sembunyikan kalau sudah melewati tahap kepsek
    return statusAlur == 'dikirim_ke_waka' ||
        statusAlur == 'dikirim_ke_user' ||
        statusAlur == 'didistribusikan_user' ||
        statusAlur == 'selesai';
  }

  bool _isKepsekDoneKeluar(SuratKeluar s) {
    final status = s.status.toLowerCase();
    return status == 'disetujui' || status == 'ditolak' || status == 'selesai';
  }

  Future<void> _fetchSurat() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.jenisSurat == 'Surat Masuk') {
        final list = await _suratMasukRepo.getList();
        if (!mounted) return;
        setState(() {
          _suratList = list
              .where((s) => !_isKepsekDone(s))
              .map(
                (s) => {
                  'jenisSurat': 'Surat Masuk',
                  'tanggal': _formatTanggal(s.createdAt.toIso8601String()),
                  'status': s.status,
                  'data': {
                    'No Surat': s.noSurat,
                    'Perihal': s.perihal,
                    'Dari': s.asalSurat,
                  },
                  'lampiran': s.lampiranUrls.isNotEmpty
                      ? s.lampiranUrls
                      : (s.previewUrl.isNotEmpty ? [s.previewUrl] : <String>[]),
                  '_raw': s,
                },
              )
              .toList();
        });
      } else {
        final list = await _suratKeluarRepo.getList();
        if (!mounted) return;
        setState(() {
          _suratList = list
              .where((s) => !_isKepsekDoneKeluar(s))
              .map(
                (s) => {
                  'jenisSurat': 'Surat Keluar',
                  'tanggal': _formatTanggal(s.createdAt.toIso8601String()),
                  'status': s.status,
                  'data': {
                    'No Surat': s.noSurat,
                    'Perihal': s.perihal,
                    'Dari': s.tujuan,
                  },
                  'lampiran': s.lampiranUrls ?? <String>[],
                  '_raw': s,
                },
              )
              .toList();
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _error = parseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      final dateA = _parseDate(a['tanggal'] ?? '');
      final dateB = _parseDate(b['tanggal'] ?? '');
      return dateB.compareTo(dateA);
    });
    return result;
  }

  void _openDetail(Map<String, dynamic> surat) async {
    final isMasuk = surat['jenisSurat'] == 'Surat Masuk';
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isMasuk
            ? InputSuratMasuk(surat: surat)
            : InputSuratKeluarKepsek(surat: surat),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      _fetchSurat();
    }
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
              onPressed: _fetchSurat,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredSurat.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada surat ditemukan.',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchSurat,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: h * 0.03),
        itemCount: _filteredSurat.length,
        itemBuilder: (context, index) {
          final surat = _filteredSurat[index];
          return Padding(
            padding: EdgeInsets.only(bottom: h * 0.01),
            child: SuratCard(
              jenisSurat: surat['jenisSurat'].toString(),
              tanggal: surat['tanggal'].toString(),
              status: surat['status']?.toString(),
              data: Map<String, String>.from(surat['data']),
              role: CardRole.kepsek,
              type: CardType.menu,
              onDetail: () => _openDetail(surat),
            ),
          );
        },
      ),
    );
  }
}
