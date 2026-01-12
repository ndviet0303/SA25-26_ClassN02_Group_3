import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/features/auth/register/domain/repositories/auth_repository.dart';
import 'package:movie_fe/features/auth/register/domain/repositories/firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});


