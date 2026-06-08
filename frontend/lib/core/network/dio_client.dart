import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_config.dart';
import 'api_exception.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await _storage.deleteAll();
          // TODO: redirect ke login jika perlu
        }
        return handler.next(e);
      },
    ));
  }

  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  // ─── Core methods ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return _parse(res);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final res = await _dio.post(path, data: data);
      return _parse(res);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    try {
      final res = await _dio.put(path, data: data);
      return _parse(res);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final res = await _dio.delete(path);
      return _parse(res);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Untuk upload multipart/form-data (surat masuk/keluar dengan file PDF).
  Future<Map<String, dynamic>> postForm(
    String path, {
    required FormData formData,
  }) async {
    try {
      final res = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _parse(res);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> putForm(
    String path, {
    required FormData formData,
  }) async {
    try {
      final res = await _dio.put(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _parse(res);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _parse(Response res) {
    final body = res.data;
    if (body is Map<String, dynamic>) return body;
    return {'data': body};
  }

  ApiException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    String message = 'Terjadi kesalahan.';

    if (body is Map<String, dynamic>) {
      message = body['message']?.toString() ??
          body['error']?.toString() ??
          message;
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiException(message: 'Koneksi timeout. Periksa jaringan.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(message: 'Tidak dapat terhubung ke server.');
    }

    return ApiException(statusCode: statusCode, message: message);
  }
}
