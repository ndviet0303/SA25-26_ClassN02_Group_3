import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'custom_top_bar.dart';
import 'custom_bottom_nav_bar.dart';
import '../theme/app_colors.dart';
import '../../routes/app_router.dart';
import 'topbar_provider.dart';
import '../../routes/navigation_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final bool showAppBar;
  final bool showBottomNav;
  final List<Widget>? actions;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  const MainLayout({
    super.key,
    required this.child,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.actions,
    this.onNotificationTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final topBarState = ref.watch(topBarProvider);
    final topBarNotifier = ref.read(topBarProvider.notifier);

    _syncNavigationState(ref, currentPath, topBarNotifier, context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: showAppBar 
          ? CustomTopBar(
              title: topBarState.title,
              actions: _buildTopBarActions(ref, topBarState, context),
              onNotificationTap: onNotificationTap,
              onSearchTap: onSearchTap,
            )
          : null,
      body: child,
      bottomNavigationBar: showBottomNav 
          ? CustomBottomNavBar(
              onTap: (index) => _handleNavigation(context, index),
            )
          : null,
    );
  }

  void _syncNavigationState(
    WidgetRef ref, 
    String currentPath, 
    TopBarNotifier topBarNotifier,
    BuildContext context
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      topBarNotifier.updateForRoute(currentPath, context);
    });
  }

  void _handleNavigation(BuildContext context, int index) {
    final route = NavigationUtils.getRouteByIndex(index);
    if (route != null) {
      context.push(route);
    }
  }


  List<Widget> _buildTopBarActions(WidgetRef ref, TopBarState topBarState, BuildContext context) {
    final actions = <Widget>[];
    final topBarNotifier = ref.read(topBarProvider.notifier);

    _addActionIfExists(actions, topBarState.primaryAction, topBarNotifier, 'Primary', context);
    _addActionIfExists(actions, topBarState.secondaryAction, topBarNotifier, 'Secondary', context);

    return actions;
  }

  void _addActionIfExists(
    List<Widget> actions,
    TopBarAction? action,
    TopBarNotifier notifier,
    String actionType,
    BuildContext context,
  ) {
    if (action != null) {
      actions.add(
        IconButton(
          icon: SvgPicture.asset(
            notifier.getActionIconPath(action),
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColors.getText(context),
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => _handleTopBarAction(notifier, action, actionType, context),
        ),
      );
    }
  }

  void _handleTopBarAction(TopBarNotifier notifier, TopBarAction action, String actionType, BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    
    switch (action) {
      case TopBarAction.search:
        // Check if we're on wishlist or purchase page, then search only in that collection
        if (currentPath == AppRouter.wishlist) {
          context.push(
            AppRouter.search,
            extra: {'searchSource': 'wishlist'},
          );
        } else if (currentPath == AppRouter.purchase) {
          context.push(
            AppRouter.search,
            extra: {'searchSource': 'purchase'},
          );
        } else {
          context.push(AppRouter.search);
        }
        break;
      case TopBarAction.notification:
        context.push(AppRouter.notification);
        break;
      case TopBarAction.filter:
        // TODO: filter
        break;
      case TopBarAction.settings:
        // TODO:
        break;
      case TopBarAction.profile:
        // TODO:

        break;
    }
  }



}
