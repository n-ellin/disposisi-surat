import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();
  
  // 🔥 GANTI INI KE URL SERVER LIVE
  static const String baseUrl = 'http://118.99.86.222:8080/api';
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Auto attach JWT token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.deleteAll();
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
  
  Future<Response> get(String path, {Map<String, dynamic>? query}) => 
      _dio.get(path, queryParameters: query);
      
  Future<Response> post(String path, {dynamic data}) => 
      _dio.post(path, data: data);
      
  Future<Response> put(String path, {dynamic data}) => 
      _dio.put(path, data: data);
      
  Future<Response> delete(String path) => 
      _dio.delete(path);
}