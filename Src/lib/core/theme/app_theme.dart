import 'package:flutter/material.dart';
import 'package:movie_fe/core/extension/lined_text_divider_theme_extensions.dart';
import 'package:movie_fe/core/theme/app_colors.dart';
import 'package:movie_fe/core/theme/app_typography.dart';

class AppTheme {
  // Light theme
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary500,        // primary khi sáng
      brightness: Brightness.light,
      secondary: AppColors.secondary500,
      surface: AppColors.white
    ),
    extensions: [
      LinedTextDividerTheme(lineColor: AppColors.greyscale200,textStyle: AppTypography.bodyXLMedium.copyWith(color: AppColors.greyscale700) ),
    ],
    dividerColor: AppColors.greyscale200,
    textTheme: TextTheme(
      // Display
      displayLarge:  AppTypography.h1,
      displayMedium: AppTypography.h2,
      displaySmall:  AppTypography.h3,

      // Headline
      headlineLarge:  AppTypography.h4,
      headlineMedium: AppTypography.h5,
      headlineSmall:  AppTypography.h6,

      // Title (map bodyXL)
      titleLarge:  AppTypography.bodyXLRegular,
      titleMedium: AppTypography.bodyXLSemibold,
      titleSmall:  AppTypography.bodyXLMedium,

      // Body
      bodyLarge:  AppTypography.bodyLRegular,
      bodyMedium: AppTypography.bodyMRegular,
      bodySmall:  AppTypography.bodySBRegular,

      // Label (cho text rất nhỏ hoặc caption, nút)
      labelLarge:  AppTypography.bodyLSemibold,
      labelMedium: AppTypography.bodyMSemibold,
      labelSmall:  AppTypography.bodyXSRegular,
    ).apply(
      bodyColor: AppColors.greyscale900,
      displayColor: AppColors.greyscale900,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,   // màu button sáng
        foregroundColor: Colors.white,  // chữ trắng
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );

  // Dark theme
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary500,      // primary khi tối
      brightness: Brightness.dark,
      surface: AppColors.dark1
    ),
    extensions: [
      LinedTextDividerTheme(lineColor: AppColors.dark4,textStyle: AppTypography.bodyXLMedium.copyWith(color: AppColors.greyscale300) ),
    ],
    dividerColor: AppColors.dark4,
    textTheme: TextTheme(
      // Display
      displayLarge:  AppTypography.h1,
      displayMedium: AppTypography.h2,
      displaySmall:  AppTypography.h3,

      // Headline
      headlineLarge:  AppTypography.h4,
      headlineMedium: AppTypography.h5,
      headlineSmall:  AppTypography.h6,

      // Title (map bodyXL)
      titleLarge:  AppTypography.bodyXLRegular,
      titleMedium: AppTypography.bodyXLSemibold,
      titleSmall:  AppTypography.bodyXLMedium,

      // Body
      bodyLarge:  AppTypography.bodyLRegular,
      bodyMedium: AppTypography.bodyMRegular,
      bodySmall:  AppTypography.bodySBRegular,

      // Label (cho text rất nhỏ hoặc caption, nút)
      labelLarge:  AppTypography.bodyLSemibold,
      labelMedium: AppTypography.bodyMSemibold,
      labelSmall:  AppTypography.bodyXSRegular,
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500, // màu button tối
        foregroundColor: Colors.black,  // chữ đen
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark1,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
