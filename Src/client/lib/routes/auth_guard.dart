import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_models.dart';

/// Guard for protecting routes based on authentication state.
/// Uses token-based auth from AuthStateNotifier instead of Firebase.
class AuthGuard {
  AuthGuard({
    required bool Function() isLoggedIn,
    Set<String>? publicPaths,
    Set<String>? authRedirectWhitelist,
  })  : _isLoggedIn = isLoggedIn,
        _publicPaths = publicPaths ?? const {
          '/',
          '/signup',
          '/sign-in',
          '/forgot-password',
          '/otp-verification',
          '/reset-password',
        },
        _authRedirectWhitelist = authRedirectWhitelist ?? const {
          '/',
          '/sign-in',
          '/signup',
        };

  final bool Function() _isLoggedIn;
  final Set<String> _publicPaths;
  final Set<String> _authRedirectWhitelist;

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _isLoggedIn();
    final location = _normalize(state.matchedLocation);

    // If not logged in and trying to access protected route, redirect to sign-in
    if (!isLoggedIn && !_publicPaths.contains(location)) {
      return '/sign-in';
    }

    // If logged in and on auth pages, redirect to home
    if (isLoggedIn && _authRedirectWhitelist.contains(location)) {
      return '/home';
    }

    return null;
  }

  String _normalize(String location) {
    if (location.isEmpty) return '/';
    final uri = Uri.parse(location);
    final path = uri.path;
    return path.isEmpty ? '/' : path;
  }
}
