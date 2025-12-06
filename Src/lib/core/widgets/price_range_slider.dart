import 'package:flutter/material.dart';
import '../app_export.dart';
import 'custom_range_thumb.dart';

class PriceRangeSlider extends StatefulWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<RangeValues>? onChanged;

  const PriceRangeSlider({
    super.key,
    required this.values,
    this.min = 0,
    this.max = 1000,
    this.divisions = 100,
    this.onChanged,
  });

  @override
  State<PriceRangeSlider> createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {

  @override
  Widget build(BuildContext context) {

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        rangeThumbShape: const CustomRangeThumb(
          enabledThumbRadius: 12,
          elevation: 2,
          pressedElevation: 4,
        ), // custom nút

        activeTrackColor: AppColors.primary500, // màu thanh active
        inactiveTrackColor: AppColors.getLine(context), // inactive
        overlayColor: AppColors.primary500.withValues(alpha: 0), // tắt overlay

        // showValueIndicator: ShowValueIndicator.alwaysVisible, // hiện value
        valueIndicatorColor: AppColors.primary500,
        valueIndicatorTextStyle: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        )
      ),
      child: RangeSlider(

        values: widget.values,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions, // số bước nhảy
        labels: RangeLabels(
          context.i18n.locale == 'vi'
              ? '${widget.values.start.round()} đ'
              : '\$${widget.values.start.round()}',
          context.i18n.locale == 'vi'
              ? '${widget.values.end.round()} đ'
              : '\$${widget.values.end.round()}',
        ),
        onChanged: (RangeValues values) {
          widget.onChanged?.call(values);
        },
      ),
    );
  }
}
