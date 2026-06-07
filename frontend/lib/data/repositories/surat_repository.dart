import '../../core/api/api_client.dart';

class SuratRepository {
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> _parseListResponse(
    dynamic body,
    String fallbackMessage,
  ) {
    if (body is! Map<String, dynamic>) {
      throw Exception(fallbackMessage);
    }
    if (body['success'] != true) {
      throw Exception(body['message'] ?? fallbackMessage);
    }
    final data = body['data'];
    if (data == null) return Future.value([]);
    if (data is! List) throw Exception('Format data tidak valid');
    return Future.value(
      data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getSuratMasukList({
    Map<String, dynamic>? query,
  }) async {
    final response = await _api.get('/surat-masuk', query: query);
    return _parseListResponse(
      response.data,
      'Gagal mengambil surat masuk',
    );
  }

  Future<List<Map<String, dynamic>>> getSuratKeluarList({
    Map<String, dynamic>? query,
  }) async {
    final response = await _api.get('/surat-keluar', query: query);
    return _parseListResponse(
      response.data,
      'Gagal mengambil surat keluar',
    );
  }

  Future<List<Map<String, dynamic>>> getSuratMasukHistory({
    Map<String, dynamic>? query,
  }) async {
    final response = await _api.get('/surat-masuk/history', query: query);
    return _parseListResponse(
      response.data,
      'Gagal mengambil riwayat surat masuk',
    );
  }

  Future<List<Map<String, dynamic>>> getSuratKeluarHistory({
    Map<String, dynamic>? query,
  }) async {
    final response = await _api.get('/surat-keluar/history', query: query);
    return _parseListResponse(
      response.data,
      'Gagal mengambil riwayat surat keluar',
    );
  }
}