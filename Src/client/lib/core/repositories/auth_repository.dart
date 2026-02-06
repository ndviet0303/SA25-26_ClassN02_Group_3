import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../auth/auth_models.dart';

/// Authentication Repository - REST API based
/// API: AuthController and AdminController endpoints
class AuthRepository {
  AuthRepository({Dio? dio})
      : _dio = dio ?? Dio() {
    _setup();
  }

  final Dio _dio;

  void _setup() {
    _dio.options
      ..baseUrl = ApiConfig.baseUrl
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
      if (data == null) throw Exception('No response data');

      if (data['success'] == true && data['data'] != null) {
        return AuthTokens.fromJson(data['data'] as Map<String, dynamic>);
      }
      
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
      if (data == null) throw Exception('No response data');

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
      if (data == null) throw Exception('No response data');

      if (data['success'] == true && data['data'] != null) {
        return AuthUser.fromJson(data['data'] as Map<String, dynamic>);
      }

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
      if (data == null) throw Exception('No response data');

      if (data['success'] == true && data['data'] != null) {
        return AuthTokens.fromJson(data['data'] as Map<String, dynamic>);
      }

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
      if (data == null) throw Exception('No response data');

      if (data['success'] == true && data['data'] != null) {
        return AuthUser.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw Exception(data['message'] ?? 'Profile update failed');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update user email
  /// PUT /api/auth/email
  Future<void> updateEmail(String email, String accessToken) async {
    try {
      await _dio.put(
        '/api/auth/email',
        data: {'email': email},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ========== New Methods ==========

  /// Check username availability
  /// GET /api/auth/check-username
  Future<bool> checkUsername(String username) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/auth/check-username',
        queryParameters: {'username': username},
      );
      final data = response.data;
      return data?['data']?['available'] ?? data?['available'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check email availability
  /// GET /api/auth/check-email
  Future<bool> checkEmail(String email) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/auth/check-email',
        queryParameters: {'email': email},
      );
      final data = response.data;
      return data?['data']?['available'] ?? data?['available'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Delete account
  /// DELETE /api/auth/account
  Future<void> deleteAccount(String accessToken) async {
    try {
      await _dio.delete(
        '/api/auth/account',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout other sessions
  /// DELETE /api/auth/sessions/others
  Future<void> logoutOthers(String accessToken) async {
    try {
      await _dio.delete(
        '/api/auth/sessions/others',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Forgot password
  /// POST /api/auth/forgot-password
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Reset password
  /// POST /api/auth/reset-password
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post(
        '/api/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get active sessions
  /// GET /api/auth/sessions
  Future<List<Map<String, dynamic>>> getSessions(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/auth/sessions',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      final List<dynamic> data = response.data?['data'] ?? response.data ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Revoke a specific session
  /// DELETE /api/auth/sessions/{id}
  Future<void> revokeSession(String sessionId, String accessToken) async {
    try {
      await _dio.delete(
        '/api/auth/sessions/$sessionId',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
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
        if (message != null) return Exception(message.toString());
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return Exception('Unable to connect to server.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred');
    }
  }
}
