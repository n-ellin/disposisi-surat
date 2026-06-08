import '../../core/constants/api_config.dart';
import '../../core/network/dio_client.dart';

class UserRepository {
  final _client = DioClient();

  /// List semua user (untuk keperluan admin/TU).
  Future<List<Map<String, dynamic>>> getUsers() async {
    final res = await _client.get(ApiConfig.users);
    return _parseList(res);
  }

  /// List target disposisi — dipakai untuk:
  /// - TU pilih Waka penerima surat masuk
  /// - Waka pilih guru/user penerima
  ///
  /// [role] : filter 'waka' untuk TU, 'user' untuk Waka (tergantung BE support)
  Future<List<Map<String, dynamic>>> getDisposisiTargets({String? role}) async {
    final query = <String, dynamic>{};
    if (role != null) query['role'] = role;

    final res = await _client.get(
      ApiConfig.disposisiTargets,
      query: query.isNotEmpty ? query : null,
    );
    return _parseList(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> _parseList(Map<String, dynamic> res) {
    final data = res['data'];
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
