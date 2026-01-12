import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/enums/status_type.dart';
import 'package:movie_fe/core/utils/data/date_util.dart';
import 'package:movie_fe/features/notification/models/notification_item.dart';
import 'package:movie_fe/features/notification/presentation/widgets/notification_icon.dart';
import 'package:movie_fe/routes/app_router.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        onTap();
        if (notification.deepLink != null) {
          // Navigate based on deep link
          _handleDeepLink(context, notification.deepLink!);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
            Row(
              spacing: 12,
              children: [
                Flexible(
                  child: NotificationIcon(type: _mapNotificationType(notification.type)),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    spacing: 6,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          Text(
                            DateUtil.formatRelativeDate(notification.createdAt, context),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                          Text(
                            "|",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                          Text(
                            DateFormat('hh:mm a').format(notification.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                        color: AppColors.primary500,
                      ),
                      child: Center(
                        child: Text(
                          context.i18n.notification.newItem,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              notification.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
    );
  }

  void _handleDeepLink(BuildContext context, String deepLink) {
    // Parse deep links like: "movie:123", "profile", "settings:notifications"
    final parts = deepLink.split(':');
    if (parts.isEmpty) return;

    final route = parts[0];
    final param = parts.length > 1 ? parts[1] : null;

    switch (route) {
      case 'movie':
        if (param != null) {
          context.push('${AppRouter.movie}/$param');
        }
        break;
      case 'profile':
        context.go(AppRouter.profile);
        break;
      case 'settings':
        if (param == 'notifications') {
          context.push(AppRouter.notificationSettings);
        }
        break;
      default:
        break;
    }
  }

  StatusType _mapNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.purchase:
      case NotificationType.priceDrop:
        return StatusType.credit;
      case NotificationType.recommendation:
      case NotificationType.authorUpdate:
        return StatusType.info;
      case NotificationType.system:
      case NotificationType.tips:
        return StatusType.update;
      case NotificationType.survey:
        return StatusType.feature;
      case NotificationType.general:
      default:
        return StatusType.update;
    }
  }
}
