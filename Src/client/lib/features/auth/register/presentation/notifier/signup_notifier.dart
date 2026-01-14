import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:movie_fe/features/auth/shared/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/auth/auth_providers.dart';
import 'package:movie_fe/core/common/ui_state.dart';
import 'package:movie_fe/features/auth/shared/providers/auth_repository_provider.dart';
import 'package:movie_fe/features/auth/register/domain/models/user_registration.dart';
import 'package:movie_fe/features/auth/register/domain/repositories/auth_repository.dart';
import 'package:movie_fe/features/profile/models/user_profile.dart'
    as profile_models;
import 'package:movie_fe/features/profile/notifiers/profile_notifier.dart';
import 'package:movie_fe/features/profile/repository/settings_repository.dart';

final signupNotifierProvider =
    StateNotifierProvider<SignupNotifier, UIState<UserReg>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupNotifier(ref, repository);
});

class SignupNotifier extends StateNotifier<UIState<UserReg>> {
  SignupNotifier(this._ref, this._repository) : super(const Idle<UserReg>());

  final Ref _ref;
  final AuthRepository _repository;

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

      // Register user via microservice API
      await _repository.register(userRegistration, avatarUrl: avatarUrl);

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

      final profile = profile_models.UserProfile(
        id: authUser.id,
        fullName: authUser.fullName ?? '',
        username: authUser.username,
        email: authUser.email,
        phone: authUser.phone ?? '',
        dateOfBirth: authUser.dateOfBirth ?? '',
        country: authUser.country ?? '',
        avatarUrl: authUser.avatarUrl ?? '',
      );

      final settingsRepository = _ref.read(settingsRepositoryProvider);
      await settingsRepository.updateProfile(profile);
      _ref.read(profileNotifierProvider.notifier).setProfile(profile);
      debugPrint('[SignupNotifier] User profile synced successfully');
    } catch (error) {
      debugPrint('[SignupNotifier] Failed to sync user profile: $error');
    }
  }
}
