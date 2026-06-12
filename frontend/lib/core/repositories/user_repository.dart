import '../network/api_client.dart';

class UserRepository {
  final _dio = ApiClient.dio;

  /// GET /api/users
  /// Accessible: admin, kepsek, pegawai, waka
  /// Dipakai untuk: forward modal (pilih waka/guru penerima disposisi)
  /// Query params opsional untuk filter
  Future<List<Map<String, dynamic>>> getList({
    String? role,   // 'waka' | 'user' | 'pegawai' | 'kepsek'
    String? search,
  }) async {
    final res = await _dio.get(
      '/api/users',
      queryParameters: {
        if (role != null && role.isNotEmpty) 'role': role,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final List raw = res.data['data'] as List? ?? [];
    return raw.cast<Map<String, dynamic>>();
  }
}