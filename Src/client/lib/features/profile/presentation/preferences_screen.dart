import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/feedback/toast_notification.dart';
import 'package:movie_fe/features/profile/models/preferences.dart';
import 'package:movie_fe/features/profile/notifiers/preferences_notifier.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesState = ref.watch(preferencesNotifierProvider);
    final prefs = preferencesState.value ?? Preferences.defaults;
    final notifier = ref.read(preferencesNotifierProvider.notifier);
    final t = context.i18n;

    if (preferencesState.isLoading && preferencesState.value == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    void showClearCacheSheet() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.getSurface(context),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          final sizeLabel = _cacheLabel(context, prefs.cacheSizeMb);
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.profile.preferences.actions.clearCache.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getText(context),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.profile.preferences.actions.clearCache
                      .description(size: sizeLabel),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.getTextSecondary(context),
                      ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: t.profile.preferences.actions.clearCache.button,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    notifier.updateFields(cacheSizeMb: 0);
                    ToastNotification.showSuccess(
                      context,
                      message: t.profile.preferences.actions.clearCache.success,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  hasShadow: true,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: t.common.cancel,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          );
        },
      );
    }

    void showOptionsSheet({
      required String title,
      required Map<String, String> options,
      required String selected,
      required ValueChanged<String> onSelect,
    }) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.getSurface(context),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.getText(context),
                      ),
                ),
                const SizedBox(height: 16),
                ...options.entries.map(
                  (option) => RadioListTile<String>(
                    value: option.key,
                    groupValue: selected,
                    onChanged: (value) {
                      if (value == null) return;
                      onSelect(value);
                      Navigator.of(sheetContext).pop();
                    },
                    activeColor: AppColors.primary500,
                    title: Text(option.value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(t.common.cancel),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.profile.preferences.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _SectionLabel(title: t.profile.preferences.sections.general),
          _ToggleTile(
            title: t.profile.preferences.toggles.wifiOnlyDownloads,
            value: prefs.wifiOnlyDownloads,
            onChanged: (value) => notifier.updateFields(wifiOnlyDownloads: value),
          ),
          _ActionTile(
            title: t.profile.preferences.actions.clearCache.title,
            value: _cacheLabel(context, prefs.cacheSizeMb),
            onPressed: showClearCacheSheet,
          ),
          const SizedBox(height: 24),
          _SectionLabel(title: t.profile.preferences.sections.playback),
          _ToggleTile(
            title: t.profile.preferences.toggles.autoPlayNextEpisode,
            value: prefs.autoPlayNextEpisode,
            onChanged: (value) => notifier.updateFields(autoPlayNextEpisode: value),
          ),
          _ToggleTile(
            title: t.profile.preferences.toggles.continueWatching,
            value: prefs.continueWatching,
            onChanged: (value) => notifier.updateFields(continueWatching: value),
          ),
          _ToggleTile(
            title: t.profile.preferences.toggles.subtitlesEnabled,
            value: prefs.subtitlesEnabled,
            onChanged: (value) => notifier.updateFields(subtitlesEnabled: value),
          ),
          const SizedBox(height: 24),
          _SectionLabel(title: t.profile.preferences.sections.video),
          _ActionTile(
            title: t.profile.preferences.actions.videoQuality.title,
            value: _localizedVideoQuality(context, prefs.videoQuality),
            onPressed: () => showOptionsSheet(
              title: t.profile.preferences.actions.videoQuality.title,
              options: {
                'Auto': t.profile.preferences.actions.videoQuality.options.auto,
                'HD': t.profile.preferences.actions.videoQuality.options.hd,
                'Full HD': t.profile.preferences.actions.videoQuality.options.fullHd,
              },
              selected: prefs.videoQuality,
              onSelect: (value) => notifier.updateFields(videoQuality: value),
            ),
          ),
          _ToggleTile(
            title: t.profile.preferences.toggles.autoRotateScreen,
            value: prefs.autoRotateScreen,
            onChanged: (value) => notifier.updateFields(autoRotateScreen: value),
          ),
          const SizedBox(height: 24),
          _SectionLabel(title: t.profile.preferences.sections.audio),
          _ActionTile(
            title: t.profile.preferences.actions.audioPreference.title,
            value: _localizedAudioPreference(context, prefs.audioPreference),
            onPressed: () => showOptionsSheet(
              title: t.profile.preferences.actions.audioPreference.title,
              options: {
                'System Default':
                    t.profile.preferences.actions.audioPreference.options.systemDefault,
                'English • High Quality':
                    t.profile.preferences.actions.audioPreference.options.englishHigh,
                'Original • Standard':
                    t.profile.preferences.actions.audioPreference.options.originalStandard,
              },
              selected: prefs.audioPreference,
              onSelect: (value) => notifier.updateFields(audioPreference: value),
            ),
          ),
          _ToggleTile(
            title: t.profile.preferences.toggles.autoDownloadAudio,
            value: prefs.autoDownloadAudio,
            onChanged: (value) => notifier.updateFields(autoDownloadAudio: value),
          ),
        ],
      ),
    );
  }
}

String _cacheLabel(BuildContext context, double value) {
  final t = context.i18n.profile.preferences.storageLabel;
  if (value <= 0) return t.empty;
  return t.value(amount: value.toStringAsFixed(0));
}

String _localizedVideoQuality(BuildContext context, String value) {
  final options = context.i18n.profile.preferences.actions.videoQuality.options;
  switch (value.toLowerCase()) {
    case 'auto':
      return options.auto;
    case 'hd':
      return options.hd;
    case 'full hd':
      return options.fullHd;
    default:
      return value;
  }
}

String _localizedAudioPreference(BuildContext context, String value) {
  final options = context.i18n.profile.preferences.actions.audioPreference.options;
  switch (value.toLowerCase()) {
    case 'system default':
      return options.systemDefault;
    case 'english • high quality':
      return options.englishHigh;
    case 'original • standard':
      return options.originalStandard;
    default:
      return value;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.getText(context),
            ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.getText(context),
            ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary500,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    this.value,
    required this.onPressed,
  });

  final String title;
  final String? value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final subtitle = value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.getText(context),
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getTextSecondary(context),
                  ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.getTextSecondary(context),
      ),
      onTap: onPressed,
    );
  }
}


