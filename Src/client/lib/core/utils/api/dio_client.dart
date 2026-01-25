import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

class DioClient {
  DioClient._();

  // Base URL for API Gateway (microservices)
  static String get _kBaseUrl => ApiConfig.baseUrl;

  static late final Dio _dio;
  static bool _inited = false;
  static String? _token;

  /// Gọi 1 lần trong main()
  static void init({
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 30),
    Map<String, dynamic>? defaultHeaders,
    bool enableLogger = kDebugMode,
  }) {
    if (_inited) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: _kBaseUrl, // 👈 dùng base URL cứng
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          ...?defaultHeaders,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opts, handler) {
          if (_token != null && _token!.isNotEmpty) {
            opts.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(opts);
        },
      ),
    );

    if (enableLogger) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }

    _inited = true;
  }

  static void setToken(String? token) => _token = token;
  static void clearToken() => _token = null;

  static Dio get raw => _dio;

  // Helpers (tuỳ thích dùng)
  static Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) =>
      _dio.get<T>(path, queryParameters: query);

  static Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? query}) =>
      _dio.post<T>(path, data: data, queryParameters: query);

  static Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? query}) =>
      _dio.put<T>(path, data: data, queryParameters: query);

  static Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? query}) =>
      _dio.delete<T>(path, data: data, queryParameters: query);
}
