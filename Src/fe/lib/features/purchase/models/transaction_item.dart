import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionItem {
  final String id;
  final String userId;
  final String movieId;
  final String? movieTitle;
  final String? movieImageUrl;
  final String? movieSlug;
  final double amount;
  final String currency;
  final String status;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final DateTime? failedAt;
  final DateTime? canceledAt;
  final String? stripePaymentIntentId;
  final String? chargeId;
  final String? errorMessage;

  const TransactionItem({
    required this.id,
    required this.userId,
    required this.movieId,
    this.movieTitle,
    this.movieImageUrl,
    this.movieSlug,
    required this.amount,
    this.currency = 'usd',
    required this.status,
    this.createdAt,
    this.paidAt,
    this.failedAt,
    this.canceledAt,
    this.stripePaymentIntentId,
    this.chargeId,
    this.errorMessage,
  });

  factory TransactionItem.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is Map) {
        final seconds = value['_seconds'] ?? value['seconds'];
        if (seconds != null) {
          final nanoseconds = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(
            (seconds as int) * 1000 + ((nanoseconds as int) ~/ 1000000),
          );
        }
      }
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return null;
    }

    return TransactionItem(
      id: id,
      userId: data['userId'] as String? ?? '',
      movieId: data['movieId'] as String? ?? '',
      movieTitle: data['movieTitle'] as String?,
      movieImageUrl: data['movieImageUrl'] as String?,
      movieSlug: data['movieSlug'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'usd',
      status: data['status'] as String? ?? 'pending',
      createdAt: parseTimestamp(data['createdAt']),
      paidAt: parseTimestamp(data['paidAt']),
      failedAt: parseTimestamp(data['failedAt']),
      canceledAt: parseTimestamp(data['canceledAt']),
      stripePaymentIntentId: data['stripePaymentIntentId'] as String?,
      chargeId: data['chargeId'] as String?,
      errorMessage: data['errorMessage'] as String?,
    );
  }

  bool get isSuccess => status == 'succeeded';
  bool get isFailed => status == 'failed';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';
}
