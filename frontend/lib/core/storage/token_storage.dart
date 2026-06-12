import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TokenStorage — auto-switch antara SecureStorage (mobile) dan SharedPrefs (web)
class TokenStorage {
  static const _key = 'auth_token';
  static const _secure = FlutterSecureStorage();

  // ── SIMPAN TOKEN ──────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, token);
      } else {
        await _secure.write(key: _key, value: token);
      }
    } catch (e) {
      throw Exception('Gagal menyimpan token: $e');
    }
  }

  // ── HAPUS TOKEN (logout) ──────────────────────────────────
  static Future<void> deleteToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_key);
      } else {
        await _secure.delete(key: _key);
      }
    } catch (e) {
      throw Exception('Gagal menghapus token: $e');
    }
  }

  // ── CEK SUDAH LOGIN? ──────────────────────────────────────
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── HAPUS SEMUA (reset total) ─────────────────────────────
  static Future<void> clearAll() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } else {
        await _secure.deleteAll();
      }
    } catch (e) {
      throw Exception('Gagal clear storage: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_key);

        print('WEB TOKEN = $token');

        return token;
      } else {
        final token = await _secure.read(key: _key);

        print('MOBILE TOKEN = $token');

        return token;
      }
    } catch (e) {
      throw Exception('Gagal mengambil token: $e');
    }
  }

  static Future<void> saveRefreshToken(String refreshToken) async {}
}
