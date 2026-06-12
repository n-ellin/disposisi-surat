import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/models/surat_masuk.dart';

class SuratMasukRepository {
  final _dio = ApiClient.dio;

  /// GET /api/surat-masuk
  /// BE otomatis filter berdasarkan role dari JWT:
  /// - user  → hanya surat yang didisposisi ke mereka (belum dibaca)
  /// - waka  → surat yang diteruskan TU ke waka (belum diteruskan ke user)
  /// - kepsek/admin/pegawai → sesuai status
  Future<List<SuratMasuk>> getList({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    // Alias params dipakai history_tu.dart
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    final res = await _dio.get(
      '/api/surat-masuk',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
        if (tanggalAwal != null) 'date_from': tanggalAwal,
        if (tanggalAkhir != null) 'date_to': tanggalAkhir,
      },
    );
    final List raw = res.data['data'] ?? [];
    return raw
        .map((e) => SuratMasuk.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/users/waka
  Future<List<Map<String, dynamic>>> getWakaList() async {
    final res = await _dio.get('/api/users/waka');
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }

  /// GET /api/surat-masuk/history
  /// BE otomatis filter berdasarkan role:
  /// - user  → surat yang sudah dibaca/dikonfirmasi
  /// - waka  → surat yang sudah diteruskan ke user
  /// - kepsek → surat yang sudah di-approve/tolak
  /// - admin/pegawai → semua history
  Future<List<SuratMasuk>> getHistory({
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final res = await _dio.get(
      '/api/surat-masuk/history',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      },
    );
    final List raw = res.data['data'] ?? [];
    return raw
        .map((e) => SuratMasuk.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/surat-masuk/:id
  /// Response: { success, data: { surat: {...}, disposisi: [...] } }
  Future<SuratMasuk> getDetail(int id) async {
    final res = await _dio.get('/api/surat-masuk/$id');
    return SuratMasuk.fromDetailJson(res.data['data'] as Map<String, dynamic>);
  }

  /// POST /api/surat-masuk (TU upload surat, multipart/form-data)
  Future<SuratMasuk> create({
    required String noSurat,
    required String perihalSurat,
    required String asalSurat,
    required String tanggalSurat,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'no_surat': noSurat,
      'perihal_surat': perihalSurat,
      'asal_surat': asalSurat,
      'tanggal_surat': tanggalSurat,
      'file_pdf': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });
    final res = await _dio.post('/api/surat-masuk', data: formData);
    return SuratMasuk.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// PUT /api/surat-masuk/:id/review (KEPSEK: approve/tolak)
  /// Body: { status: "disetujui"|"ditolak", catatan: "...", target_penerima: [...] }
  Future<void> review(
    int id, {
    required bool isApproved,
    String catatan = '',
    List<String> targetPenerima = const [],
  }) async {
    await _dio.put(
      '/api/surat-masuk/$id/review',
      data: {
        'status': isApproved ? 'disetujui' : 'ditolak',
        'catatan': catatan,
        if (targetPenerima.isNotEmpty) 'target_penerima': targetPenerima,
      },
    );
  }

  /// PUT /api/surat-masuk/:id/teruskan (TU: teruskan ke Waka)
  /// Body: { diteruskan_ke: [wakaUserId], targets: [{user_id, jabatan_id}] }
  Future<void> teruskanKeWaka(int id, {required List<int> wakaIds}) async {
    await _dio.put(
      '/api/surat-masuk/$id/teruskan',
      data: {'diteruskan_ke': wakaIds},
    );
  }

  /// PUT /api/surat-masuk/:id/teruskan-waka (WAKA: teruskan ke user/guru)
  /// Body: { diteruskan_ke: [userId, ...], catatan_waka: "..." }
  Future<void> teruskanKeUser(
    int id, {
    required List<int> userIds,
    String catatanWaka = '',
  }) async {
    await _dio.put(
      '/api/surat-masuk/$id/teruskan-waka',
      data: {'diteruskan_ke': userIds, 'catatan_waka': catatanWaka},
    );
  }

  /// PUT /api/disposisi/:id/confirm (User: konfirmasi sudah baca)
  /// BE juga auto-confirm ketika user buka detail (GET /api/surat-masuk/:id)
  Future<void> konfirmasiPenerimaan(int disposisiId) async {
    await _dio.put('/api/disposisi/$disposisiId/confirm');
  }

  /// PUT /api/surat-masuk/:id/arsip (TU: arsipkan surat)
  Future<void> arsip(int id) async {
    await _dio.put('/api/surat-masuk/$id/arsip');
  }

  /// DELETE /api/surat-masuk/:id (TU: hapus surat, hanya jika masih menunggu)
  Future<void> delete(int id) async {
    await _dio.delete('/api/surat-masuk/$id');
  }

  /// PUT /api/surat-masuk/:id/teruskan — alias dipakai OutputSuratmasuk
  /// Teruskan ke Waka (TU action), body: { diteruskan_ke: [wakaId] }
  Future<void> disposisi(int id, {required int wakaId}) async {
    await _dio.put(
      '/api/surat-masuk/$id/teruskan',
      data: {
        'diteruskan_ke': [wakaId],
      },
    );
  }
}
