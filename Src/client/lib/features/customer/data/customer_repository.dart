import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../../../core/auth/auth_providers.dart';

final customerDioProvider = Provider((ref) => Dio());

class CustomerInfo {
  final int id;
  final int userId;
  final String? email;
  final String? phoneNumber;
  final bool isSubscribed;
  final String? subscriptionStatus;
  final DateTime? subscriptionEndDate;
  final String? stripeCustomerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerInfo({
    required this.id,
    required this.userId,
    this.email,
    this.phoneNumber,
    required this.isSubscribed,
    this.subscriptionStatus,
    this.subscriptionEndDate,
    this.stripeCustomerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['phone_number'],
      isSubscribed: json['isSubscribed'] ?? json['is_subscribed'] ?? json['subscribed'] ?? false,
      subscriptionStatus: json['subscriptionStatus'] ?? json['subscription_status'],
      subscriptionEndDate: (json['subscriptionEndDate'] ?? json['subscription_end_date']) != null 
          ? DateTime.tryParse((json['subscriptionEndDate'] ?? json['subscription_end_date']).toString())
          : null,
      stripeCustomerId: json['stripeCustomerId'] ?? json['stripe_customer_id'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class CustomerRepository {
  final Dio _dio;
  final Ref _ref;

  CustomerRepository(this._dio, this._ref);

  Map<String, String> get _headers {
    final token = _ref.read(accessTokenProvider);
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<CustomerInfo?> getCustomerByUserId(int userId) async {
    if (userId <= 0) return null;
    try {
      final response = await _dio.get(
        '${ApiConfig.customerServiceUrl}/user/$userId',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return CustomerInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching customer info: $e');
      return null;
    }
  }

  Future<bool> isUserSubscribed(int userId) async {
    if (userId <= 0) return false;
    final customer = await getCustomerByUserId(userId);
    return customer?.isSubscribed ?? false;
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(customerDioProvider), ref);
});

final customerInfoProvider = FutureProvider.family<CustomerInfo?, int>((ref, userId) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCustomerByUserId(userId);
});

final isUserSubscribedProvider = FutureProvider.family<bool, int>((ref, userId) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.isUserSubscribed(userId);
});
