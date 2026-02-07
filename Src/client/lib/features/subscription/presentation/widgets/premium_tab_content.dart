import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/subscription_model.dart';
import '../../../../core/repositories/subscription_repository.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/loading.dart';

class PremiumTabContent extends ConsumerWidget {
  const PremiumTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentSubAsync = ref.watch(currentSubscriptionProvider);
    final historyAsync = ref.watch(subscriptionHistoryProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Subscription Status
          currentSubAsync.when(
            data: (sub) => sub != null && sub.isActive
                ? _buildActiveSubCard(context, ref, sub)
                : _buildNoSubHeader(context),
            loading: () => LoadingCustom(assetName: ImageConstant.loadingIcon, size: 40),
            error: (e, __) => const SizedBox.shrink(),
          ),
          
          const Gap(24),
          
          // Available Plans
          Text(
            context.i18n.premium.plans.availablePlans,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          plansAsync.when(
            data: (plans) {
              final currentSub = currentSubAsync.value;
              final hasActiveSub = currentSub != null && currentSub.isActive;
              final filteredPlans = plans.where((p) {
                if (p.planType == 'FREE') return false;
                if (currentSub != null && currentSub.isActive && currentSub.planName == p.planType) {
                  return false;
                }
                return true;
              }).toList();
              
              return Column(
                children: filteredPlans.map((plan) => _buildPlanCard(context, ref, plan, hasActiveSub: hasActiveSub)).toList(),
              );
            },
            loading: () => LoadingCustom(assetName: ImageConstant.loadingIcon, size: 40),
            error: (e, __) => Center(child: Text('Error loading plans: $e')),
          ),
          
          const Gap(32),
          
          // History
          Text(
            context.i18n.premium.history,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          historyAsync.when(
            data: (history) => history.isEmpty 
                ? _buildEmptyHistory(context)
                : Column(
                    children: history.map((h) => _buildHistoryItem(context, h)).toList(),
                  ),
            loading: () => LoadingCustom(assetName: ImageConstant.loadingIcon, size: 40),
            error: (e, __) => Text('Error loading history: $e'),
          ),
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildNoSubHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary500, AppColors.primary500.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
              const Gap(12),
              Text(
                context.i18n.premium.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            context.i18n.premium.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubCard(BuildContext context, WidgetRef ref, UserSubscription sub) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  context.i18n.premium.active.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const Icon(Icons.check_circle, color: AppColors.success),
            ],
          ),
          const Gap(16),
          Text(
            sub.planName,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            '${context.i18n.premium.nextBillingDate}: ${dateFormat.format(sub.endDate)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.getTextSecondary(context)),
          ),
          const Gap(4),
          Text(
            '${sub.daysRemaining} ${context.i18n.premium.daysLeft}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
          ),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(context.i18n.premium.cancel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, SubscriptionPlan plan, {bool hasActiveSub = false}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getLine(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  plan.formattedPrice,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              plan.durationLabel,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.getTextSecondary(context)),
            ),
            if (plan.description.isNotEmpty) ...[
              const Gap(8),
              Text(
                plan.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 13,
                ),
              ),
            ],
            const Gap(16),
            ...plan.features.take(3).map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check, color: AppColors.success, size: 16),
                  const Gap(8),
                  Text(f, style: theme.textTheme.bodyMedium),
                ],
              ),
            )),
            const Gap(16),
            PrimaryButton(
              text: context.i18n.premium.subscribe,
              onPressed: hasActiveSub ? null : () => _handleSubscribe(context, ref, plan),
              height: 48,
              backgroundColor: hasActiveSub ? AppColors.greyscale400 : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, UserSubscription sub) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary500.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, color: AppColors.primary500, size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub.planName, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '${dateFormat.format(sub.startDate)} - ${dateFormat.format(sub.endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.getTextSecondary(context)),
                ),
              ],
            ),
          ),
          Text(
            sub.status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: sub.status == 'ACTIVE' ? AppColors.success : AppColors.getTextSecondary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          context.i18n.premium.historyEmpty,
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.i18n.premium.cancel),
        content: Text(context.i18n.premium.cancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.i18n.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(subscriptionRepositoryProvider).cancelSubscription();
              if (success && context.mounted) {
                ref.invalidate(currentSubscriptionProvider);
                ref.invalidate(subscriptionHistoryProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.i18n.premium.canceled), backgroundColor: AppColors.success),
                );
              }
            },
            child: Text(context.i18n.common.yes, style: const TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(BuildContext context, WidgetRef ref, SubscriptionPlan plan) async {
     try {
       // Guard against subscribing if already subscribed
       final currentSub = ref.read(currentSubscriptionProvider).value;
       if (currentSub != null && currentSub.isActive) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('You already have an active subscription.'),
             backgroundColor: AppColors.warning,
           ),
         );
         return;
       }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LoadingCustom(assetName: ImageConstant.loadingIcon, size: 50),
      );

      final service = ref.read(subscriptionRepositoryProvider);
      final success = await service.subscribe(plan.id, planType: plan.planType);

      if (context.mounted) Navigator.of(context).pop();

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Redirecting to payment...'), backgroundColor: AppColors.success),
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
