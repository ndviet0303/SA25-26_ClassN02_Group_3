import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:movie_fe/features/auth/shared/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/auth/auth_providers.dart';
import 'package:movie_fe/core/common/ui_state.dart';
import 'package:movie_fe/features/auth/register/domain/models/user_registration.dart';
import 'package:movie_fe/features/profile/notifiers/profile_notifier.dart';

final signupNotifierProvider =
    StateNotifierProvider<SignupNotifier, UIState<UserReg>>((ref) {
  return SignupNotifier(ref);
});

class SignupNotifier extends StateNotifier<UIState<UserReg>> {
  SignupNotifier(this._ref) : super(const Idle<UserReg>());

  final Ref _ref;

  Future<UIState<UserReg>> registerUser({
    String? gender,
    String? age,
    List<String> genres = const [],
    required Map<String, String> profileData,
    required Map<String, dynamic> accountData,
    File? avatarFile,
  }) async {
    try {
      state = const Loading<UserReg>();

      String? avatarUrl;
      if (avatarFile != null) {
        try {
          final storageService = _ref.read(storageServiceProvider);
          avatarUrl = await storageService.uploadToImgBB(avatarFile);
        } catch (e) {
          debugPrint('[SignupNotifier] Avatar upload failed: $e');
          // Continue without avatar or throw error? Let's continue for now
        }
      }

      final userProfile = UserProfile(
        fullName: (profileData['fullName'] ?? '').trim(),
        phone: (profileData['phone'] ?? '').trim(),
        dateOfBirth: (profileData['dob'] ?? '').trim(),
        country: (profileData['country'] ?? '').trim(),
      );

      final userAccount = UserAccount(
        username: (accountData['username'] ?? '').trim(),
        email: (accountData['email'] ?? '').trim(),
        password: (accountData['password'] ?? '').trim(),
        rememberMe: accountData['rememberMe'] ?? false,
      );

      final userRegistration = UserReg(
        gender: gender,
        age: age,
        genres: genres,
        profile: userProfile,
        account: userAccount,
      );

      // Register user via central AuthStateNotifier (handles registration and auto-login)
      await _ref.read(authStateNotifierProvider.notifier).register(
        username: userAccount.username,
        email: userAccount.email,
        password: userAccount.password,
        fullName: userProfile.fullName,
        phone: userProfile.phone,
        dateOfBirth: userProfile.dateOfBirth,
        country: userProfile.country,
        gender: gender,
        age: age,
        genres: genres,
        avatarUrl: avatarUrl,
      );

      // Sync user profile from auth state
      await _syncUserProfile();

      state = Success<UserReg>(userRegistration);
      return state;
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      state = Error<UserReg>(message);
      return state;
    }
  }

  /// Sync user profile from auth state to profile notifier
  Future<void> _syncUserProfile() async {
    try {
      final authState = _ref.read(authStateNotifierProvider);
      final authUser = authState.user;
      if (authUser == null) {
        debugPrint('[SignupNotifier] No auth user found to sync');
        return;
      }

      debugPrint('[SignupNotifier] Syncing user profile from auth: ${authUser.username}');

      // Invalidate the profile notifier to force it to refetch data from the server
      _ref.invalidate(profileNotifierProvider);
      
      debugPrint('[SignupNotifier] User profile refreshed successfully');
    } catch (error) {
      debugPrint('[SignupNotifier] Failed to sync user profile: $error');
    }
  }
}
