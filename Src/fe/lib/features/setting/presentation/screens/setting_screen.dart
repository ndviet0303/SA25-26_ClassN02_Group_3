import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_export.dart';
import '../../../../routes/app_router.dart';

class SettingPage extends ConsumerWidget {

  final Locale locale;
  final void Function(Locale) onChangeLocale;

  const SettingPage(this.locale, this.onChangeLocale, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.i18n;

    final themeMode = ref.watch(themeModeProvider);
    // Watch current locale from provider to ensure consistency
    final currentLocale = ref.watch(localeControllerProvider);
    // Watch rebuild trigger to force rebuild when locale changes
    ref.watch(localeRebuildProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.app.title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(t.settings.language.english)),
                ButtonSegment(value: 'vi', label: Text(t.settings.language.vietnamese)),
              ],
              selected: {currentLocale.languageCode},
              onSelectionChanged: (s) => onChangeLocale(Locale(s.first)),
            ),

            const SizedBox(height: 24),

            // ---- Switch theme: System / Light / Dark ----
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.phone_iphone), label: Text(t.settings.theme.system)),
                ButtonSegment(value: ThemeMode.light,  icon: Icon(Icons.light_mode),  label: Text(t.settings.theme.light)),
                ButtonSegment(value: ThemeMode.dark,   icon: Icon(Icons.dark_mode),   label: Text(t.settings.theme.dark)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
            ),

            ElevatedButton(onPressed: () {}, child: Text(t.common.data)),

            const SizedBox(height: 24),
            
            PrimaryButton(text: 'Welcome', onPressed: () => context.go(AppRouter.welcome),)
            
          ],
        ),
      ),
    );
  }
}
