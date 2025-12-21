import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_fe/core/app_export.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    this.borderRadius = 6,
    this.label,
    this.spacing = 12,
    this.textStyle,
    this.duration = const Duration(milliseconds: 200),
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Kích thước ô checkbox (match với viewBox của SVG)
  final double size;

  /// Bo góc (để dùng cho InkWell borderRadius, SVG tự vẽ)
  final double borderRadius;

  /// Text bên phải (optional). Nếu null thì chỉ hiện icon.
  final String? label;

  /// Khoảng cách giữa icon và text
  final double spacing;

  /// Style cho label
  final TextStyle? textStyle;

  /// Thời gian animate khi chuyển SVG
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon SVG có AnimatedSwitcher
            SizedBox(
              width: size,
              height: size,
              child: AnimatedSwitcher(
                duration: duration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: SvgPicture.asset(
                  value
                      ? ImageConstant.imgCheckedIcon
                      : ImageConstant.imgUncheckedIcon,
                  key: ValueKey<bool>(value),
                  width: size,
                  height: size,
                ),
              ),
            ),

            // Label (optional)
            if (label != null) ...[
              SizedBox(width: spacing),
              Text(
                label!,
                style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
