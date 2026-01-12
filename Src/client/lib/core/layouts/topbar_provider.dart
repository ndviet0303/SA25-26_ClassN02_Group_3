import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../i18n/translations.g.dart';
import '../../routes/app_router.dart';
import '../utils/data/image_constant.dart';

enum TopBarAction {
  notification,
  filter,
  search,
  settings,
  profile,
}

class TopBarState {
  final TopBarAction? primaryAction;
  final TopBarAction? secondaryAction;
  final String title;

  const TopBarState({
    this.primaryAction,
    this.secondaryAction,
    required this.title,
  });
}



final topBarProvider = StateNotifierProvider<TopBarNotifier, TopBarState>(
  (ref) => TopBarNotifier(ref),
);

class TopBarNotifier extends StateNotifier<TopBarState> {
  final Ref _ref;

  TopBarNotifier(this._ref) : super(const TopBarState(title: 'NoZie', primaryAction: TopBarAction.search, secondaryAction: TopBarAction.notification)) {
    // Khởi tạo với title mặc định
  }

  void updateForRoute(String route, BuildContext context) {
    state = _getTopBarConfig(route, context);
  }

  TopBarState _getTopBarConfig(String route, BuildContext context) {

    final t = Translations.of(context);

    switch (route) {
      case AppRouter.home:
        return TopBarState(
          title: t.navigation.home,
          primaryAction: TopBarAction.search,
          secondaryAction: TopBarAction.notification,
        );
      case AppRouter.discover:
        return TopBarState(
          title: t.navigation.discover,
          primaryAction: TopBarAction.search,

        );
      case AppRouter.wishlist:
        return TopBarState(
          title: t.navigation.wishlist,
          primaryAction: TopBarAction.search,
        );
      case AppRouter.purchase:
        return TopBarState(
          title: t.navigation.purchase,
          primaryAction: TopBarAction.search,
        );
      case AppRouter.profile:
        return TopBarState(
          title: t.navigation.profile,
          primaryAction: TopBarAction.settings,
        );
      default:
        return TopBarState(title: t.app.title);
    }
  }

  String getActionIconPath(TopBarAction action) {
    return _actionConfigs[action]?.iconPath ?? '';
  }

  String getActionLabel(TopBarAction action) {
    return _actionConfigs[action]?.label ?? 'Unknown';
  }

  static const Map<TopBarAction, _ActionConfig> _actionConfigs = {
    TopBarAction.notification: _ActionConfig(
      iconPath: ImageConstant.bellIcon,
      label: 'Notifications',
    ),
    TopBarAction.filter: _ActionConfig(
      iconPath: ImageConstant.filterIcon,
      label: 'Filter',
    ),
    TopBarAction.search: _ActionConfig(
      iconPath: ImageConstant.searchIcon,
      label: 'Search',
    ),
    TopBarAction.settings: _ActionConfig(
      iconPath: ImageConstant.moreCircleIcon,
      label: 'Settings',
    ),
    TopBarAction.profile: _ActionConfig(
      iconPath: ImageConstant.profileIcon,
      label: 'Profile',
    ),
  };
}

class _ActionConfig {
  final String iconPath;
  final String label;

  const _ActionConfig({
    required this.iconPath,
    required this.label,
  });
}


// Provider quản lý navigation index
final navIndexProvider = StateProvider<int>((ref) => 0);


