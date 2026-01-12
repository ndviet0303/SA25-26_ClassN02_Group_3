import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AutoLayout extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AutoLayout({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return
      Container(
          decoration: BoxDecoration(
            color: AppColors.getAutoLayoutBg(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.getLine(context),
              width: 1,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: child
          )
      );
  }
}
