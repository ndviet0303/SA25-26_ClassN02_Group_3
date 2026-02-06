/// Subscription Plan model - matches backend SubscriptionPlan entity
class SubscriptionPlan {
  final String id;
  final String? planType;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final String stripePriceId;
  final bool isActive;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    this.planType,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.stripePriceId,
    this.isActive = true,
    this.features = const [],
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      planType: json['planType'] ?? json['type'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? 30,
      stripePriceId: json['stripePriceId'] ?? '',
      isActive: json['isActive'] ?? true,
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'durationDays': durationDays,
    'stripePriceId': stripePriceId,
    'isActive': isActive,
    'features': features,
  };

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get durationLabel {
    if (durationDays >= 365) return '${durationDays ~/ 365} year';
    if (durationDays >= 30) return '${durationDays ~/ 30} month';
    return '$durationDays days';
  }

  int get intervalMonths {
    if (durationDays >= 365) return 12;
    if (durationDays >= 30) return durationDays ~/ 30;
    return 1;
  }
}

/// User Subscription status model
class UserSubscription {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String? stripeSubscriptionId;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.stripeSubscriptionId,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      planName: json['planName'] ?? json['planType'] ?? 'Premium',
      status: json['status'] ?? 'ACTIVE',
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : DateTime.now(),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : DateTime.now().add(const Duration(days: 30)),
      stripeSubscriptionId: json['stripeSubscriptionId'],
    );
  }

  bool get isActive => status == 'ACTIVE' && endDate.isAfter(DateTime.now());

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}
