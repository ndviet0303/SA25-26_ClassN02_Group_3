import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/features/profile/models/payment_method.dart';
import 'package:movie_fe/features/profile/notifiers/payment_notifier.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentNotifierProvider);
    final methods = paymentState.value ?? const <PaymentMethod>[];
    final selectedId = methods.firstWhere(
      (method) => method.isDefault,
      orElse: () => methods.isNotEmpty ? methods.first : const PaymentMethod(
        id: '',
        label: '',
        brand: '',
        last4: '',
        isDefault: false,
      ),
    ).id;
    final notifier = ref.read(paymentNotifierProvider.notifier);
    final t = context.i18n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.profile.payment.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ContentWrappers.page(
              context,
              child: paymentState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    t.profile.payment.loadError(error: error.toString()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warning,
                        ),
                  ),
                ),
                data: (_) => Column(
                  children: [
                    for (var i = 0; i < methods.length; i++) ...[
                      InkWell(
                        onTap: () => notifier.setDefault(methods[i].id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                ImageConstant.visaIcon,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  (methods[i].brand.isNotEmpty ? methods[i].brand : t.purchase.checkout.labels.visa),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.getText(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Radio<String>(
                                value: methods[i].id,
                                groupValue: selectedId,
                                onChanged: (_) => notifier.setDefault(methods[i].id),
                                activeColor: AppColors.primary500,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (i != methods.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: AppColors.getText(context).withOpacity(0.08),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.getText(context).withOpacity(0.08),
              ),
              Padding(
                padding: ResponsivePadding.content(context).copyWith(top: 26, bottom: 26),
                child: PrimaryButton(
                  text: t.common.addNew,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  textColor: Colors.white,
                  onPressed: () {
                    ToastNotification.showInfo(
                      context,
                      message: t.profile.payment.comingSoon,
                      duration: const Duration(seconds: 3),
                    );
                  },
                  hasShadow: true,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


