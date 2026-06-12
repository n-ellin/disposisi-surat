import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ta_mobile_disposisi_surat/core/network/api_client.dart';

class DownloadHelper {

  // ── Deteksi apakah file adalah PDF ───────────────────────────────────────
  static bool _isPdf(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.pdf');
  }

  // ── Dapatkan path Downloads untuk PDF ────────────────────────────────────
  static Future<String> _getPdfSavePath(String fileName) async {
    if (Platform.isAndroid) {
      // Folder Downloads publik Android
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) {
        return '${publicDownloads.path}/$fileName';
      }
      // Fallback: folder eksternal app (tidak perlu permission)
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) return '${extDir.path}/$fileName';
    }
    // iOS: folder Documents app
    final docs = await getApplicationDocumentsDirectory();
    return '${docs.path}/$fileName';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Download satu file — otomatis deteksi PDF vs gambar
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> downloadToGallery(
    BuildContext context, {
    required String imageUrl,
    String? fileName,
  }) async {
    // Nama file dari parameter atau ambil dari URL
    final name = fileName ??
        imageUrl.split('/').last.split('?').first;

    // Tampilkan loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(minutes: 3),
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Mengunduh...'),
            ],
          ),
        ),
      );
    }

    try {
      if (_isPdf(imageUrl)) {
        // ✅ PDF → simpan ke folder Downloads
        await _downloadPdf(context, imageUrl, name);
      } else {
        // ✅ Gambar → simpan ke Gallery pakai Gal
        await _downloadImage(context, imageUrl, name);
      }
    } on DioException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      String pesan;
      switch (e.response?.statusCode) {
        case 401: pesan = '❌ Sesi habis — login ulang'; break;
        case 403: pesan = '❌ Tidak punya akses ke file ini'; break;
        case 404: pesan = '❌ File tidak ditemukan di server'; break;
        default:  pesan = '❌ Gagal download: ${e.message}';
      }
      _showResult(context, pesan, isError: true);
      debugPrint('❌ DioException [$imageUrl]: $e');

    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showResult(context, '❌ Terjadi kesalahan: $e', isError: true);
      debugPrint('❌ Download error: $e');
    }
  }

  // ── Download PDF → folder Downloads ──────────────────────────────────────
  static Future<void> _downloadPdf(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    final savePath = await _getPdfSavePath(fileName);
    debugPrint('📥 Download PDF: $url → $savePath');

    // ✅ Pakai ApiClient.dio (bukan Dio() baru) — sudah ada token auth
    await ApiClient.dio.download(
      url,
      savePath,
      deleteOnError: true,
      options: Options(
        receiveTimeout: const Duration(minutes: 3),
        sendTimeout: const Duration(minutes: 1),
      ),
      onReceiveProgress: (received, total) {
        if (total > 0) {
          debugPrint('📦 ${(received / total * 100).toInt()}%');
        }
      },
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Tampilkan sukses + tombol "Buka PDF"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ PDF berhasil diunduh',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              fileName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Buka',
          textColor: Colors.white,
          onPressed: () => OpenFilex.open(savePath),
        ),
      ),
    );
  }

  // ── Download gambar → Gallery ─────────────────────────────────────────────
  static Future<void> _downloadImage(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    // Minta izin galeri
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) {
        _showResult(context, '❌ Izin galeri ditolak.', isError: true);
        return;
      }
    }

    final tempDir  = await getTemporaryDirectory();
    final savePath = '${tempDir.path}/$fileName';

    debugPrint('📥 Download gambar: $url → $savePath');

    // ✅ Pakai ApiClient.dio bukan Dio() baru
    await ApiClient.dio.download(url, savePath);

    // Simpan ke galeri HP
    await Gal.putImage(savePath);

    // Hapus file temp
    final tempFile = File(savePath);
    if (await tempFile.exists()) await tempFile.delete();

    _showResult(context, '✅ Gambar disimpan ke galeri.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Download semua file (PDF maupun gambar)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> downloadAllPages(
    BuildContext context, {
    required List<String> imageUrls,
    String prefix = 'surat',
  }) async {
    if (imageUrls.isEmpty) {
      _showResult(context, '❌ Tidak ada lampiran.', isError: true);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏳ Mengunduh ${imageUrls.length} file...'),
          duration: const Duration(minutes: 5),
        ),
      );
    }

    // Cek izin galeri kalau ada file gambar
    final adaGambar = imageUrls.any((url) => !_isPdf(url));
    if (adaGambar) {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _showResult(context, '❌ Izin galeri ditolak.', isError: true);
          return;
        }
      }
    }

    final tempDir = await getTemporaryDirectory();
    int sukses = 0;
    int gagal  = 0;

    for (int i = 0; i < imageUrls.length; i++) {
      final url   = imageUrls[i];
      final isPdf = _isPdf(url);
      // ✅ Ekstensi sesuai jenis file
      final ext      = isPdf ? '.pdf' : '.jpg';
      final fileName = '${prefix}_${i + 1}$ext';

      try {
        if (isPdf) {
          // PDF → Downloads folder
          final savePath = await _getPdfSavePath(fileName);
          await ApiClient.dio.download( // ✅ auth headers
            url,
            savePath,
            deleteOnError: true,
          );
        } else {
          // Gambar → Gallery
          final savePath = '${tempDir.path}/$fileName';
          await ApiClient.dio.download(url, savePath); // ✅ auth headers
          await Gal.putImage(savePath);
          final f = File(savePath);
          if (await f.exists()) await f.delete();
        }
        sukses++;
      } catch (e) {
        gagal++;
        debugPrint('❌ Gagal download file ${i + 1}: $e');
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gagal == 0
            ? Colors.green.shade700
            : Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        content: Text(
          gagal == 0
              ? '✅ $sukses file berhasil diunduh'
              : '⚠️ $sukses berhasil, $gagal gagal',
        ),
      ),
    );
  }

  // ── Helper tampilkan snackbar ─────────────────────────────────────────────
  static void _showResult(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade700 : Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}