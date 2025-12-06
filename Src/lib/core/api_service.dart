import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Basic API service wrapper. Handles base configuration for Dio and
/// automatically injects authentication headers when provided.
class ApiService {
  ApiService({Dio? client, String? baseUrl, String? accessToken})
      : _dio = client ?? Dio(),
        _baseUrl = baseUrl ?? _defaultBaseUrl,
        _accessToken = ValueNotifier<String?>(accessToken) {
    _setup();
  }

  static const _defaultBaseUrl = 'https://api.nozie.app/v1';

  final Dio _dio;
  final String _baseUrl;
  final ValueNotifier<String?> _accessToken;

  Dio get client => _dio;

  void setAccessToken(String? token) {
    if (_accessToken.value == token) return;
    _accessToken.value = token;
  }

  void _setup() {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..contentType = 'application/json';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _accessToken.value;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: query, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.patch<T>(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: query, options: options);
  }
}


