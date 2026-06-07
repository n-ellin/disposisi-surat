import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveAuth(String token, String refreshToken, Map<String, dynamic> user) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user', value: jsonEncode(user));
  }
  
  static Future<String?> getToken() => _storage.read(key: 'token');
  static Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');
  
  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }
  
  static Future<void> clear() => _storage.deleteAll();
  static Future<bool> isLoggedIn() async => (await getToken()) != null;
}