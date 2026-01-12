import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/common/ui_state.dart';
import '../../../../profile/models/user_profile.dart' as profile_models;
import '../../../../profile/notifiers/profile_notifier.dart';
import '../../../../profile/repository/settings_repository.dart';
import '../../../shared/providers/auth_repository_provider.dart';
import '../../../shared/providers/firebase_auth_provider.dart';
import '../../../register/domain/repositories/auth_repository.dart';

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, UIState<bool>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginNotifier(ref, repository);
});

class LoginNotifier extends StateNotifier<UIState<bool>> {
  LoginNotifier(this._ref, this._repository) : super(const Idle<bool>());

  final Ref _ref;
  final AuthRepository _repository;

  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const Loading<bool>();
      await _repository.signIn(email: email, password: password);
      await _syncUserProfile();
      state = const Success<bool>(true);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      state = Error<bool>(message);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const Loading<bool>();
      await _repository.signInWithGoogle();
      await _syncUserProfile();
      state = const Success<bool>(true);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      state = Error<bool>(message);
    }
  }

  void reset() {
    state = const Idle<bool>();
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
      debugPrint('[Auth] Firestore user data fetched: $data');

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
      debugPrint('Failed to sync user profile: $error');
    }
  }
}


