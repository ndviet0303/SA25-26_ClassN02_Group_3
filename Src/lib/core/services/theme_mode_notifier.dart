import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier()..load(); // load khi khởi tạo
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  static const _key = 'app_theme_mode'; // 'system' | 'light' | 'dark'

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    switch (sp.getString(_key)) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _key,
      mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system',
    );
  }
}
