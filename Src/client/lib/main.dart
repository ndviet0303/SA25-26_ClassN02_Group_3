import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/locale_setting.dart';
import 'core/services/shared_prefs_provider.dart';
import 'core/utils/api/dio_client.dart';
import 'i18n/translations.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final sp = await SharedPreferences.getInstance();
  DioClient.init();

  // Set locale before widget tree
  final savedLocaleCode = sp.getString('app_locale') ?? 'vi';
  final appLocale = AppLocale.values.firstWhere(
    (l) => l.languageCode == savedLocaleCode,
    orElse: () => AppLocale.vi,
  );
  LocaleSettings.setLocale(appLocale);

  runApp(
    ProviderScope(
      overrides: [
        localeControllerProvider.overrideWith((ref) => LocaleController(sp, ref)),
        sharedPreferencesProvider.overrideWithValue(sp),
      ],
      child: TranslationProvider(child: const NozieApp()),
    ),
  );
}
