import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/preferences.dart';
import '../repository/settings_repository.dart';

class PreferencesNotifier extends StateNotifier<AsyncValue<Preferences>> {
  PreferencesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      final data = await _repository.fetchPreferences();
      state = AsyncValue.data(data);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> update(Preferences preferences) async {
    state = AsyncValue.data(preferences);
    try {
      await _repository.updatePreferences(preferences);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateFields({
    bool? wifiOnlyDownloads,
    bool? autoPlayNextEpisode,
    bool? continueWatching,
    bool? subtitlesEnabled,
    bool? autoRotateScreen,
    bool? autoDownloadAudio,
    String? videoQuality,
    String? audioPreference,
    double? cacheSizeMb,
  }) async {
    final current = state.value ?? Preferences.defaults;
    final updated = current.copyWith(
      wifiOnlyDownloads: wifiOnlyDownloads,
      autoPlayNextEpisode: autoPlayNextEpisode,
      continueWatching: continueWatching,
      subtitlesEnabled: subtitlesEnabled,
      autoRotateScreen: autoRotateScreen,
      autoDownloadAudio: autoDownloadAudio,
      videoQuality: videoQuality,
      audioPreference: audioPreference,
      cacheSizeMb: cacheSizeMb,
    );
    await update(updated);
  }
}

final preferencesNotifierProvider =
    StateNotifierProvider<PreferencesNotifier, AsyncValue<Preferences>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return PreferencesNotifier(repository);
});


