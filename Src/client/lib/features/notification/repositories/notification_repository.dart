import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/api_config.dart';
import '../models/notification_item.dart';

final dioProvider = Provider((ref) => Dio());

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    ref.watch(dioProvider),
    ref,
  );
});

/// Notification Repository - REST API based
/// TODO: Connect to actual REST API endpoints
class NotificationRepository {
  NotificationRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // In-memory cache for sample data
  final List<NotificationItem> _sampleNotifications = [
    NotificationItem(
      id: 'sample-1',
      type: NotificationType.general,
      title: 'Welcome to Nozie!',
      description: 'Start exploring your favorite movies today.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationItem(
      id: 'sample-2',
      type: NotificationType.newRelease,
      title: 'New Movie Released!',
      description: 'Check out the latest blockbuster now available.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {'movieId': 'sample-1'},
    ),
  ];

  /// Fetch all notifications for the user
  Future<List<NotificationItem>> fetchNotifications({int limit = 100}) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.notificationServiceUrl}/users/$userId/notifications',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map<NotificationItem>((json) => NotificationItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _sampleNotifications;
    } catch (e) {
      return _sampleNotifications;
    }
  }

  /// Stream notifications in real-time (converts Future to Stream)
  Stream<List<NotificationItem>> watchNotifications({int limit = 100}) {
    return Stream.fromFuture(fetchNotifications(limit: limit));
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _dio.patch(
        '${ApiConfig.notificationServiceUrl}/users/$userId/notifications/$notificationId/read',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Update local sample for demo
      final index = _sampleNotifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        _sampleNotifications[index] = _sampleNotifications[index].copyWith(
          readAt: DateTime.now(),
        );
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _dio.patch(
        '${ApiConfig.notificationServiceUrl}/users/$userId/notifications/read-all',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Update local sample for demo
      for (int i = 0; i < _sampleNotifications.length; i++) {
        _sampleNotifications[i] = _sampleNotifications[i].copyWith(
          readAt: DateTime.now(),
        );
      }
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _dio.delete(
        '${ApiConfig.notificationServiceUrl}/users/$userId/notifications/$notificationId',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Remove from local sample for demo
      _sampleNotifications.removeWhere((n) => n.id == notificationId);
    }
  }

  /// Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _dio.delete(
        '${ApiConfig.notificationServiceUrl}/users/$userId/notifications/read',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Remove read notifications from local sample for demo
      _sampleNotifications.removeWhere((n) => n.readAt != null);
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    final notifications = await fetchNotifications();
    return notifications.where((n) => n.readAt == null).length;
  }

  /// Stream unread count
  Stream<int> watchUnreadCount() {
    return Stream.fromFuture(getUnreadCount());
  }

  /// Create a notification (for local/admin use)
  Future<void> createNotification(NotificationItem notification) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _dio.post(
        '${ApiConfig.notificationServiceUrl}/users/$userId/notifications',
        data: notification.toJson(),
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Add to local sample for demo
      _sampleNotifications.insert(0, notification);
    }
  }
}

// Providers
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
