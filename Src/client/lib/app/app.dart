import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../i18n/translations.g.dart';
import '../core/services/locale_setting.dart';
import '../core/services/theme_mode_notifier.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/orientation_lock_widget.dart';
import '../routes/app_router.dart';

class NozieApp extends ConsumerWidget {
  const NozieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeControllerProvider);
    final router = ref.watch(routerProvider);

    return OrientationLockWidget(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: locale, // language
        supportedLocales: AppLocale.values.map((e) => e.flutterLocale),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: themeMode, // dark/light mode
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router, // routing config
      ),
    );
  }
}
