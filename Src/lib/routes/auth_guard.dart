import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AuthGuard {
  AuthGuard({
    FirebaseAuth? auth,
    Set<String>? publicPaths,
    Set<String>? authRedirectWhitelist,
  })  : _auth = auth ?? FirebaseAuth.instance,
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

  final FirebaseAuth _auth;
  final Set<String> _publicPaths;
  final Set<String> _authRedirectWhitelist;

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final user = _auth.currentUser;
    final isLoggedIn = user != null;
    final location = _normalize(state.matchedLocation);

    if (!isLoggedIn && !_publicPaths.contains(location)) {
      return '/sign-in';
    }

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

