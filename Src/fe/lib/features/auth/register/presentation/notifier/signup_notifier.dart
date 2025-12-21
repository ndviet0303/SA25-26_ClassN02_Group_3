import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/common/ui_state.dart';
import 'package:movie_fe/features/auth/shared/providers/auth_repository_provider.dart';
import 'package:movie_fe/features/auth/shared/providers/firebase_auth_provider.dart';
import 'package:movie_fe/features/auth/shared/providers/storage_service_provider.dart';
import 'package:movie_fe/features/auth/shared/services/storage_service.dart';
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
  }) async {
    try {
      state = const Loading<UserReg>();

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

      // Upload avatar before creating user (if avatar exists)
      String? avatarUrl;
      final avatarPath = profileData['avatarPath'];
      if (avatarPath != null && avatarPath.isNotEmpty) {
        try {
          final avatarFile = File(avatarPath);
          if (await avatarFile.exists()) {
            debugPrint('[SignupNotifier] Uploading avatar before user creation');
            // Upload to temp location, will move to user location after user creation
            final storageService = _ref.read(storageServiceProvider);
            // Create temporary ID for signup
            final tempId = DateTime.now().millisecondsSinceEpoch.toString();
            avatarUrl = await storageService.uploadAvatarForSignup(
              avatarFile,
              tempId,
            );
            debugPrint('[SignupNotifier] Avatar uploaded: $avatarUrl');
          }
        } catch (error) {
          debugPrint('[SignupNotifier] Failed to upload avatar: $error');
          // Continue without avatar if upload fails
        }
      }

      final userRegistration = UserReg(
        gender: gender,
        age: age,
        genres: genres,
        profile: userProfile,
        account: userAccount,
      );

      // Pass avatarUrl to repository
      await _repository.register(
        userRegistration,
        avatarUrl: avatarUrl,
      );

      await _syncUserProfile();

      state = Success<UserReg>(userRegistration);
      return state;
    } catch (error) {
      state = Error<UserReg>(error.toString());
      return state;
    }
  }

  Future<void> signInWithGoogle() async {
    await _repository.signInWithGoogle();
    await _syncUserProfile();
  }

  Future<void> _syncUserProfile() async {
    try {
      final auth = _ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data() ?? <String, dynamic>{};
      debugPrint('[Auth] Firestore user data fetched after signup: $data');

      final profile = profile_models.UserProfile(
        id: user.uid,
        fullName: (data['displayName'] ?? data['fullName'] ??
                user.displayName ?? '')
            .toString(),
        username: (data['username'] ?? '').toString(),
        email: (data['email'] ?? user.email ?? '').toString(),
        phone: (data['phone'] ?? '').toString(),
        dateOfBirth: (data['dateOfBirth'] ?? '').toString(),
        country: (data['country'] ?? '').toString(),
        avatarUrl: (data['avatarUrl'] ?? user.photoURL ?? '').toString(),
      );

      final settingsRepository = _ref.read(settingsRepositoryProvider);
      await settingsRepository.updateProfile(profile);
      _ref.read(profileNotifierProvider.notifier).setProfile(profile);
    } catch (error) {
      debugPrint('Failed to sync user profile after signup: $error');
    }
  }
}


