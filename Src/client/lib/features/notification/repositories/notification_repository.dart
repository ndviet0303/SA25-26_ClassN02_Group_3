import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_item.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _db.collection('users').doc(_userId).collection('notifications');

  /// Fetch all notifications for the user
  Future<List<NotificationItem>> fetchNotifications({
    int limit = 100,
  }) async {
    try {
      final snapshot = await _notificationsRef
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => NotificationItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Stream notifications in real-time
  Stream<List<NotificationItem>> watchNotifications({
    int limit = 100,
  }) {
    return _notificationsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final snapshot = await _notificationsRef
          .where('readAt', isNull: true)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all read notifications
  Future<void> deleteAllReadNotifications() async {
    try {
      final snapshot = await _notificationsRef
          .where('readAt', isNull: false)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete read notifications: $e');
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final snapshot = await _notificationsRef
          .where('readAt', isNull: true)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Stream unread count
  Stream<int> watchUnreadCount() {
    return _notificationsRef
        .where('readAt', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Create a notification (for testing or admin use)
  Future<void> createNotification(NotificationItem notification) async {
    try {
      await _notificationsRef.doc(notification.id).set(notification.toJson());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }
}

