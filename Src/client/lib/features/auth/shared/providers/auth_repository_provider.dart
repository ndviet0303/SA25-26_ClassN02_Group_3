import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/auth/auth_providers.dart';
import 'package:movie_fe/features/auth/register/domain/repositories/auth_repository.dart';
import 'package:movie_fe/features/auth/register/domain/repositories/api_auth_repository.dart';

/// Provides the AuthRepository implementation for the app.
/// Uses ApiAuthRepository which connects to the Identity Service microservice.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authNotifier = ref.watch(authStateNotifierProvider.notifier);
  return ApiAuthRepository(authStateNotifier: authNotifier);
});
