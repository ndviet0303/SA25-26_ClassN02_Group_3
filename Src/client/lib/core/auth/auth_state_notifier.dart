import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_api_service.dart';
import 'auth_models.dart';

/// Keys for storing auth data in SharedPreferences
class _StorageKeys {
  static const accessToken = 'auth_access_token';
  static const refreshToken = 'auth_refresh_token';
  static const userId = 'auth_user_id';
}

/// Manages authentication state throughout the app
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier({
    required SharedPreferences sharedPreferences,
    required AuthApiService authApiService,
  })  : _prefs = sharedPreferences,
        _authApi = authApiService,
        super(const AuthState()) {
    _restoreSession();
  }

  final SharedPreferences _prefs;
  final AuthApiService _authApi;

  /// Stream controller to notify listeners of auth state changes
  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateChanges => _authStateController.stream;

  /// Restore session from saved tokens on app startup
  Future<void> _restoreSession() async {
    final accessToken = _prefs.getString(_StorageKeys.accessToken);
    final refreshToken = _prefs.getString(_StorageKeys.refreshToken);
    final userId = _prefs.getString(_StorageKeys.userId);

    if (accessToken == null || refreshToken == null) {
      debugPrint('[AuthStateNotifier] No saved session found');
      return;
    }

    debugPrint('[AuthStateNotifier] Restoring session...');
    state = state.copyWith(isLoading: true);

    try {
      // Validate current token
      final isValid = await _authApi.validateToken(accessToken);

      if (isValid) {
        // Token is valid, restore session
        final tokens = AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: userId,
        );

        // Fetch user info
        final user = await _authApi.getCurrentUser(accessToken);

        state = state.copyWith(
          tokens: tokens,
          user: user,
          isLoading: false,
          clearError: true,
        );
        _authStateController.add(true);
        debugPrint('[AuthStateNotifier] Session restored for user: ${user.username}');
      } else {
        // Try to refresh token
        debugPrint('[AuthStateNotifier] Token expired, attempting refresh...');
        await _refreshTokens(refreshToken);
      }
    } catch (e) {
      debugPrint('[AuthStateNotifier] Failed to restore session: $e');
      await _clearSession();
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login with username and password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = LoginRequest(username: username, password: password);
      final tokens = await _authApi.login(request);

      await _saveTokens(tokens);

      // Fetch user info
      final user = await _authApi.getCurrentUser(tokens.accessToken);

      state = state.copyWith(
        tokens: tokens,
        user: user,
        isLoading: false,
      );
      _authStateController.add(true);
      debugPrint('[AuthStateNotifier] Login successful for: ${user.username}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Register a new user (does not auto-login)
  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? phone,
    String? country,
    String? dateOfBirth,
    String? gender,
    String? age,
    List<String>? genres,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        country: country,
        dateOfBirth: dateOfBirth,
        gender: gender,
        age: age,
        genres: genres,
        avatarUrl: avatarUrl,
      );

      await _authApi.register(request);
      state = state.copyWith(isLoading: false);
      debugPrint('[AuthStateNotifier] Registration successful for: $username');

      // Auto-login after registration
      await login(username: username, password: password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Logout current session
  Future<void> logout() async {
    final tokens = state.tokens;
    if (tokens != null) {
      await _authApi.logout(
        LogoutRequest(refreshToken: tokens.refreshToken),
        tokens.accessToken,
      );
    }

    await _clearSession();
    state = const AuthState();
    _authStateController.add(false);
    debugPrint('[AuthStateNotifier] Logged out');
  }

  /// Logout from all devices
  Future<void> logoutAll() async {
    final tokens = state.tokens;
    if (tokens != null) {
      await _authApi.logoutAll(tokens.accessToken);
    }

    await _clearSession();
    state = const AuthState();
    _authStateController.add(false);
    debugPrint('[AuthStateNotifier] Logged out from all devices');
  }

  /// Refresh tokens
  Future<void> refreshTokens() async {
    final currentRefreshToken = state.tokens?.refreshToken;
    if (currentRefreshToken == null) {
      throw Exception('No refresh token available');
    }

    await _refreshTokens(currentRefreshToken);
  }

  Future<void> _refreshTokens(String refreshToken) async {
    try {
      final request = RefreshRequest(refreshToken: refreshToken);
      final newTokens = await _authApi.refreshToken(request);

      await _saveTokens(newTokens);

      // Fetch user info with new token
      final user = await _authApi.getCurrentUser(newTokens.accessToken);

      state = state.copyWith(
        tokens: newTokens,
        user: user,
        isLoading: false,
        clearError: true,
      );
      _authStateController.add(true);
      debugPrint('[AuthStateNotifier] Tokens refreshed successfully');
    } catch (e) {
      debugPrint('[AuthStateNotifier] Token refresh failed: $e');
      // Clear session on refresh failure
      await _clearSession();
      state = const AuthState();
      _authStateController.add(false);
      rethrow;
    }
  }

  /// Update user profile locally (after fetching from API)
  void updateUser(AuthUser user) {
    state = state.copyWith(user: user);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> _saveTokens(AuthTokens tokens) async {
    await _prefs.setString(_StorageKeys.accessToken, tokens.accessToken);
    await _prefs.setString(_StorageKeys.refreshToken, tokens.refreshToken);
    if (tokens.userId != null) {
      await _prefs.setString(_StorageKeys.userId, tokens.userId!);
    }
  }

  Future<void> _clearSession() async {
    await _prefs.remove(_StorageKeys.accessToken);
    await _prefs.remove(_StorageKeys.refreshToken);
    await _prefs.remove(_StorageKeys.userId);
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
