import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_settings.dart';
import '../repository/settings_repository.dart';

class NotificationNotifier extends StateNotifier<AsyncValue<NotificationSettings>> {
  NotificationNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      final settings = await _repository.fetchNotificationSettings();
      state = AsyncValue.data(settings);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> toggle({
    bool? newRecommendation,
    bool? newBookSeries,
    bool? authorUpdates,
    bool? priceDrops,
    bool? purchase,
    bool? appSystem,
    bool? tipsServices,
    bool? survey,
  }) async {
    final current = state.value ?? NotificationSettings.defaults;
    final updated = current.copyWith(
      newRecommendation: newRecommendation,
      newBookSeries: newBookSeries,
      authorUpdates: authorUpdates,
      priceDrops: priceDrops,
      purchase: purchase,
      appSystem: appSystem,
      tipsServices: tipsServices,
      survey: survey,
    );
    state = AsyncValue.data(updated);
    try {
      await _repository.updateNotificationSettings(updated);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<NotificationSettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return NotificationNotifier(repository);
});


