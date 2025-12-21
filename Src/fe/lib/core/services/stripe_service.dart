import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../constants/stripe_constants.dart';

final stripeServiceProvider = Provider<StripeService>((ref) {
  return StripeService();
});

class StripeService {
  StripeService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = StripeConstants.backendBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  final Dio _dio;

  /// Create Payment Intent via backend
  Future<PaymentIntentResponse> createPaymentIntent({
    required String movieId,
    required double amount,
    String currency = 'usd',
    String? movieTitle,
    String? movieImageUrl,
    String? movieSlug,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final requestData = {
        'userId': user.uid,
        'movieId': movieId,
        'amount': amount,
        'currency': currency,
      };

      if (movieTitle != null) requestData['movieTitle'] = movieTitle;
      if (movieImageUrl != null) requestData['movieImageUrl'] = movieImageUrl;
      if (movieSlug != null) requestData['movieSlug'] = movieSlug;

      final response = await _dio.post(
        '/create-payment',
        data: requestData,
      );

      return PaymentIntentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create payment intent: ${e.toString()}');
    }
  }

  /// Initialize and present Stripe Payment Sheet
  Future<void> presentPaymentSheet({
    required String clientSecret,
    required String ephemeralKeySecret,
    required String customerId,
  }) async {
    try {
      // Initialize Payment Sheet with v12 API
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Nozie',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKeySecret,
        ),
      );

      // Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw Exception('Payment canceled');
      } else {
        throw Exception('Payment failed: ${e.error.message}');
      }
    } catch (e) {
      throw Exception('Payment error: ${e.toString()}');
    }
  }

  /// Get transaction status from backend
  Future<TransactionStatus> getTransactionStatus(String transactionId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final response = await _dio.get('/transaction/${user.uid}/$transactionId');
      return TransactionStatus.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get transaction status: ${e.toString()}');
    }
  }
}

class PaymentIntentResponse {
  final String clientSecret;
  final String ephemeralKey;
  final String customerId;
  final String transactionId;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.ephemeralKey,
    required this.customerId,
    required this.transactionId,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['clientSecret'] as String,
      ephemeralKey: json['ephemeralKey'] as String,
      customerId: json['customerId'] as String,
      transactionId: json['transactionId'] as String,
    );
  }
}

class TransactionStatus {
  final String id;
  final String status;
  final DateTime? paidAt;
  final DateTime? failedAt;
  final DateTime? canceledAt;
  final String? errorMessage;

  TransactionStatus({
    required this.id,
    required this.status,
    this.paidAt,
    this.failedAt,
    this.canceledAt,
    this.errorMessage,
  });

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is Map) {
        final seconds = value['_seconds'] ?? value['seconds'];
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch((seconds as int) * 1000);
        }
      }
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return null;
    }

    return TransactionStatus(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      paidAt: parseTimestamp(json['paidAt']),
      failedAt: parseTimestamp(json['failedAt']),
      canceledAt: parseTimestamp(json['canceledAt']),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  bool get isSuccess => status == 'succeeded';
  bool get isFailed => status == 'failed';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';
}
