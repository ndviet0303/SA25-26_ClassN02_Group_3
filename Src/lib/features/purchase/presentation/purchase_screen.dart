import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/app_export.dart';
import '../../../../core/constants/app_padding.dart';
import '../application/purchase_state_notifier.dart';
import '../data/repositories/purchase_repository.dart';
import 'widgets/purchase_item.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseAsync = ref.watch(purchaseProvider);
    final purchaseState = ref.watch(purchaseStateProvider);

    return Scaffold(
      body: purchaseAsync.when(
        data: (items) {
          final mappedItems = items.map((item) {
            final isDownloaded = purchaseState.downloadStatus[item.id] ?? item.isDownloaded;
            final isFinished = purchaseState.finishedIds.contains(item.id) || item.isFinished;
            return item.copyWith(
              isDownloaded: isDownloaded,
              isFinished: isFinished,
            );
          }).toList();
          
          if (mappedItems.isEmpty) {
            return _buildEmpty(context);
          }
          return _buildList(context, ref, mappedItems);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, ref, error),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsivePadding.content(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              ImageConstant.purchaseIcon,
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                AppColors.getTextSecondary(context),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your purchased library is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.getText(context),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Purchase books to add them to your library',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getTextSecondary(context),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $error',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.warning,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(purchaseProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List items) {
    return Padding(
      padding: context.responsivePadding(
        horizontalPercent: AppPadding.contentHorizontalPercent,
        topPercent: AppPadding.contentVerticalPercent,
        bottomPercent: 0,
      ),
      child: ListView.separated(
        itemBuilder: (context, index) => PurchaseItemWidget(
          item: items[index],
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 18),
        itemCount: items.length,
      ),
    );
  }
}
