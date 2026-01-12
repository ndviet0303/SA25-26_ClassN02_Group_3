import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/movie.dart';
import '../../../features/notification/models/notification_item.dart';
import '../../../features/notification/repositories/notification_repository.dart';
import '../../../features/notification/providers/notification_providers.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
    ref.watch(notificationRepositoryProvider),
  );
});

class PaymentService {
  PaymentService(
    this._db,
    this._auth,
    this._notificationRepo,
  );

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final NotificationRepository _notificationRepo;

  String? get _userId => _auth.currentUser?.uid;

  /// Process a movie purchase with payment
  /// 
  /// This method:
  /// 1. Validates payment method
  /// 2. Processes payment (simulated or real gateway)
  /// 3. Adds to purchases if successful
  /// 4. Creates purchase notification
  /// 5. Records transaction history
  Future<bool> processPurchase({
    required Movie movie,
    required String paymentMethodId,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // 1. Validate payment method
      await _validatePaymentMethod(paymentMethodId);

      // 2. Process payment
      final paymentSuccessful = await _processPaymentWithGateway(
        movie: movie,
        paymentMethodId: paymentMethodId,
      );

      if (!paymentSuccessful) {
        return false;
      }

      // 3. Add to purchases
      await _addToPurchases(movie.id);

      // 4. Record transaction
      await _recordTransaction(
        movie: movie,
        paymentMethodId: paymentMethodId,
      );

      return true;
    } catch (e) {
      // Log error
      await _recordFailedTransaction(
        movie: movie,
        paymentMethodId: paymentMethodId,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Validate that payment method exists and is valid
  Future<void> _validatePaymentMethod(String paymentMethodId) async {
    // TODO: Implement real validation with payment gateway
    // For now, just check if method exists
    if (paymentMethodId.isEmpty) {
      throw Exception('Invalid payment method');
    }
    
    // Simulate validation delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Process payment with payment gateway
  /// 
  /// TODO: Integrate with real payment gateway (Stripe, PayPal, etc.)
  Future<bool> _processPaymentWithGateway({
    required Movie movie,
    required String paymentMethodId,
  }) async {
    final price = movie.priceValue ?? 0.0;
    
    if (price == 0.0) {
      // Free content - no payment needed
      return true;
    }

    // TODO: Replace this with real payment gateway integration
    // Example: Stripe, PayPal, Google Pay, Apple Pay, etc.
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate 95% success rate for demo
    // In production, this will be based on real gateway response
    final random = DateTime.now().millisecond % 100;
    
    if (random < 95) {
      return true; // Payment successful
    } else {
      throw Exception('Payment declined. Please try another payment method.');
    }
  }

  /// Add movie to user's purchases
  Future<void> _addToPurchases(String movieId) async {
    await _db
        .collection('users')
        .doc(_userId)
        .collection('purchases')
        .doc(movieId)
        .set({
      'movieId': movieId,
      'purchasedAt': FieldValue.serverTimestamp(),
      'isDownloaded': true,
      'isFinished': false,
    });
  }

  /// Create purchase notification
  Future<void> _createPurchaseNotification(Movie movie) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.purchase,
      title: 'Purchase Successful! 🎬',
      description: 'You now own "${movie.title}"',
      createdAt: DateTime.now(),
      deepLink: 'movie:${movie.id}',
      metadata: {
        'movieId': movie.id,
        'movieTitle': movie.title,
        'movieImageUrl': movie.imageUrl,
      },
    );

    await _notificationRepo.createNotification(notification);
  }

  /// Record successful transaction
  Future<void> _recordTransaction({
    required Movie movie,
    required String paymentMethodId,
  }) async {
    final price = movie.priceValue ?? 0.0;
    
    await _db
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc()
        .set({
      'movieId': movie.id,
      'movieTitle': movie.title,
      'amount': price,
      'paymentMethodId': paymentMethodId,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Create notification after transaction is recorded
    await _createPurchaseNotification(movie);
  }

  /// Record failed transaction
  Future<void> _recordFailedTransaction({
    required Movie movie,
    required String paymentMethodId,
    required String error,
  }) async {
    final price = movie.priceValue ?? 0.0;
    
    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc()
          .set({
        'movieId': movie.id,
        'movieTitle': movie.title,
        'amount': price,
        'paymentMethodId': paymentMethodId,
        'status': 'failed',
        'error': error,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Ignore transaction recording errors
    }
  }
}

