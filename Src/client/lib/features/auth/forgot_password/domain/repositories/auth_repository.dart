abstract class AuthRepository {
  Future<void> resendOtp({required String email});
  Future<String> verifyOtp({required String email, required String code});
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });
}
