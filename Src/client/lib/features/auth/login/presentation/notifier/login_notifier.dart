import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/auth/auth_providers.dart';
import '../../../../../core/common/ui_state.dart';
import '../../../../profile/models/user_profile.dart' as profile_models;
import '../../../../profile/notifiers/profile_notifier.dart';
import '../../../../profile/repository/settings_repository.dart';
import '../../../shared/providers/auth_repository_provider.dart';
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

  void reset() {
    state = const Idle<bool>();
  }

  /// Sync user profile from auth state to profile notifier
  Future<void> _syncUserProfile() async {
    try {
      final authState = _ref.read(authStateNotifierProvider);
      final authUser = authState.user;
      if (authUser == null) {
        debugPrint('[LoginNotifier] No auth user found to sync');
        return;
      }

      debugPrint('[LoginNotifier] Syncing user profile from auth: ${authUser.username}');

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
      debugPrint('[LoginNotifier] User profile synced successfully');
    } catch (error) {
      debugPrint('[LoginNotifier] Failed to sync user profile: $error');
    }
  }
}
