import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/auth/auth_providers.dart';
import '../../../../../core/common/ui_state.dart';
import '../../../../profile/notifiers/profile_notifier.dart';

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, UIState<bool>>((ref) {
  return LoginNotifier(ref);
});

class LoginNotifier extends StateNotifier<UIState<bool>> {
  LoginNotifier(this._ref) : super(const Idle<bool>());

  final Ref _ref;

  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const Loading<bool>();
      
      // 1. Use central AuthStateNotifier for login to handle global state and token persistence
      await _ref.read(authStateNotifierProvider.notifier).login(
            username: email,
            password: password,
          );
          
      // 2. Sync user profile state
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

      // Invalidate the profile notifier to force it to refetch data from the server
      // using the newly acquired access token.
      _ref.invalidate(profileNotifierProvider);
      
      debugPrint('[LoginNotifier] User profile refreshed successfully');
    } catch (error) {
      debugPrint('[LoginNotifier] Failed to sync user profile: $error');
    }
  }
}
