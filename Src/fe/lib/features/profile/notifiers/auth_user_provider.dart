import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import 'profile_notifier.dart';

final authUserProvider = Provider<AsyncValue<UserProfile>>((ref) {
  return ref.watch(profileNotifierProvider);
});


