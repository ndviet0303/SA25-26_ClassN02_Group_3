import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_padding.dart';
import '../utils/data/image_constant.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../extension/responsive_extensions.dart';
import 'topbar_provider.dart';
import '../../i18n/translations.g.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final topBarNotifier = ref.read(topBarProvider.notifier);
    
    return Container(
      padding: ResponsivePadding.bottomBar(context),
      decoration: BoxDecoration(
        color: AppColors.getBackground(context),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _handleTabTap(ref, topBarNotifier, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.getBackground(context),
          selectedItemColor: AppColors.primary500,
          unselectedItemColor: AppColors.greyscale500,
          selectedLabelStyle: AppTypography.bodyXSBold.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTypography.bodyXSBold,
          elevation: 0,
          items: _buildBottomNavItems(context, currentIndex),
        ),
      ),
    );
  }

  
  void _handleTabTap(WidgetRef ref, TopBarNotifier topBarNotifier, int index) {
    // Chỉ cập nhật nav index và gọi callback
    // MainLayout sẽ xử lý navigation thực tế
    ref.read(navIndexProvider.notifier).state = index;
    onTap(index);
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(BuildContext context, int currentIndex) {
    final t = Translations.of(context);
    
    return _navigationItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = currentIndex == index;

      return BottomNavigationBarItem(
        icon: _buildNavIcon(context, item.icon, isSelected),
        label: _getLocalizedLabel(item.labelKey, t),
      );
    }).toList();
  }

  Widget _buildNavIcon(BuildContext context, String iconPath, bool isSelected) {
    return Container(
      padding: ResponsivePadding.icon(context),
      child: SvgPicture.asset(
        iconPath,
        width: context.responsiveWidth(5.9), // ~22px trên màn hình 375px
        height: context.responsiveWidth(5.9),
        colorFilter: ColorFilter.mode(
          isSelected 
              ? AppColors.primary500 
              : AppColors.getTextSecondary(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }

  String _getLocalizedLabel(String labelKey, Translations t) {
    switch (labelKey) {
      case 'home':
        return t.navigation.home;
      case 'discover':
        return t.navigation.discover;
      case 'wishlist':
        return t.navigation.wishlist;
      case 'purchase':
        return t.navigation.purchase;
      case 'profile':
        return t.navigation.profile;
      default:
        return labelKey;
    }
  }

  static const List<_NavItem> _navigationItems = [
    _NavItem(icon: ImageConstant.homeIcon, labelKey: 'home'),
    _NavItem(icon: ImageConstant.discoverIcon, labelKey: 'discover'),
    _NavItem(icon: ImageConstant.wishlistIcon, labelKey: 'wishlist'),
    _NavItem(icon: ImageConstant.purchaseIcon, labelKey: 'purchase'),
    _NavItem(icon: ImageConstant.profileIcon, labelKey: 'profile'),
  ];
}

class _NavItem {
  final String icon;
  final String labelKey;

  const _NavItem({
    required this.icon,
    required this.labelKey,
  });
}
