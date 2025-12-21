import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

@immutable
class LinedTextDividerTheme extends ThemeExtension<LinedTextDividerTheme> {
  final Color lineColor;
  final TextStyle textStyle;
  final double thickness;
  final double spacing;
  final EdgeInsets padding;

  const LinedTextDividerTheme({
    required this.lineColor,
    required this.textStyle,
    this.thickness = 1,
    this.spacing = 16,
    this.padding = EdgeInsets.zero,
  });

  static LinedTextDividerTheme of(BuildContext context) =>
      Theme.of(context).extension<LinedTextDividerTheme>() ??
          LinedTextDividerTheme(
            lineColor: Theme.of(context).dividerColor,
            textStyle: Theme.of(context).textTheme.bodyMedium ??
                const TextStyle(fontSize: 14),
          );

  @override
  LinedTextDividerTheme copyWith({
    Color? lineColor,
    TextStyle? textStyle,
    double? thickness,
    double? spacing,
    EdgeInsets? padding,
  }) {
    return LinedTextDividerTheme(
      lineColor: lineColor ?? this.lineColor,
      textStyle: textStyle ?? this.textStyle,
      thickness: thickness ?? this.thickness,
      spacing: spacing ?? this.spacing,
      padding: padding ?? this.padding,
    );
  }

  @override
  LinedTextDividerTheme lerp(
      ThemeExtension<LinedTextDividerTheme>? other, double t) {
    if (other is! LinedTextDividerTheme) return this;
    return LinedTextDividerTheme(
      lineColor: Color.lerp(lineColor, other.lineColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
      thickness: lerpDouble(thickness, other.thickness, t)!,
      spacing: lerpDouble(spacing, other.spacing, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
    );
  }
}
