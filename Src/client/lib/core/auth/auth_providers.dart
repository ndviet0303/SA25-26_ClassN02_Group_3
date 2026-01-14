import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_prefs_provider.dart';
import 'auth_api_service.dart';
import 'auth_models.dart';
import 'auth_state_notifier.dart';

/// Provider for the Auth API Service
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService();
});

/// Provider for the Auth State Notifier
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final authApi = ref.watch(authApiServiceProvider);
  return AuthStateNotifier(
    sharedPreferences: prefs,
    authApiService: authApi,
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
