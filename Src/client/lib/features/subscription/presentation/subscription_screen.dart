import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/app_export.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentSubAsync = ref.watch(currentSubscriptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Premium',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              currentSubAsync.when(
                data: (sub) => sub != null && sub.isActive
                    ? _buildCurrentSubscription(context, sub, isDark)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Gap(16),
              _buildHeader(context),
              const Gap(24),
              Expanded(
                child: plansAsync.when(
                  data: (plans) => ListView.separated(
                    itemCount: plans.length,
                    separatorBuilder: (_, __) => const Gap(16),
                    itemBuilder: (context, index) => _buildPlanCard(
                      context,
                      ref,
                      plans[index],
                      isDark,
                      isRecommended: index == 1,
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary500),
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.warning),
                        const Gap(16),
                        Text('Failed to load plans', style: theme.textTheme.bodyLarge),
                        const Gap(8),
                        PrimaryButton(
                          text: 'Retry',
                          width: 120,
                          height: 44,
                          onPressed: () => ref.invalidate(subscriptionPlansProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary500,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upgrade to Premium',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getText(context),
                    ),
              ),
              const Gap(4),
              Text(
                'Unlimited movies, no ads',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getTextSecondary(context),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSubscription(BuildContext context, UserSubscription sub, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.white, size: 24),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Premium',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${sub.planName} • ${sub.daysRemaining} days left',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
    bool isDark, {
    bool isRecommended = false,
  }) {
    final theme = Theme.of(context);
    final cardColor = isDark ? AppColors.dark3 : Colors.white;
    final borderColor = isRecommended ? AppColors.primary500 : (isDark ? AppColors.dark4 : AppColors.greyscale200);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor, width: isRecommended ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 16),
                  Gap(6),
                  Text('BEST VALUE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
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
                    Text(plan.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(plan.formattedPrice, style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.primary500, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(plan.durationLabel, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.getTextSecondary(context))),
                const Gap(16),
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check, color: AppColors.success, size: 18),
                          const Gap(8),
                          Text(feature, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    )),
                const Gap(16),
                PrimaryButton(
                  text: 'Subscribe Now',
                  onPressed: () => _handleSubscribe(context, ref, plan),
                  backgroundColor: isRecommended ? AppColors.primary500 : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(BuildContext context, WidgetRef ref, SubscriptionPlan plan) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary500)),
      );

      final service = ref.read(subscriptionServiceProvider);
      final success = await service.subscribe(plan.id);

      if (context.mounted) Navigator.of(context).pop();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Redirecting to payment...'), backgroundColor: AppColors.success),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start checkout'), backgroundColor: AppColors.warning),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.warning));
      }
    }
  }
}
