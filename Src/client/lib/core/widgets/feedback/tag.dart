import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class Tag extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool showBorder;
  final Duration animationDuration;
  final Curve animationCurve;

  const Tag({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.textColor = AppColors.primary500, // mặc định
    this.selectedTextColor = AppColors.white,
    this.borderColor,
    this.selectedBorderColor,
    this.borderWidth = 1.5,
    this.borderRadius = 100.0,
    this.padding,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
    this.showBorder = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final tagWidget = AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? (selectedBackgroundColor ?? AppColors.primary500)
            : (backgroundColor ?? AppColors.getSurface(context)),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(
          color: isSelected 
              ? (selectedBorderColor ?? AppColors.primary500)
              : (borderColor ?? AppColors.primary500),
          width: borderWidth,
        ) : null,
      ),
      child: AnimatedDefaultTextStyle(
        duration: animationDuration,
        style: AppTypography.bodyMRegular.copyWith(
          color: isSelected 
              ? (selectedTextColor ?? AppColors.getText(context))
              : (textColor ?? AppColors.primary500),
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w500,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: tagWidget,
      );
    }

    return tagWidget;
  }
}
