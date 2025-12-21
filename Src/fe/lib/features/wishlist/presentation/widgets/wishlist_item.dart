import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/models/movie_item.dart';
import 'package:movie_fe/core/widgets/image_utils.dart';
import '../../repositories/wishlist_repository.dart';
import '../../../../routes/app_router.dart';
import '../../../../core/repositories/movie_repository.dart';

enum WishlistAction {
  remove,
  share,
  about,
}

class WishlistItem extends ConsumerStatefulWidget {
  const WishlistItem({
    super.key,
    required this.movie,
  });

  final MovieItem movie;

  @override
  ConsumerState<WishlistItem> createState() => _WishlistItemState();
}

class _WishlistItemState extends ConsumerState<WishlistItem> {
  final GlobalKey _buttonKey = GlobalKey();

  void _showActionMenu(BuildContext context, WidgetRef ref) {
    final RenderBox? button =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;

    final buttonPosition = button.localToGlobal(Offset.zero);
    final buttonSize = button.size;
    final screenSize = MediaQuery.of(context).size;
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);
    final theme = Theme.of(context);

    const menuWidth = 200.0;
    final buttonRight = buttonPosition.dx + buttonSize.width;
    final menuLeft = (buttonRight - menuWidth).clamp(8.0, screenSize.width - menuWidth - 8);
    final menuTop = buttonPosition.dy + buttonSize.height + 8;
    final menuRight = screenSize.width - menuLeft - menuWidth;

    showMenu<WishlistAction>(
      context: context,
      useRootNavigator: true,
      color: AppColors.getModalBackground(context),
      position: RelativeRect.fromLTRB(
        menuLeft,
        menuTop,
        menuRight,
        menuTop,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: secondaryText.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      elevation: 0,
      items: [
        PopupMenuItem<WishlistAction>(
          value: WishlistAction.remove,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  ImageConstant.paperNegativeIcon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    textColor,
                    BlendMode.srcIn,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    context.i18n.wishlist.item.menu.removeFromWishlist,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<WishlistAction>(
          value: WishlistAction.share,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  ImageConstant.sendIcon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    textColor,
                    BlendMode.srcIn,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    context.i18n.wishlist.item.menu.share,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<WishlistAction>(
          value: WishlistAction.about,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  ImageConstant.infoSquareIcon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    textColor,
                    BlendMode.srcIn,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    context.i18n.wishlist.item.menu.aboutMovie,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value != null && context.mounted) {
        _handleAction(context, ref, value);
      }
    });
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    WishlistAction action,
  ) async {
    switch (action) {
      case WishlistAction.remove:
        try {
          final repo = ref.read(wishlistRepositoryProvider);
          await repo.removeFromWishlist(widget.movie.id);
          if (context.mounted) {
            ToastNotification.showSuccess(
              context,
              message: context.i18n.wishlist.item.snackbar.removed,
              duration: const Duration(seconds: 2),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ToastNotification.showError(
              context,
              message: '${context.i18n.wishlist.common.errorPrefix} ${e.toString()}',
              duration: const Duration(seconds: 2),
            );
          }
        }
        break;
      case WishlistAction.share:
        if (context.mounted) {
          ToastNotification.showInfo(
            context,
            message: context.i18n.wishlist.item.snackbar.shareComing,
            duration: const Duration(seconds: 2),
          );
        }
        break;
      case WishlistAction.about:
        try {
          final movieRepo = ref.read(movieRepoProvider);
          final movie = await movieRepo.getMovieDetail(widget.movie.id);
          if (movie != null && context.mounted) {
            context.push(
              '${AppRouter.movieInfo}/${movie.id}',
              extra: {'movie': movie},
            );
          } else if (context.mounted) {
            ToastNotification.showError(
              context,
              message: context.i18n.wishlist.common.movieNotFound,
              duration: const Duration(seconds: 2),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ToastNotification.showError(
              context,
              message: '${context.i18n.wishlist.common.errorPrefix} ${e.toString()}',
              duration: const Duration(seconds: 2),
            );
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    return InkWell(
      onTap: () {
        context.push('${AppRouter.movie}/${widget.movie.id}');
      },
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: NetworkOrAssetImage(
            imageUrl: widget.movie.imageUrl,
            width: 80,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              if (widget.movie.rating != null) ...[
                const Gap(8),
                Row(
                  children: [
                    SvgPicture.asset(
                      ImageConstant.groupIcon,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        secondaryText,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      widget.movie.rating?.toStringAsFixed(1) ?? '0.0',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
              if (widget.movie.price != null) ...[
                const Gap(8),
                Text(
                  '\$${widget.movie.price?.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          key: _buttonKey,
          icon: Icon(
            Icons.more_vert,
            color: secondaryText,
            size: 24,
          ),
          onPressed: () => _showActionMenu(context, ref),
        ),
      ],
      ),
    );
  }
}


