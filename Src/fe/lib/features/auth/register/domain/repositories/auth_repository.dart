import '../models/user_registration.dart';

abstract class AuthRepository {
  Future<void> register(
    UserReg userRegistration, {
    String? avatarUrl,
  });
  Future<void> signIn({required String email, required String password});
  Future<void> signInWithGoogle();
}

