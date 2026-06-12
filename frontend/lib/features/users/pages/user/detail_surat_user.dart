import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ta_mobile_disposisi_surat/core/constants/app_color.dart';
import 'package:ta_mobile_disposisi_surat/core/utils/full-images-viewer.dart';

import '../../../../core/network/api_client.dart';

class DetailSuratUsers extends StatefulWidget {
  final Map<String, dynamic> surat;

  const DetailSuratUsers({super.key, required this.surat});

  @override
  State<DetailSuratUsers> createState() => _DetailSuratUsersState();
}

class _DetailSuratUsersState extends State<DetailSuratUsers> {
  // =========================================================
  // DATA SURAT
  // =========================================================

  Map<String, dynamic> get _suratData => widget.surat['data'] ?? {};

  List<String> get _attachmentUrls =>
      List<String>.from(widget.surat['lampiran'] ?? []);

  /// ✅ FIX: coba semua kemungkinan key yang mungkin dikirim dari API/caller
  String get _catatanWaka {
    final keys = [
      'catatan_waka',
      'catatanWaka',
      'catatan_verifikasi',
      'catatanVerifikasi',
      'catatan',
      'notes',
      'note',
    ];
    for (final key in keys) {
      final val = widget.surat[key]?.toString().trim() ?? '';
      if (val.isNotEmpty) return val;
    }
    return '';
  }

  /// ✅ FIX: nama waka dengan fallback semua kemungkinan key
  String get _namaWaka {
    final keys = [
      'nama_waka',
      'namaWaka',
      'waka_nama',
      'jabatan_waka',
      'jabatanWaka',
    ];
    for (final key in keys) {
      final val = widget.surat[key]?.toString().trim() ?? '';
      if (val.isNotEmpty) return val;
    }
    return '';
  }

  // =========================================================
  // RESPONSIVE HELPER
  // =========================================================
  double rf(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    return size * (width / 375);
  }

  // =========================================================
  // DEBUG: print semua key yang ada di surat (hapus di production)
  // =========================================================
  @override
  void initState() {
    super.initState();
    debugPrint('=== DetailSuratUsers keys: ${widget.surat.keys.toList()}');
    debugPrint('=== DetailSuratUsers full data: ${widget.surat}');
  }

  // =========================================================
  // MAIN UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, w, h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: h * 0.025),

                    _buildDetailCard(context, w, h),

                    SizedBox(height: h * 0.02),

                    // ✅ Catatan waka — selalu tampil section-nya,
                    //    isi "-" kalau kosong agar user tahu field ini ada
                    _buildCatatan(context, w, h),

                    SizedBox(height: h * 0.025),

                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildTombolKonfirmasi(context, w),
                    ),

                    SizedBox(height: h * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================
  Widget _buildHeader(BuildContext context, double w, double h) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.025, left: w * 0.05, right: w * 0.05),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.bluePrimary,
              size: rf(context, 20),
            ),
          ),
          SizedBox(width: w * 0.02),
          Expanded(
            child: Text(
              'Detail Surat Masuk',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: rf(context, 18),
                fontWeight: FontWeight.bold,
                color: AppColors.bluePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DETAIL CARD
  // =========================================================
  Widget _buildDetailCard(BuildContext context, double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rf(context, 20)),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailItem(
            context,
            icon: Icons.description_outlined,
            label: 'Nomor Surat',
            value:
                _suratData['Nomor Surat'] ??
                _suratData['No Surat'] ??
                widget.surat['no_surat']?.toString() ??
                '-',
          ),
          _detailItem(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal',
            value: widget.surat['tanggal'] ?? '-',
          ),
          _detailItem(
            context,
            icon: Icons.person_outline,
            label: 'Pengirim',
            value:
                _suratData['Dari'] ??
                _suratData['Pengirim'] ??
                widget.surat['asal_surat']?.toString() ??
                '-',
          ),
          _detailItem(
            context,
            icon: Icons.notes,
            label: 'Perihal',
            value:
                _suratData['Perihal'] ??
                widget.surat['perihal']?.toString() ??
                '-',
          ),

          // Lampiran
          Text(
            'Lampiran',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: rf(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: h * 0.01),
          if (_attachmentUrls.isEmpty)
            Text(
              'Tidak ada lampiran',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: rf(context, 14),
              ),
            )
          else
            _buildLampiranTile(context, w),
        ],
      ),
    );
  }

  // =========================================================
  // CATATAN WAKA — ✅ selalu render, isi "-" kalau kosong
  // =========================================================
  Widget _buildCatatan(BuildContext context, double w, double h) {
    final catatan = _catatanWaka.isEmpty ? '-' : _catatanWaka;
    final namaWaka = _namaWaka;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rf(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.bluePrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(rf(context, 14)),
        border: Border.all(color: AppColors.bluePrimary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: rf(context, 16),
                color: AppColors.bluePrimary,
              ),
              SizedBox(width: w * 0.02),
              Text(
                'Catatan Waka',
                style: TextStyle(
                  fontSize: rf(context, 13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.bluePrimary,
                ),
              ),
            ],
          ),

          // Nama waka (kalau ada)
          if (namaWaka.isNotEmpty) ...[
            SizedBox(height: h * 0.008),
            Text(
              namaWaka,
              style: TextStyle(
                fontSize: rf(context, 12),
                fontWeight: FontWeight.w600,
                color: AppColors.bluePrimary.withOpacity(0.7),
              ),
            ),
          ],

          SizedBox(height: h * 0.012),

          // Isi catatan
          Text(
            catatan,
            style: TextStyle(
              fontSize: rf(context, 14),
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TOMBOL KONFIRMASI
  // =========================================================
  Widget _buildTombolKonfirmasi(BuildContext context, double w) {
    return ElevatedButton(
      style: _buttonStyle(context),
      onPressed: () async {
        // Ambil disposisi_id yang sudah di-pass via surat map
        final disposisiId = widget.surat['disposisi_id'] as int?;

        if (disposisiId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ID disposisi tidak ditemukan')),
          );
          return;
        }

        try {
          // FIX: PUT /api/disposisi/{disposisi_id}/confirm
          // Pakai ApiClient.dio (bukan ApiClient()) agar JWT ikut terkirim
          final response = await ApiClient.dio.put(
            '/api/disposisi/$disposisiId/confirm',
          );

          if (response.data['success'] == true) {
            _showSuccessDialog(context, 'Konfirmasi berhasil dikirim.');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.data['message'] ?? 'Gagal konfirmasi'),
              ),
            );
          }
        } on DioException catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(parseError(e))));
        }
      },
      child: Text(
        'Konfirmasi',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: rf(context, 14),
          color: Colors.white,
        ),
      ),
    );
  }

  // =========================================================
  // SUCCESS DIALOG
  // =========================================================
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rf(context, 16)),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: rf(context, 24),
              ),
              SizedBox(width: rf(context, 8)),
              Text('Berhasil', style: TextStyle(fontSize: rf(context, 18))),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: rf(context, 14))),
          actions: [
            ElevatedButton(
              style: _buttonStyle(context),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(fontSize: rf(context, 14))),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // LAMPIRAN TILE
  // =========================================================
  Widget _buildLampiranTile(BuildContext context, double w) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              imageUrls: _attachmentUrls,
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rf(context, 14),
          vertical: rf(context, 12),
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(rf(context, 10)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              color: AppColors.bluePrimary,
              size: rf(context, 20),
            ),
            SizedBox(width: w * 0.025),
            Expanded(
              child: Text(
                '${_attachmentUrls.length} File Lampiran',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: rf(context, 14),
                ),
              ),
            ),
            Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.grey.shade500,
              size: rf(context, 16),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STYLES
  // =========================================================
  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(rf(context, 14)),
      boxShadow: [
        BoxShadow(
          blurRadius: rf(context, 12),
          offset: const Offset(0, 4),
          color: Colors.black.withOpacity(0.08),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.bluePrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: rf(context, 20),
        vertical: rf(context, 12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rf(context, 12)),
      ),
    );
  }

  // =========================================================
  // DETAIL ITEM
  // =========================================================
  Widget _detailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: rf(context, 20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: rf(context, 3)),
            child: Icon(
              icon,
              color: Colors.grey.shade500,
              size: rf(context, 24),
            ),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: rf(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: rf(context, 4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: rf(context, 16),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
