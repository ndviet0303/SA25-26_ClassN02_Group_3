import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchNotifications();
});

final unreadCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.watchUnreadCount();
});

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final unreadCount = ref.watch(unreadCountProvider);
  final count = unreadCount.value;
  if (count == null) return false;
  return count > 0;
});

