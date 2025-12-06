import 'package:flutter/material.dart';
import 'package:movie_fe/core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    this.radius = 28,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 👇 set cứng cho light / dark
    final Color bg = isDark ? AppColors.dark2 : AppColors.white;
    final Color border = isDark ? AppColors.dark4 : AppColors.greyscale200;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border, width: 1),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
