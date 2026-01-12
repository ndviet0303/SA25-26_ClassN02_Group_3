import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movie_fe/core/theme/app_colors.dart';
import 'package:movie_fe/core/theme/app_typography.dart';
import 'package:movie_fe/core/utils/data/image_constant.dart';
class RadioBox extends StatelessWidget {
  final String title;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final double borderWidth;
  final Color? textColor;
  final Color? selectedTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double radioSize;
  final double radioBorderWidth;
  final Color? radioBorderColor;
  final Color? selectedRadioBorderColor;
  final double innerDotSize;
  final Color? innerDotColor;
  final Duration animationDuration;
  final Curve animationCurve;
  final double? iconSpacing;

  const RadioBox({
    super.key,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.onTap,
    this.width,
    this.height = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.borderRadius = 16,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.borderColor,
    this.selectedBorderColor,
    this.borderWidth = 0,
    this.textColor,
    this.selectedTextColor,
    this.fontSize = 16,
    this.fontWeight,
    this.radioSize = 24,
    this.radioBorderWidth = 3,
    this.radioBorderColor,
    this.selectedRadioBorderColor,
    this.innerDotSize = 12,
    this.innerDotColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.iconSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final defaultBorderColor = AppColors.primary500;
    final defaultSelectedBorderColor = AppColors.primary500;
    final defaultRadioBackgroundColor = isDarkMode ? AppColors.dark2 : AppColors.white;
    final defaultTextColor = isDarkMode ? AppColors.white : AppColors.greyscale900;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: animationDuration,
        curve: animationCurve,
        width: width ?? double.infinity,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderWidth > 0 ? Border.all(
            color: isSelected
                ? (selectedBorderColor ?? defaultSelectedBorderColor)
                : (borderColor ?? defaultBorderColor),
            width: borderWidth,
          ) : null,
        ),
        child: Row(
          children: [

            SizedBox(
              width: radioSize,
              height: radioSize,
              child: Stack(
                children: [
                  // nhấn
                  AnimatedOpacity(
                    opacity: isSelected ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(
                      ImageConstant.radioUnIcon,
                      width: radioSize,
                      height: radioSize,
                      colorFilter: ColorFilter.mode(
                        radioBorderColor ?? defaultBorderColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                  AnimatedOpacity( // icon
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(
                      ImageConstant.radioIcon,
                      width: radioSize,
                      height: radioSize,
                      colorFilter: ColorFilter.mode(
                        selectedRadioBorderColor ?? defaultSelectedBorderColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: iconSpacing ?? 16),

            // Title
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.bodyLSemibold.copyWith(
                  color: textColor ?? defaultTextColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
                child: Text(title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}