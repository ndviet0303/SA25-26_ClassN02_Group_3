import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_fe/core/auth/auth_models.dart';

class AuthGuard {
  /// Auth route guard.
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

    // Redirect to sign-in if not logged in and accessing protected page
    if (!isLoggedIn && !_publicPaths.contains(location)) {
      return '/sign-in';
    }

    // Redirect logged in user away from auth pages
    if (isLoggedIn && _authRedirectWhitelist.contains(location)) {
      return '/home';
    }

    return null;
  }

  // Normalize URI path
  String _normalize(String location) {
    if (location.isEmpty) return '/';
    final uri = Uri.parse(location);
    final path = uri.path;
    return path.isEmpty ? '/' : path;
  }
}
