import 'package:flutter/material.dart';

/// Extension để xử lý responsive design cho BuildContext
extension ResponsiveExtensions on BuildContext {
  /// Lấy kích thước màn hình
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Lấy chiều rộng màn hình
  double get screenWidth => screenSize.width;
  
  /// Lấy chiều cao màn hình
  double get screenHeight => screenSize.height;
  
  /// Tính padding theo tỉ lệ phần trăm của màn hình
  EdgeInsets responsivePadding({
    double? leftPercent,
    double? topPercent,
    double? rightPercent,
    double? bottomPercent,
    double? horizontalPercent,
    double? verticalPercent,
    double? allPercent,
  }) {
    if (allPercent != null) {
      final padding = screenWidth * (allPercent / 100);
      return EdgeInsets.all(padding);
    }
    
    double left = 0;
    double top = 0;
    double right = 0;
    double bottom = 0;
    
    if (horizontalPercent != null) {
      left = right = screenWidth * (horizontalPercent / 100);
    }
    if (verticalPercent != null) {
      top = bottom = screenHeight * (verticalPercent / 100);
    }
    
    if (leftPercent != null) {
      left = screenWidth * (leftPercent / 100);
    }
    if (topPercent != null) {
      top = screenHeight * (topPercent / 100);
    }
    if (rightPercent != null) {
      right = screenWidth * (rightPercent / 100);
    }
    if (bottomPercent != null) {
      bottom = screenHeight * (bottomPercent / 100);
    }
    
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }
  
  /// Tính margin theo tỉ lệ phần trăm của màn hình
  EdgeInsets responsiveMargin({
    double? leftPercent,
    double? topPercent,
    double? rightPercent,
    double? bottomPercent,
    double? horizontalPercent,
    double? verticalPercent,
    double? allPercent,
  }) {
    return responsivePadding(
      leftPercent: leftPercent,
      topPercent: topPercent,
      rightPercent: rightPercent,
      bottomPercent: bottomPercent,
      horizontalPercent: horizontalPercent,
      verticalPercent: verticalPercent,
      allPercent: allPercent,
    );
  }
  
  /// Tính kích thước theo tỉ lệ phần trăm của chiều rộng màn hình
  double responsiveWidth(double percent) {
    return screenWidth * (percent / 100);
  }
  
  /// Tính kích thước theo tỉ lệ phần trăm của chiều cao màn hình
  double responsiveHeight(double percent) {
    return screenHeight * (percent / 100);
  }
  
  /// Tính kích thước theo tỉ lệ phần trăm của kích thước nhỏ hơn giữa width và height
  double responsiveSize(double percent) {
    return (screenWidth < screenHeight ? screenWidth : screenHeight) * (percent / 100);
  }
  
  /// Kiểm tra xem có phải màn hình nhỏ không (< 600dp)
  bool get isSmallScreen => screenWidth < 600;
  
  /// Kiểm tra xem có phải màn hình medium không (600dp - 900dp)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;
  
  /// Kiểm tra xem có phải màn hình large không (>= 900dp)
  bool get isLargeScreen => screenWidth >= 900;
  
  /// Trả về responsive value dựa trên kích thước màn hình
  T responsiveValue<T>({
    required T small,
    T? medium,
    T? large,
  }) {
    if (isLargeScreen && large != null) {
      return large;
    } else if (isMediumScreen && medium != null) {
      return medium;
    } else {
      return small;
    }
  }
}

/// Utility class để tính toán responsive design
class ResponsiveUtils {
  /// Tính padding theo tỉ lệ phần trăm của màn hình
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double? leftPercent,
    double? topPercent,
    double? rightPercent,
    double? bottomPercent,
    double? horizontalPercent,
    double? verticalPercent,
    double? allPercent,
  }) {
    return context.responsivePadding(
      leftPercent: leftPercent,
      topPercent: topPercent,
      rightPercent: rightPercent,
      bottomPercent: bottomPercent,
      horizontalPercent: horizontalPercent,
      verticalPercent: verticalPercent,
      allPercent: allPercent,
    );
  }
  
  /// Tính kích thước theo tỉ lệ phần trăm
  static double responsiveWidth(BuildContext context, double percent) {
    return context.responsiveWidth(percent);
  }
  
  /// Tính kích thước theo tỉ lệ phần trăm
  static double responsiveHeight(BuildContext context, double percent) {
    return context.responsiveHeight(percent);
  }
  
  /// Tính kích thước theo tỉ lệ phần trăm
  static double responsiveSize(BuildContext context, double percent) {
    return context.responsiveSize(percent);
  }
}
