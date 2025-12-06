import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomRangeThumb extends RangeSliderThumbShape {
  final double enabledThumbRadius;
  final double elevation;
  final double pressedElevation;

  const CustomRangeThumb({
    this.enabledThumbRadius = 12,
    this.elevation = 2,
    this.pressedElevation = 4,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool? isPressed,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
  }) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = AppColors.primary500
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, enabledThumbRadius, paint);

      final innerPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, enabledThumbRadius - 4, innerPaint);

    final picture = recorder.endRecording();
    context.canvas.drawPicture(picture);
  }
}
