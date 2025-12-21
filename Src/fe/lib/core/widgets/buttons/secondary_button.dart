import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool hasShadow;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final double elevation;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.hasShadow = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 100,
    this.icon,
    this.padding,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = backgroundColor ?? (isDarkMode ? AppColors.dark4 : AppColors.primary100);
    final labelColor = textColor ?? (isDarkMode ? AppColors.white : AppColors.primary500);

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: labelColor,
            side: BorderSide(
              color: labelColor,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
          ),
          child: _buildButtonContent(labelColor),
        ),
      );
    }

    Widget button = SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: labelColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: elevation,
          padding: padding,
        ),
        child: _buildButtonContent(labelColor),
      ),
    );

    // Add shadow if needed
    if (hasShadow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent(Color labelColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(labelColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTypography.bodyLMedium.copyWith(
              color: labelColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTypography.bodyLBold.copyWith(
        color: labelColor,
      ),
    );
  }
}
