import 'package:flutter/widgets.dart';
import 'package:movie_fe/core/app_export.dart';

class RGap extends StatelessWidget {
  final double? wPercent;
  final double? hPercent;

  const RGap._({this.wPercent, this.hPercent});

  factory RGap.h(double percent) => RGap._(wPercent: percent);

  factory RGap.v(double percent) => RGap._(hPercent: percent);
  
  factory RGap.element(BuildContext context) =>
      RGap._(wPercent: AppPadding.elementSpacingPercent);

  @override
  Widget build(BuildContext context) {
    final w = wPercent != null ? context.responsiveWidth(wPercent!) : 0.0;
    final h = hPercent != null ? context.responsiveHeight(hPercent!) : 0.0;
    return SizedBox(width: w, height: h);
  }
}
