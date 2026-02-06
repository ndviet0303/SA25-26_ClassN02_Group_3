import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_prefs_provider.dart';
import '../repositories/auth_repository.dart';
import 'auth_models.dart';
import 'auth_state_notifier.dart';

/// Provider for the Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for the Auth State Notifier
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(
    sharedPreferences: prefs,
    authRepository: authRepo,
  );
});

/// Convenience provider for checking if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateNotifierProvider).isLoggedIn;
});

/// Convenience provider for getting current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateNotifierProvider).currentUserId;
});

/// Convenience provider for getting access token
final accessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authStateNotifierProvider).accessToken;
});

/// Convenience provider for getting current auth user
final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateNotifierProvider).user;
});

/// Provider for auth state changes stream (for router)
final authStateChangesProvider = StreamProvider<bool>((ref) {
  final notifier = ref.watch(authStateNotifierProvider.notifier);
  return notifier.authStateChanges;
});
