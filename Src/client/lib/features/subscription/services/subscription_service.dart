import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/api_config.dart';
import '../models/subscription_model.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(Dio(), ref);
});

/// Subscription Service - handles subscription plans and Stripe checkout
class SubscriptionService {
  SubscriptionService(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Get all available subscription plans
  Future<List<SubscriptionPlan>> getPlans() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.subscriptionServiceUrl}/plans',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> plans = data['data'] ?? data;
        return plans.map((p) => SubscriptionPlan.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      // Return mock data for demo
      return [
        SubscriptionPlan(
          id: '1',
          name: 'Monthly Premium',
          description: 'Access all premium content',
          price: 9.99,
          durationDays: 30,
          stripePriceId: 'price_monthly',
          features: ['Unlimited streaming', 'HD quality', 'No ads'],
        ),
        SubscriptionPlan(
          id: '2',
          name: 'Yearly Premium',
          description: 'Best value - save 20%',
          price: 99.99,
          durationDays: 365,
          stripePriceId: 'price_yearly',
          features: ['Unlimited streaming', '4K quality', 'No ads', 'Offline downloads'],
        ),
      ];
    }
  }

  /// Subscribe to a plan - opens Stripe Checkout
  Future<bool> subscribe(String planId) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _dio.post(
        '${ApiConfig.subscriptionServiceUrl}/subscribe',
        data: {
          'userId': int.parse(_userId!),
          'planId': int.parse(planId),
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final checkoutUrl = data['data']?['checkoutUrl'] ?? data['checkoutUrl'];
        
        if (checkoutUrl != null) {
          // Open Stripe Checkout URL
          final uri = Uri.parse(checkoutUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current subscription status for user
  Future<UserSubscription?> getCurrentSubscription() async {
    if (_userId == null) return null;

    try {
      final response = await _dio.get(
        '${ApiConfig.subscriptionServiceUrl}/current/$_userId',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data != null) {
          return UserSubscription.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if current user has active subscription
  Future<bool> hasActiveSubscription() async {
    final sub = await getCurrentSubscription();
    return sub?.isActive ?? false;
  }

  /// Get subscription history
  Future<List<UserSubscription>> getSubscriptionHistory() async {
    if (_userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.subscriptionServiceUrl}/history/$_userId',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> history = data['data'] ?? data;
        return history.map((s) => UserSubscription.fromJson(s)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

/// Provider to fetch subscription plans
final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((ref) {
  return ref.watch(subscriptionServiceProvider).getPlans();
});

/// Provider to fetch current user subscription
final currentSubscriptionProvider = FutureProvider<UserSubscription?>((ref) {
  return ref.watch(subscriptionServiceProvider).getCurrentSubscription();
});

/// Provider to check if user has active subscription
final hasSubscriptionProvider = FutureProvider<bool>((ref) {
  return ref.watch(subscriptionServiceProvider).hasActiveSubscription();
});
