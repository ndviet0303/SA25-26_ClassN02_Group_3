import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/features/profile/models/notification_settings.dart';
import 'package:movie_fe/features/profile/notifiers/notification_notifier.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(notificationNotifierProvider);
    final settings = settingsState.value ?? NotificationSettings.defaults;
    final isUpdating = settingsState.isLoading;
    final t = context.i18n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.profile.notification.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: false,
      ),
      body: ContentWrappers.page(
        context,
        child: settingsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              t.profile.notification.loadError(error: error.toString()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
          data: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(t.profile.notification.sectionTitle),
              const SizedBox(height: 12),
              _SettingGroup(
                children: [
                  _ToggleTile(
                    title: t.profile.notification.toggles.newRecommendation,
                    value: settings.newRecommendation,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(newRecommendation: value),
                  ),
                  _ToggleTile(
                    title: t.profile.notification.toggles.newBookSeries,
                    value: settings.newBookSeries,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(newBookSeries: value),
                  ),
                  _ToggleTile(
                    title: t.profile.notification.toggles.authorUpdates,
                    value: settings.authorUpdates,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(authorUpdates: value),
                  ),
                  _ToggleTile(
                    title: t.profile.notification.toggles.priceDrops,
                    value: settings.priceDrops,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(priceDrops: value),
                  ),
                  _ToggleTile(
                    title: t.profile.notification.toggles.purchase,
                    value: settings.purchase,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(purchase: value),
                  ),
                  _ToggleTile(
                    title: t.profile.notification.toggles.appSystem,
                    value: settings.appSystem,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(appSystem: value),
                  ),
                  _ToggleTile(
                    title: t.profile.notification.toggles.tipsServices,
                    value: settings.tipsServices,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(tipsServices: value),
                  ),
                  _ToggleTile(
                    title: t.profile.notification.toggles.survey,
                    value: settings.survey,
                    enabled: !isUpdating,
                    onChanged: (value) => ref
                        .read(notificationNotifierProvider.notifier)
                        .toggle(survey: value),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
    );
  }
}

class _SettingGroup extends StatelessWidget {
  final List<_ToggleTile> children;

  const _SettingGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i != 0) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: children[i],
          ),
        ],
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const _ToggleTile({
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.getText(context);
    final secondaryColor = AppColors.getTextSecondary(context);

    return Row(
      crossAxisAlignment:
          description?.isNotEmpty == true ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (description?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: secondaryColor,
                      ),
                ),
              ],
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: AppColors.primary500,
          activeTrackColor: AppColors.primary500,
        ),
      ],
    );
  }
}


