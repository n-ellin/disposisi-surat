// lib/core/helpers/download_helper.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
  static final _dio = Dio();

  /// Download satu gambar dari URL → simpan ke galeri
  /// Tampilkan SnackBar sukses/gagal otomatis
  static Future<void> downloadToGallery(
    BuildContext context, {
    required String imageUrl,
    String? fileName, // opsional, kalau null pakai nama dari URL
  }) async {
    // Ambil nama file dari URL kalau tidak disediakan
    final name = fileName ?? imageUrl.split('/').last.split('?').first;

    // Tampilkan loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
        duration: Duration(seconds: 30), // akan di-dismiss manual
      ),
    );

    try {
      // 1. Minta izin galeri
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _showResult(context, '❌ Izin galeri ditolak.', isError: true);
          return;
        }
      }

      // 2. Download file ke temp folder
      final tempDir  = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$name';

      await _dio.download(
        imageUrl,
        savePath,
        onReceiveProgress: (received, total) {
          // bisa dipakai untuk progress bar kalau mau
        },
      );

      // 3. Simpan ke galeri
      await Gal.putImage(savePath);

      // 4. Hapus file temp
      final tempFile = File(savePath);
      if (await tempFile.exists()) await tempFile.delete();

      _showResult(context, '✅ Gambar disimpan ke galeri.');
    } on GalException catch (e) {
      _showResult(context, '❌ Gagal simpan ke galeri: ${e.type}', isError: true);
    } on DioException catch (e) {
      _showResult(context, '❌ Gagal download: ${e.message}', isError: true);
    } catch (e) {
      _showResult(context, '❌ Terjadi kesalahan.', isError: true);
    }
  }

  /// Download semua halaman surat (semua pages[]) ke galeri
  static Future<void> downloadAllPages(
    BuildContext context, {
    required List<String> imageUrls,
    String prefix = 'surat', // prefix nama file
  }) async {
    if (imageUrls.isEmpty) {
      _showResult(context, '❌ Tidak ada lampiran.', isError: true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mengunduh ${imageUrls.length} halaman...'),
        duration: const Duration(seconds: 30),
      ),
    );

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _showResult(context, '❌ Izin galeri ditolak.', isError: true);
          return;
        }
      }

      final tempDir = await getTemporaryDirectory();
      int success = 0;

      for (int i = 0; i < imageUrls.length; i++) {
        final url      = imageUrls[i];
        final savePath = '${tempDir.path}/${prefix}_halaman_${i + 1}.jpg';

        await _dio.download(url, savePath);
        await Gal.putImage(savePath);

        final tempFile = File(savePath);
        if (await tempFile.exists()) await tempFile.delete();

        success++;
      }

      _showResult(context, '✅ $success halaman disimpan ke galeri.');
    } catch (e) {
      _showResult(context, '❌ Gagal download: $e', isError: true);
    }
  }

  // ── internal helper ────────────────────────────────────────────────────────
  static void _showResult(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}