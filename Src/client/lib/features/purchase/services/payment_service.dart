import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/api_config.dart';
import '../../../core/models/movie.dart';
import '../../../features/notification/models/notification_item.dart';
import '../../../features/notification/repositories/notification_repository.dart';

final dioProvider = Provider((ref) => Dio());

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(
    ref.watch(dioProvider),
    ref,
    ref.watch(notificationRepositoryProvider),
  );
});

/// Payment Service - REST API based
/// Handles movie purchases and payment processing
class PaymentService {
  PaymentService(
    this._dio,
    this._ref,
    this._notificationRepo,
  );

  final Dio _dio;
  final Ref _ref;
  final NotificationRepository _notificationRepo;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

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

    try {
      final response = await _dio.post(
        '${ApiConfig.paymentServiceUrl}/process',
        data: {
          'userId': _userId,
          'movieId': movie.id,
          'amount': price,
          'currency': 'usd',
          'paymentMethodId': paymentMethodId,
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['success'] == true;
      }
      
      throw Exception('Payment failed');
    } catch (e) {
      // Simulate payment for demo
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate 95% success rate for demo
      final random = DateTime.now().millisecond % 100;
      if (random < 95) {
        return true;
      } else {
        throw Exception('Payment declined. Please try another payment method.');
      }
    }
  }

  /// Add movie to user's purchases
  Future<void> _addToPurchases(String movieId) async {
    try {
      await _dio.post(
        '${ApiConfig.purchaseServiceUrl}/users/$_userId/purchases',
        data: {
          'movieId': movieId,
          'purchasedAt': DateTime.now().toIso8601String(),
          'isDownloaded': true,
          'isFinished': false,
        },
        options: Options(headers: _headers),
      );
    } catch (e) {
      // For demo, just log error
      print('[PaymentService] Error adding to purchases: $e');
    }
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
    
    try {
      await _dio.post(
        '${ApiConfig.purchaseServiceUrl}/users/$_userId/transactions',
        data: {
          'movieId': movie.id,
          'movieTitle': movie.title,
          'amount': price,
          'paymentMethodId': paymentMethodId,
          'status': 'completed',
          'createdAt': DateTime.now().toIso8601String(),
        },
        options: Options(headers: _headers),
      );
    } catch (e) {
      // For demo, just log error
      print('[PaymentService] Error recording transaction: $e');
    }

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
      await _dio.post(
        '${ApiConfig.purchaseServiceUrl}/users/$_userId/transactions',
        data: {
          'movieId': movie.id,
          'movieTitle': movie.title,
          'amount': price,
          'paymentMethodId': paymentMethodId,
          'status': 'failed',
          'error': error,
          'createdAt': DateTime.now().toIso8601String(),
        },
        options: Options(headers: _headers),
      );
    } catch (_) {
      // Ignore transaction recording errors
    }
  }
}
