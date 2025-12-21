import 'package:flutter/material.dart';
import '../../app_export.dart';

/// Wrapper component để áp dụng padding đồng bộ cho content pages
/// Đảm bảo tất cả content pages có cùng padding với topbar và bottom bar
class ContentWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool useSafeArea;
  final bool scrollable;

  const ContentWrapper({
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
    this.scrollable = false,
  });

  /// Standard content wrapper với responsive padding
  const ContentWrapper.standard({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.scrollable = false,
  }) : padding = null;

  /// Content wrapper cho full screen content
  const ContentWrapper.fullScreen({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.scrollable = false,
  }) : padding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final contentPadding = padding ?? ResponsivePadding.content(context);
    
    Widget content = Padding(
      padding: contentPadding,
      child: child,
    );

    if (scrollable) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    if (useSafeArea) {
      content = SafeArea(
        child: content,
      );
    }

    return content;
  }
}

/// Specialized wrapper cho different content types
class ContentWrappers {
  ContentWrappers._();

  /// Standard page content với responsive padding
  static Widget page(BuildContext context, {required Widget child}) {
    return ContentWrapper.standard(
      useSafeArea: true,
      scrollable: true,
      child: child,
    );
  }

  /// Modal/Dialog content với responsive padding
  static Widget modal(BuildContext context, {required Widget child}) {
    return ContentWrapper(
      padding: ResponsivePadding.card(context),
      useSafeArea: false,
      scrollable: true,
      child: child,
    );
  }

  /// Form content với responsive padding
  static Widget form(BuildContext context, {required Widget child}) {
    return ContentWrapper(
      padding: ResponsivePadding.content(context),
      useSafeArea: true,
      scrollable: true,
      child: child,
    );
  }

  /// List content với responsive padding
  static Widget list(BuildContext context, {required Widget child}) {
    return ContentWrapper(
      padding: ResponsivePadding.content(context),
      useSafeArea: true,
      scrollable: true,
      child: child,
    );
  }
}
