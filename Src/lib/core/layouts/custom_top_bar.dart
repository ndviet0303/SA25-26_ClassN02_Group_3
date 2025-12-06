import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_fe/core/app_export.dart';
import '../utils/data/image_constant.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  const CustomTopBar({
    super.key,
    this.title = 'NoZie',
    this.actions,
    this.onNotificationTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.getBackground(context),
      centerTitle: false,
      title: _buildTitle(context),
      actions: _buildActions(context),
      actionsIconTheme: const IconThemeData(
        size: 24,
      ),
      // Sử dụng padding đồng bộ cho actions
      actionsPadding: ResponsivePadding.horizontal(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          ImageConstant.logoMovie,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(
            AppColors.primary500,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: context.responsiveWidth(4)), // Responsive spacing
        Text(
          title,
          style: AppTypography.h5.copyWith(
            color: AppColors.getText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return actions ?? [
      Container(
        margin: ResponsivePadding.elementSpacing(context),
        child: IconButton(
          icon: SvgPicture.asset(
            ImageConstant.searchIcon,
            width: context.responsiveWidth(5.3), // ~20px trên màn hình 375px
            height: context.responsiveWidth(5.3),
            colorFilter: ColorFilter.mode(
              AppColors.getText(context),
              BlendMode.srcIn,
            ),
          ),
          onPressed: onSearchTap ?? () {
            // Default search action
          },
        ),
      ),
      SizedBox(width: context.responsiveWidth(2.1)), // Responsive spacing
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
