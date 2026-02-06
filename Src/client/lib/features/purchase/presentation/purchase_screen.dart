import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_export.dart';
import '../../subscription/presentation/widgets/premium_tab_content.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.i18n.premium.title),
        centerTitle: false,
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
      ),
      body: const PremiumTabContent(),
    );
  }
}
