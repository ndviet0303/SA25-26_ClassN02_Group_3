import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/locale_setting.dart';
import '../models/language_settings.dart';
import '../repository/settings_repository.dart';

class LanguageNotifier extends StateNotifier<AsyncValue<LanguageSettings>> {
  LanguageNotifier(this._ref, this._repository)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;
  final SettingsRepository _repository;

  static const _supportedLocales = {'en_us', 'vi_vn'};
  static const _fallbackLocale = 'en_us';

  Future<void> _load() async {
    try {
      final data = await _repository.fetchLanguageSettings();
      final normalized = data.selected.toLowerCase();
      final effective =
          _supportedLocales.contains(normalized) ? normalized : _fallbackLocale;
      if (effective != normalized) {
        final corrected = LanguageSettings(selected: effective);
        await _repository.updateLanguage(corrected);
        state = AsyncValue.data(corrected);
      } else {
        state = AsyncValue.data(data);
      }
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> select(String value) async {
    final normalized = value.toLowerCase();
    final effective =
        _supportedLocales.contains(normalized) ? normalized : _fallbackLocale;
    final updated = LanguageSettings(selected: effective);
    state = AsyncValue.data(updated);
    try {
      await _repository.updateLanguage(updated);
      final locale = _parseLocale(effective);
      await _ref.read(localeControllerProvider.notifier).setLocale(locale);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Locale _parseLocale(String value) {
    final parts = value.split('_');
    if (parts.length == 2) {
      return Locale(parts.first, parts.last.toUpperCase());
    }
    return Locale(value);
  }
}

final languageNotifierProvider =
    StateNotifierProvider<LanguageNotifier, AsyncValue<LanguageSettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return LanguageNotifier(ref, repository);
});


