import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/models/surat_keluar.dart';

class SuratKeluarRepository {
  final _dio = ApiClient.dio;

  /// GET /api/surat-keluar
  /// BE filter otomatis berdasarkan role JWT:
  /// - user/waka → hanya surat yang relevan
  /// - kepsek/admin/pegawai → semua surat aktif
  Future<List<SuratKeluar>> getList({
    String? status,
    String? search,
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    final res = await _dio.get(
      '/api/surat-keluar',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (tanggalAwal != null) 'date_from': tanggalAwal,
        if (tanggalAkhir != null) 'date_to': tanggalAkhir,
      },
    );
    final List raw = res.data['data'] ?? [];
    return raw.map((e) => SuratKeluar.fromJson(e)).toList();
  }

  /// GET /api/surat-keluar/history
  /// BE filter otomatis berdasarkan role JWT
  Future<List<SuratKeluar>> getHistory({
    String? status,
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    final res = await _dio.get(
      '/api/surat-keluar/history',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (tanggalAwal != null) 'date_from': tanggalAwal,
        if (tanggalAkhir != null) 'date_to': tanggalAkhir,
      },
    );
    final List raw = res.data['data'] ?? [];
    return raw.map((e) => SuratKeluar.fromJson(e)).toList();
  }

  /// GET /api/surat-keluar/:id
  Future<SuratKeluar> getDetail(int id) async {
    final res = await _dio.get('/api/surat-keluar/$id');
    return SuratKeluar.fromJson(res.data['data']);
  }

  /// POST /api/surat-keluar (multipart — ada file PDF)
  Future<SuratKeluar> create({
    required int kodeSurat,
    required String noSurat,
    required String perihal,
    required String tanggalSurat, // "YYYY-MM-DD"
    required String filePath,
    String? tujuan,
    String? catatan,
  }) async {
    final formData = FormData.fromMap({
      'kode_surat': kodeSurat,
      'no_surat': noSurat,
      'perihal': perihal,
      'tanggal_surat': tanggalSurat,
      if (tujuan != null) 'tujuan': tujuan,
      if (catatan != null) 'catatan': catatan,
      'file_pdf': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });
    final res = await _dio.post('/api/surat-keluar', data: formData);
    return SuratKeluar.fromJson(res.data['data']);
  }

  /// PUT /api/surat-keluar/:id/review (Kepsek: approve / tolak)
  /// Body: { status: "disetujui" | "ditolak", catatan: "..." }
  Future<void> review(
    int id, {
    required bool isApproved,
    String catatan = '',
  }) async {
    await _dio.put(
      '/api/surat-keluar/$id/review',
      data: {
        'status': isApproved ? 'disetujui' : 'ditolak',
        'catatan': catatan,
      },
    );
  }

  /// PUT /api/surat-keluar/:id/arsip (TU: arsipkan surat)
  Future<void> arsip(int id) async {
    await _dio.put('/api/surat-keluar/$id/arsip');
  }

  /// DELETE /api/surat-keluar/:id (TU: hapus surat, hanya jika masih menunggu)
  Future<void> delete(int id) async {
    await _dio.delete('/api/surat-keluar/$id');
  }
}
