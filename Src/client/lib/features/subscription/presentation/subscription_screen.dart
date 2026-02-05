import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_export.dart';
import '../../../core/constants/app_padding.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentSubAsync = ref.watch(currentSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: ResponsivePadding.content(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Subscription Status
              currentSubAsync.when(
                data: (sub) => sub != null && sub.isActive
                    ? _buildCurrentSubscription(context, sub)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 16),
              
              // Header
              Text(
                'Choose Your Plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getText(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get unlimited access to all premium movies',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Plans List
              Expanded(
                child: plansAsync.when(
                  data: (plans) => ListView.separated(
                    itemCount: plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildPlanCard(
                      context, 
                      ref, 
                      plans[index],
                      isRecommended: index == 1, // Yearly is recommended
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscription(BuildContext context, UserSubscription sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Active Subscription',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${sub.planName} - ${sub.daysRemaining} days remaining',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, 
    WidgetRef ref,
    SubscriptionPlan plan, {
    bool isRecommended = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? AppColors.primary500 : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: isRecommended 
            ? AppColors.primary500.withOpacity(0.05) 
            : Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Text(
                '⭐ RECOMMENDED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.formattedPrice,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '/${plan.durationLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  plan.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Features
                ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(feature),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleSubscribe(context, ref, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended ? AppColors.primary500 : null,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Subscribe Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isRecommended ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(
    BuildContext context, 
    WidgetRef ref, 
    SubscriptionPlan plan,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final service = ref.read(subscriptionServiceProvider);
      final success = await service.subscribe(plan.id);

      // Hide loading
      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirecting to payment...'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start checkout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
