import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../repository/settings_repository.dart';
import '../../../core/auth/auth_providers.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      final data = await _repository.fetchProfile();
      state = AsyncValue.data(data);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> refresh() async => _load();

  Future<void> update(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateProfile(profile);
      state = AsyncValue.data(updated);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  void setProfile(UserProfile profile) {
    state = AsyncValue.data(profile);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  // Watch user ID to ensure profile is reloaded on user changes
  ref.watch(currentUserIdProvider);
  
  final repository = ref.watch(settingsRepositoryProvider);
  return ProfileNotifier(repository);
});


