import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthRepository {
  final _dio = ApiClient.dio;

  /// POST /api/auth/login
  /// Response: { success, data: { token, refresh_token?, user: {...} } }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final token = res.data['data']['token'] as String;
    final user = res.data['data']['user'] as Map<String, dynamic>;

    await TokenStorage.saveToken(token);

    final refreshToken = res.data['data']['refresh_token'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await TokenStorage.saveRefreshToken(refreshToken);
    }

    return user;
  }

  /// GET /api/profile
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/api/profile');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /api/auth/me
  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/api/auth/me');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Logout
  Future<void> logout() async {
    await TokenStorage.deleteToken();
  }
}
