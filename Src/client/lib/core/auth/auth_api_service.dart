import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

import 'auth_models.dart';

/// Service for making API calls to the Identity Service
class AuthApiService {
  AuthApiService({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? _defaultBaseUrl {
    _setup();
  }

  static String get _defaultBaseUrl => ApiConfig.baseUrl;

  final Dio _dio;
  final String _baseUrl;

  void _setup() {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 30)
      ..contentType = 'application/json';

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  /// Login with username and password
  /// POST /api/auth/login
  Future<AuthTokens> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('No response data');
      }

      // Handle wrapped response {success: true, data: {...}}
      if (data['success'] == true && data['data'] != null) {
        return AuthTokens.fromJson(data['data'] as Map<String, dynamic>);
      }

      // Handle direct token response
      if (data['accessToken'] != null) {
        return AuthTokens.fromJson(data);
      }

      throw Exception(data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register a new user
  /// POST /api/auth/register
  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/register',
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('No response data');
      }

      if (data['success'] == false) {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get current authenticated user
  /// GET /api/auth/me
  Future<AuthUser> getCurrentUser(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('No response data');
      }

      // Handle wrapped response
      if (data['success'] == true && data['data'] != null) {
        return AuthUser.fromJson(data['data'] as Map<String, dynamic>);
      }

      // Handle direct user response
      if (data['id'] != null || data['userId'] != null) {
        return AuthUser.fromJson(data);
      }

      throw Exception(data['message'] ?? 'Failed to get user');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Validate current token
  /// GET /api/auth/validate
  Future<bool> validateToken(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/auth/validate',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = response.data;
      return data?['success'] == true || data?['valid'] == true;
    } on DioException {
      return false;
    }
  }

  /// Refresh access token
  /// POST /api/auth/refresh
  Future<AuthTokens> refreshToken(RefreshRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('No response data');
      }

      // Handle wrapped response
      if (data['success'] == true && data['data'] != null) {
        return AuthTokens.fromJson(data['data'] as Map<String, dynamic>);
      }

      // Handle direct token response
      if (data['accessToken'] != null) {
        return AuthTokens.fromJson(data);
      }

      throw Exception(data['message'] ?? 'Token refresh failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout current session
  /// POST /api/auth/logout
  Future<void> logout(LogoutRequest request, String accessToken) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/auth/logout',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      // Ignore logout errors - user should still be logged out locally
      debugPrint('Logout API error: ${e.message}');
    }
  }

  /// Logout from all sessions
  /// POST /api/auth/logout-all
  Future<void> logoutAll(String accessToken) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/auth/logout-all',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      debugPrint('Logout all API error: ${e.message}');
    }
  }

  /// Update user profile
  /// PUT /api/auth/profile
  Future<AuthUser> updateProfile(UpdateProfileRequest request, String accessToken) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/api/auth/profile',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('No response data');
      }

      // Handle wrapped response
      if (data['success'] == true && data['data'] != null) {
        return AuthUser.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception(data['message'] ?? 'Profile update failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    final response = e.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'];
        if (message != null) {
          return Exception(message.toString());
        }
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return Exception('Unable to connect to server. Check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Invalid credentials');
        } else if (statusCode == 403) {
          return Exception('Access denied');
        } else if (statusCode == 404) {
          return Exception('Service not found');
        } else if (statusCode == 409) {
          return Exception('User already exists');
        }
        return Exception('Server error ($statusCode)');
      default:
        return Exception(e.message ?? 'An unexpected error occurred');
    }
  }
}
