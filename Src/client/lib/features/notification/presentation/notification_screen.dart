import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/feedback/toast_notification.dart';
import 'package:movie_fe/features/notification/presentation/widgets/notification_card.dart';
import 'package:movie_fe/features/notification/providers/notification_providers.dart';
import 'package:movie_fe/routes/app_router.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.i18n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final notificationRepo = ref.read(notificationRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.notification.title,
          style: theme.textTheme.headlineLarge,
        ),
        centerTitle: false,
        actions: [
          if (notificationsAsync.value?.isNotEmpty ?? false)
            TextButton(
              onPressed: () async {
                try {
                  await notificationRepo.markAllAsRead();
                } catch (e) {
                  if (context.mounted) {
                    ToastNotification.showError(
                      context,
                      message: t.notification.markAllAsReadFailed(error: e.toString()),
                    );
                  }
                }
              },
              child: Text(
                t.notification.markAllAsRead,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(AppRouter.notificationSettings);
            },
          ),
        ],
      ),
      body: ContentWrapper(
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 140),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        isDark
                            ? ImageConstant.notificationFrameDark
                            : ImageConstant.notificationFrame,
                      ),
                      const Gap(60),
                      Text(
                        t.common.empty,
                        style: theme.textTheme.headlineLarge,
                      ),
                      const Gap(12),
                      Text(
                        t.notification.empty,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Gap(16),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () async {
                    try {
                      await notificationRepo.markAsRead(notification.id);
                    } catch (e) {
                      if (context.mounted) {
                        ToastNotification.showError(
                          context,
                          message: '${t.common.errorPrefix} ${e.toString()}',
                        );
                      }
                    }
                  },
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.warning,
                  ),
                  const Gap(16),
                  Text(
                    t.notification.loadFailed,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Gap(8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.getTextSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(notificationsProvider);
                    },
                    child: Text(t.common.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
