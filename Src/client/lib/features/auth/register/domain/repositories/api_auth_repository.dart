import 'package:flutter/foundation.dart';
import 'package:movie_fe/core/auth/auth.dart';

import '../models/user_registration.dart';
import 'auth_repository.dart';

/// Implementation of AuthRepository using microservice API
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required AuthStateNotifier authStateNotifier,
  }) : _authNotifier = authStateNotifier;

  final AuthStateNotifier _authNotifier;

  @override
  Future<void> register(
    UserReg userRegistration, {
    String? avatarUrl,
  }) async {
    try {
      final account = userRegistration.account;
      final profile = userRegistration.profile;

      await _authNotifier.register(
        username: account.username.trim(),
        email: account.email.trim(),
        password: account.password,
        fullName: profile.fullName.trim(),
        phone: profile.phone.trim(),
        country: profile.country.trim(),
        dateOfBirth: profile.dateOfBirth.trim(),
        gender: userRegistration.gender,
        age: userRegistration.age,
        genres: userRegistration.genres,
        avatarUrl: avatarUrl,
      );

      debugPrint('[ApiAuthRepository] Registration successful for: ${account.username}');
    } catch (e) {
      debugPrint('[ApiAuthRepository] Registration failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      // The API uses 'username' but we accept 'email' for backward compatibility
      // Users can login with either username or email
      await _authNotifier.login(
        username: email.trim(),
        password: password,
      );

      debugPrint('[ApiAuthRepository] Sign in successful');
    } catch (e) {
      debugPrint('[ApiAuthRepository] Sign in failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authNotifier.logout();
      debugPrint('[ApiAuthRepository] Sign out successful');
    } catch (e) {
      debugPrint('[ApiAuthRepository] Sign out failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? country,
    String? dateOfBirth,
    String? gender,
    String? age,
    List<String>? genres,
    String? avatarUrl,
  }) async {
    try {
      await _authNotifier.updateProfile(
        fullName: fullName,
        phone: phone,
        country: country,
        dateOfBirth: dateOfBirth,
        gender: gender,
        age: age,
        genres: genres,
        avatarUrl: avatarUrl,
      );
      debugPrint('[ApiAuthRepository] Profile update successful');
    } catch (e) {
      debugPrint('[ApiAuthRepository] Profile update failed: $e');
      rethrow;
    }
  }
}
