import '../../core/constants/api_config.dart';
import '../../core/network/dio_client.dart';

class DashboardRepository {
  final _client = DioClient();

  /// Ambil statistik dashboard.
  /// Response berisi count surat masuk/keluar by status, dll.
  Future<Map<String, dynamic>> getStats() async {
    final res = await _client.get(ApiConfig.dashboard);
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    return res;
  }
}
