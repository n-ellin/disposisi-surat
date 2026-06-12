import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static const baseUrl = 'http://118.99.86.222:8080';
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(_AuthInterceptor());

  /// POST helper — dipakai misal konfirmasi penerimaan surat
  Future<dynamic> post(
    String path, {
    Map<dynamic, dynamic> data = const {},
  }) async {
    final res = await ApiClient.dio.post(path, data: data);
    return res.data;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await TokenStorage.deleteToken();
    }
    handler.next(err);
  }
}

String parseError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'Koneksi timeout. Periksa jaringan kamu.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server.';
    case DioExceptionType.badResponse:
      final msg = e.response?.data?['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      final status = e.response?.statusCode;
      if (status == 401) return 'Sesi habis. Silakan login ulang.';
      if (status == 403) return 'Akses ditolak.';
      if (status == 404) return 'Data tidak ditemukan.';
      if (status == 500) return 'Terjadi kesalahan di server.';
      return 'Request gagal (status $status).';
    case DioExceptionType.cancel:
      return 'Request dibatalkan.';
    default:
      return 'Terjadi kesalahan. Coba lagi.';
  }
}
