import 'package:dio/dio.dart';
import 'package:movie_fe/features/auth/forgot_password/domain/repositories/auth_repository.dart' as domain;

class ForgotPasswordRepositoryImpl implements domain.AuthRepository {
  ForgotPasswordRepositoryImpl({Dio? client, String? baseUrl})
      : _dio = client ?? Dio(BaseOptions(baseUrl: baseUrl ?? 'http://localhost:3000'));

  final Dio _dio;

  @override
  Future<void> resendOtp({required String email}) async {
    await _dio.post('/auth/forgot-password/send-otp', data: { 'email': email });
  }

  @override
  Future<String> verifyOtp({required String email, required String code}) async {
    final res = await _dio.post('/auth/forgot-password/verify-otp', data: {
      'email': email,
      'code': code,
    });
    final data = res.data as Map;
    final token = data['resetToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Missing reset token');
    }
    return token;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    await _dio.post('/auth/forgot-password/reset', data: {
      'email': email,
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
  }
}


