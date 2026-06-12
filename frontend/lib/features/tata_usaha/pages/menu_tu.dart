import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/user_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_masuk_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/repositories/surat_keluar_repository.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_masuk.dart';
import 'package:ta_mobile_disposisi_surat/core/models/surat_keluar.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_disposisi_surat_masuk_page.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/search_bar.dart';
import 'package:ta_mobile_disposisi_surat/shared/widgets/surat_card.dart';
import 'package:ta_mobile_disposisi_surat/features/tata_usaha/pages/hasil_pengajuan_surat_keluar_page.dart';

class TuDashboardPage extends StatefulWidget {
  final String jenisSurat;
  const TuDashboardPage({super.key, required this.jenisSurat});

  @override
  State<TuDashboardPage> createState() => _TuDashboardPageState();
}

class _TuDashboardPageState extends State<TuDashboardPage> {
  final _suratMasukRepo = SuratMasukRepository();
  final _suratKeluarRepo = SuratKeluarRepository();
  // FIX: ganti getter null jadi instance yang benar
  final _userRepo = UserRepository();

  List<Map<String, dynamic>> _suratList = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSurat();
  }

  void _showProcessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Surat Dalam Proses',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Surat masih dalam proses pengajuan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
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
                  'lampiran': s.lampiranUrls,
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
                  'lampiran': s.lampiranUrls,
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

  List<Map<String, dynamic>> get _filteredSurat {
    List<Map<String, dynamic>> result = List.from(_suratList);

    if (_selectedFilter != 'semua') {
      result = result
          .where(
            (s) =>
                (s['status'] ?? '').toString().toLowerCase() ==
                _selectedFilter.toLowerCase(),
          )
          .toList();
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

  Future<void> _openDetail(Map<String, dynamic> surat) async {
    final statusCheck = (surat['status'] ?? '').toString().toLowerCase();
    if (statusCheck == 'diproses') {
      _showProcessDialog();
      return;
    }

    final isMasuk = surat['jenisSurat'] == 'Surat Masuk';
    final raw = surat['_raw'];

    try {
      if (isMasuk) {
        final detail = await _suratMasukRepo.getDetail((raw as SuratMasuk).id);

        // FIX: pakai _userRepo.getList(role: 'waka') bukan getWakaList()
        // yang hit endpoint tidak exist (/api/users/waka)
        List<Map<String, dynamic>> wakaListData = [];
        try {
          wakaListData = await _userRepo.getList(role: 'waka');
        } catch (e) {
          debugPrint('Error fetch waka: $e');
        }

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OutputSuratmasuk(
              isApproved: detail.status?.toLowerCase() == 'disetujui',
              catatan: detail.catatanVerifikasi ?? detail.catatan ?? '',
              wakaList: wakaListData,
              isReadOnly: true,
              showWaka: true,
              lampiranUrls: detail.lampiranUrls,
              suratId: detail.id,
              namaWaka: detail.namaWaka,
              jabatanWaka: detail.jabatanWaka,
            ),
          ),
        );
      } else {
        final detail = await _suratKeluarRepo.getDetail(
          (raw as SuratKeluar).id,
        );

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OutputSuratkeluar(
              catatan: detail.catatanVerifikasi ?? detail.catatan ?? '',
              isReadOnly: true,
              lampiranUrls: detail.lampiranUrls ?? [],
            ),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(parseError(e))));
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
            onDetail: () => _openDetail(surat),
          );
        },
      ),
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
