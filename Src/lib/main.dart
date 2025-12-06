import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

import 'app/app.dart';
import 'core/constants/stripe_constants.dart';
import 'core/services/locale_setting.dart';
import 'core/services/shared_prefs_provider.dart';
import 'core/utils/api/dio_client.dart';
import 'firebase_options.dart';
import 'i18n/translations.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final sp = await SharedPreferences.getInstance();
  DioClient.init();

  // Initialize Stripe
  Stripe.publishableKey = StripeConstants.publishableKey;
  Stripe.merchantIdentifier = 'merchant.com.oggy.nozie';

  // Initialize slang locale BEFORE creating widget tree
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
