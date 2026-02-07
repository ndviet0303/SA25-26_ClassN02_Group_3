import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_export.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/repositories/subscription_repository.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Refresh subscription status automatically when landing on this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(currentSubscriptionProvider);
      ref.invalidate(hasSubscriptionProvider);
      ref.invalidate(subscriptionHistoryProvider);
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 80,
                ),
              ),
              const Gap(32),
              Text(
                'Payment Successful!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              const Text(
                'Your subscription has been activated successfully. You can now enjoy all premium features.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.greyscale600),
              ),
              const Gap(40),
              PrimaryButton(
                text: 'Back to Home',
                onPressed: () {
                  // Final safeguard: also go home
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
