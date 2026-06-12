import '../network/api_client.dart';

class UserRepository {
  final _dio = ApiClient.dio;

  /// GET /api/users
  /// Filter client-side by role karena backend tidak support query param role
  Future<List<Map<String, dynamic>>> getList({
    String? role,
    String? search,
  }) async {
    final res = await _dio.get(
      '/api/users',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final List raw = res.data['data'] as List? ?? [];
    List<Map<String, dynamic>> result = raw.cast<Map<String, dynamic>>();

    // Filter client-side by role
    if (role != null && role.isNotEmpty) {
      result = result.where((u) => u['role'] == role).toList();
    }

    return result;
  }
}
