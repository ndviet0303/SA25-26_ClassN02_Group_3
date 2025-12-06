// lib/core/services/locale_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../i18n/translations.g.dart';

final localeControllerProvider =
StateNotifierProvider<LocaleController, Locale>((ref) {
  throw UnimplementedError('Must be overridden with SharedPreferences and Ref');
});

// Add a rebuild trigger provider
final localeRebuildProvider = StateProvider<int>((ref) => 0);

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs, this._ref, {String defaultCode = 'vi'})
      : super(Locale(_prefs.getString('app_locale') ?? defaultCode)) {
    // Defer slang locale sync to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSlangLocale(state);
    });
  }

  final SharedPreferences _prefs;
  final Ref _ref;

  Future<void> setLocale(Locale l) async {
    // Update state first to trigger MaterialApp rebuild
    state = l;
    await _prefs.setString('app_locale', l.languageCode);
    
    // Update slang locale after a small delay to ensure proper sync
    await Future.delayed(const Duration(milliseconds: 1));
    _updateSlangLocale(l);
    
    // Trigger a rebuild to force TranslationProvider to update
    _ref.read(localeRebuildProvider.notifier).state++;
  }

  void _updateSlangLocale(Locale locale) {
    final appLocale = AppLocale.values.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => AppLocale.vi,
    );
    LocaleSettings.setLocale(appLocale);
  }
}
