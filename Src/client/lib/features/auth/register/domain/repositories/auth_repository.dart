import '../models/user_registration.dart';

/// Repository interface for authentication operations.
/// This interface is implemented by ApiAuthRepository for microservice-based auth.
abstract class AuthRepository {
  /// Register a new user with the provided registration data
  Future<void> register(
    UserReg userRegistration, {
    String? avatarUrl,
  });

  /// Sign in with email/username and password
  Future<void> signIn({required String email, required String password});

  /// Sign out the current user
  Future<void> signOut();

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? country,
    String? dateOfBirth,
    String? gender,
    String? age,
    List<String>? genres,
    String? avatarUrl,
  });
}
