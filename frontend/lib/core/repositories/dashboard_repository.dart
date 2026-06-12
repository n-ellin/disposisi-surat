import '../network/api_client.dart';

class DashboardRepository {
  final _dio = ApiClient.dio;

  /// GET /api/dashboard/stats
  /// Response: { success, data: { ... } }
  /// Field yang dikembalikan BE tergantung role JWT:
  /// - pegawai/admin : total_surat_masuk, total_surat_keluar, menunggu_review, dll
  /// - kepsek        : menunggu_persetujuan, sudah_disetujui, dll
  /// - waka          : menunggu_terusan, sudah_diteruskan
  /// - user          : disposisi_belum_baca, disposisi_sudah_baca
  Future<Map<String, dynamic>> getStats() async {
    final res = await _dio.get('/api/dashboard/stats');
    return res.data['data'] as Map<String, dynamic>? ?? {};
  }
}