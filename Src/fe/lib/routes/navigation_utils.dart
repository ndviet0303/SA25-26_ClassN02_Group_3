import 'app_router.dart';

class NavigationUtils {
  static const List<String> bottomNavRoutes = [
    AppRouter.home,
    AppRouter.discover,
    AppRouter.wishlist,
    AppRouter.purchase,
    AppRouter.profile,
  ];

  static String? getRouteByIndex(int index) {
    if (index >= 0 && index < bottomNavRoutes.length) {
      return bottomNavRoutes[index];
    }
    return null;
  }

  static int? getIndexByRoute(String route) {
    final index = bottomNavRoutes.indexOf(route);
    return index >= 0 ? index : null;
  }
}
