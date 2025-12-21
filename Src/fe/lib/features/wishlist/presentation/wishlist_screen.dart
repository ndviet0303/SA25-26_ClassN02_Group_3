import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/constants/app_padding.dart';
import '../application/wishlist_state_notifier.dart';
import '../repositories/wishlist_repository.dart';
import 'widgets/wishlist_item.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);
    final wishlistState = ref.watch(wishlistStateProvider);

    return Scaffold(
      body: wishlistAsync.when(
        data: (items) {
          final filteredItems = items.where((item) => !wishlistState.removedIds.contains(item.id)).toList();
          if (filteredItems.isEmpty) {
            return _buildEmpty(context);
          }
          return _buildList(context, ref, filteredItems);
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
              ImageConstant.wishlistIcon,
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                AppColors.getTextSecondary(context),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.i18n.wishlist.empty.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.getText(context),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              context.i18n.wishlist.empty.subtitle,
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
            '${context.i18n.wishlist.common.errorPrefix} $error',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.warning,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(wishlistProvider);
            },
            child: Text(context.i18n.wishlist.common.retry),
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
        itemBuilder: (context, index) => WishlistItem(
          movie: items[index],
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 18),
        itemCount: items.length,
      ),
    );
  }
}
