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

  factory TransactionItem.fromJson(Map<String, dynamic> data) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
    }

    return TransactionItem(
      id: data['id'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      movieId: data['movieId'] as String? ?? '',
      movieTitle: data['movieTitle'] as String?,
      movieImageUrl: data['movieImageUrl'] as String?,
      movieSlug: data['movieSlug'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'usd',
      status: data['status'] as String? ?? 'pending',
      createdAt: parseDateTime(data['createdAt']),
      paidAt: parseDateTime(data['paidAt']),
      failedAt: parseDateTime(data['failedAt']),
      canceledAt: parseDateTime(data['canceledAt']),
      stripePaymentIntentId: data['stripePaymentIntentId'] as String?,
      chargeId: data['chargeId'] as String?,
      errorMessage: data['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'movieImageUrl': movieImageUrl,
      'movieSlug': movieSlug,
      'amount': amount,
      'currency': currency,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'failedAt': failedAt?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'stripePaymentIntentId': stripePaymentIntentId,
      'chargeId': chargeId,
      'errorMessage': errorMessage,
    };
  }

  bool get isSuccess => status == 'succeeded';
  bool get isFailed => status == 'failed';
  bool get isCanceled => status == 'canceled';
  bool get isPending => status == 'pending';
}
