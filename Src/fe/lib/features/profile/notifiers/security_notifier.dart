import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/security_settings.dart';
import '../repository/settings_repository.dart';

class SecurityNotifier extends StateNotifier<AsyncValue<SecuritySettings>> {
  SecurityNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      final settings = await _repository.fetchSecuritySettings();
      state = AsyncValue.data(settings);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> update(SecuritySettings settings) async {
    state = AsyncValue.data(settings);
    try {
      await _repository.updateSecuritySettings(settings);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> toggle({
    bool? rememberMe,
    bool? biometricId,
    bool? faceId,
    bool? smsAuthenticator,
    bool? googleAuthenticator,
  }) async {
    final current = state.value ?? SecuritySettings.defaults;
    final updated = current.copyWith(
      rememberMe: rememberMe,
      biometricId: biometricId,
      faceId: faceId,
      smsAuthenticator: smsAuthenticator,
      googleAuthenticator: googleAuthenticator,
    );
    await update(updated);
  }

  Future<void> signOutDevice(String id) async {
    try {
      final result = await _repository.signOutDevice(id);
      state = AsyncValue.data(result);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> signOutAllDevices() async {
    try {
      final result = await _repository.signOutAllDevices();
      state = AsyncValue.data(result);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final securityNotifierProvider =
    StateNotifierProvider<SecurityNotifier, AsyncValue<SecuritySettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SecurityNotifier(repository);
});


