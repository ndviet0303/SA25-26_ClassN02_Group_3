import 'package:flutter/material.dart';
import 'package:movie_fe/core/app_export.dart';

/// Constants cho padding values trong toàn bộ app
/// Đảm bảo tính nhất quán và đồng bộ giữa các components
class AppPadding {
  // Private constructor để prevent instantiation
  AppPadding._();

  /// Horizontal padding cho các layout chính (topbar, bottom bar, content)
  /// ~24px trên màn hình 375px (iPhone SE)
  /// ~32px trên màn hình 414px (iPhone 11)
  /// ~48px trên màn hình 768px (iPad)
  static const double horizontalPercent = 6.4;

  /// Vertical padding cho các layout chính
  /// ~16px trên màn hình 800px
  static const double verticalPercent = 2.0;

  /// Top padding cho topbar
  static const double topBarTopPercent = 1.0;

  /// Top padding cho bottom bar
  static const double bottomBarTopPercent = 0.2;

  /// Bottom padding cho bottom bar
  static const double bottomBarBottomPercent = 0.0;

  /// Padding cho icon trong navigation items
  /// ~8px trên màn hình 375px
  static const double iconPaddingPercent = 2.1;

  /// Spacing giữa các elements
  /// ~8px trên màn hình 375px
  static const double elementSpacingPercent = 2.1;

  /// Content padding cho các screens
  /// Sử dụng cùng horizontal padding với layout
  static const double contentHorizontalPercent = horizontalPercent;

  /// Content padding vertical cho các screens
  static const double contentVerticalPercent = 2.5;

  /// Card padding
  static const double cardPaddingPercent = 4.0;

  /// Button padding
  static const double buttonPaddingPercent = 3.0;

  /// Input field padding
  static const double inputPaddingPercent = 3.5;
}

/// Responsive padding utilities
class ResponsivePadding {
  ResponsivePadding._();

  /// Standard horizontal padding cho layout components
  static EdgeInsets horizontal(BuildContext context) {
    return context.responsivePadding(
      horizontalPercent: AppPadding.horizontalPercent,
    );
  }

  /// Standard vertical padding cho layout components
  static EdgeInsets vertical(BuildContext context) {
    return context.responsivePadding(
      verticalPercent: AppPadding.verticalPercent,
    );
  }

  /// Standard padding cho layout components (horizontal + vertical)
  static EdgeInsets standard(BuildContext context) {
    return context.responsivePadding(
      horizontalPercent: AppPadding.horizontalPercent,
      verticalPercent: AppPadding.verticalPercent,
    );
  }

  /// TopBar padding (horizontal + top)
  static EdgeInsets topBar(BuildContext context) {
    return context.responsivePadding(
      leftPercent: AppPadding.horizontalPercent,
      topPercent: AppPadding.topBarTopPercent,
      rightPercent: AppPadding.horizontalPercent,
      bottomPercent: 0,
    );
  }

  /// BottomBar padding (horizontal + bottom)
  static EdgeInsets bottomBar(BuildContext context) {
    return context.responsivePadding(
      leftPercent: AppPadding.horizontalPercent,
      topPercent: AppPadding.bottomBarTopPercent,
      rightPercent: AppPadding.horizontalPercent,
      bottomPercent: AppPadding.bottomBarBottomPercent,
    );
  }

  /// Content padding cho screens
  static EdgeInsets content(BuildContext context) {
    return context.responsivePadding(
      horizontalPercent: AppPadding.contentHorizontalPercent,
      verticalPercent: AppPadding.contentVerticalPercent,
    );
  }

  /// Card padding
  static EdgeInsets card(BuildContext context) {
    return context.responsivePadding(
      allPercent: AppPadding.cardPaddingPercent,
    );
  }

  /// Button padding
  static EdgeInsets button(BuildContext context) {
    return context.responsivePadding(
      horizontalPercent: AppPadding.buttonPaddingPercent,
      verticalPercent: AppPadding.buttonPaddingPercent,
    );
  }

  /// Input field padding
  static EdgeInsets input(BuildContext context) {
    return context.responsivePadding(
      horizontalPercent: AppPadding.inputPaddingPercent,
      verticalPercent: AppPadding.inputPaddingPercent,
    );
  }

  /// Icon padding cho navigation
  static EdgeInsets icon(BuildContext context) {
    return context.responsivePadding(
      allPercent: AppPadding.iconPaddingPercent,
    );
  }

  /// Element spacing
  static EdgeInsets elementSpacing(BuildContext context) {
    return context.responsivePadding(
      allPercent: AppPadding.elementSpacingPercent,
    );
  }
}
