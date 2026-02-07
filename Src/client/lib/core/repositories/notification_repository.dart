import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../auth/auth_providers.dart';
import '../config/api_config.dart';
import '../models/notification_item.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(Dio(), ref);
});

/// Notification Repository - REST API based
/// API: NotificationController endpoints
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
  /// API: GET /notifications/{customerId}
  Future<List<NotificationItem>> fetchNotifications({int limit = 100}) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.notificationServiceUrl}/$userId',
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

  /// Fetch unread notifications only
  /// API: GET /notifications/{customerId}/unread
  Future<List<NotificationItem>> fetchUnreadNotifications() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.notificationServiceUrl}/$userId/unread',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map<NotificationItem>((json) => NotificationItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _sampleNotifications.where((n) => n.readAt == null).toList();
    } catch (e) {
      return _sampleNotifications.where((n) => n.readAt == null).toList();
    }
  }

  /// Stream notifications
  Stream<List<NotificationItem>> watchNotifications({int limit = 100}) {
    return Stream.fromFuture(fetchNotifications(limit: limit));
  }

  /// Mark a notification as read
  /// API: PATCH /notifications/{id}/read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch(
        '${ApiConfig.notificationServiceUrl}/$notificationId/read',
        options: Options(headers: _headers),
      );
    } catch (e) {
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
    final notifications = await fetchNotifications();
    for (final notification in notifications) {
      if (notification.readAt == null) {
        await markAsRead(notification.id);
      }
    }
  }

  /// Delete a notification
  /// API: DELETE /notifications/{id}
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete(
        '${ApiConfig.notificationServiceUrl}/$notificationId',
        options: Options(headers: _headers),
      );
    } catch (e) {
      _sampleNotifications.removeWhere((n) => n.id == notificationId);
    }
  }

  /// Get unread count
  /// API: GET /notifications/{customerId}/count
  Future<int> getUnreadCount() async {
    final userId = _userId;
    if (userId == null) return 0;

    try {
      final response = await _dio.get(
        '${ApiConfig.notificationServiceUrl}/$userId/count',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['unreadCount'] ?? 0;
      }
      return _sampleNotifications.where((n) => n.readAt == null).length;
    } catch (e) {
      return _sampleNotifications.where((n) => n.readAt == null).length;
    }
  }

  /// Stream unread count
  Stream<int> watchUnreadCount() {
    return Stream.fromFuture(getUnreadCount());
  }

  /// Create a notification (for local/admin use)
  /// API: POST /api/notifications
  Future<void> createNotification(NotificationItem notification) async {
    try {
      await _dio.post(
        ApiConfig.notificationServiceUrl,
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
  // Watch userId to refresh/clear when user changes
  ref.watch(currentUserIdProvider);
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

final unreadCountProvider = StreamProvider<int>((ref) {
  // Watch userId to refresh when user changes
  ref.watch(currentUserIdProvider);
  return ref.watch(notificationRepositoryProvider).watchUnreadCount();
});

final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final unreadCount = ref.watch(unreadCountProvider);
  return (unreadCount.value ?? 0) > 0;
});
