import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_config.dart';
import '../../core/network/dio_client.dart';

class AuthRepository {
  final _client = DioClient();
  final _storage = const FlutterSecureStorage();

  // ─── Login ─────────────────────────────────────────────────────────────────

  /// Login user. Simpan token + data user ke secure storage.
  /// Return map berisi: { token, user: { id, nama, email, role, jabatan } }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      ApiConfig.login,
      data: {'email': email, 'password': password},
    );

    // BE membungkus response di dalam 'data'
    final data = res['data'] as Map<String, dynamic>? ?? res;
    final token = data['token']?.toString() ?? '';
    final refreshToken = data['refresh_token']?.toString() ?? '';
    final user = data['user'] as Map<String, dynamic>? ?? {};

    // Simpan ke secure storage
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: user['id']?.toString() ?? '');
    await _storage.write(key: 'nama', value: user['nama']?.toString() ?? '');
    await _storage.write(key: 'email', value: user['email']?.toString() ?? '');
    await _storage.write(key: 'role', value: user['role']?.toString() ?? '');
    await _storage.write(
      key: 'jabatan',
      value: user['nama_jabatan']?.toString() ?? '',
    );

    // Return format yang diexpect login_page.dart
    return {'token': token, 'user': user};
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _client.post(ApiConfig.logout);
    } catch (_) {
      // Tetap clear storage meski BE error
    } finally {
      await _storage.deleteAll();
    }
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _client.get(ApiConfig.profile);
    return res['data'] as Map<String, dynamic>? ?? res;
  }

  // ─── Change Password ───────────────────────────────────────────────────────

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _client.post(
      ApiConfig.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  // ─── Forgot Password / OTP ─────────────────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    await _client.post(ApiConfig.forgotPassword, data: {'email': email});
  }

  Future<void> resendOtp(String email) async {
    await _client.post(ApiConfig.resendOtp, data: {'email': email});
  }

  /// Return reset_token yang dipakai untuk reset password.
  Future<String> verifyOtp({required String email, required String otp}) async {
    final res = await _client.post(
      ApiConfig.verifyOtp,
      data: {'email': email, 'code': otp},
    );
    final data = res['data'] as Map<String, dynamic>? ?? res;
    return data['reset_token']?.toString() ?? '';
  }

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _client.post(
      ApiConfig.resetPassword,
      data: {
        'email': email,
        'reset_token': resetToken,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  // ─── Session helpers ───────────────────────────────────────────────────────

  Future<String?> getToken() => _storage.read(key: 'token');

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> getSessionData() async {
    return {
      'user_id': await _storage.read(key: 'user_id') ?? '',
      'nama': await _storage.read(key: 'nama') ?? '',
      'email': await _storage.read(key: 'email') ?? '',
      'role': await _storage.read(key: 'role') ?? '',
      'jabatan': await _storage.read(key: 'jabatan') ?? '',
    };
  }
}
