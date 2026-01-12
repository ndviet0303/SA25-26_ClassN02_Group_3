import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/data/image_constant.dart';

class CustomDropdown extends StatefulWidget {
  final String? label;
  final String? value;
  final String? hint;
  final List<DropdownItem> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderWidth;
  final Color? labelColor;
  final Color? hintColor;
  final Color? textColor;
  final double? fontSize;
  final double? labelFontSize;
  final double? inputFontSize;
  final FontWeight? fontWeight;
  final FontWeight? labelFontWeight;
  final FontWeight? inputFontWeight;
  final bool showBorder;
  final bool showDivider;
  final Duration animationDuration;
  final Curve animationCurve;
  final Widget? suffixIcon;

  const CustomDropdown({
    super.key,
    this.label,
    this.value,
    this.hint,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.width,
    this.height = 56,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1.0,
    this.labelColor,
    this.hintColor,
    this.textColor,
    this.fontSize,
    this.labelFontSize,
    this.inputFontSize = 18,
    this.fontWeight = FontWeight.w800,
    this.labelFontWeight,
    this.inputFontWeight,
    this.showBorder = false,
    this.showDivider = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.suffixIcon,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isFocused = false;
  String? _errorText;

  void _validateField(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  Color _getBorderColor() {
    if (_errorText != null) {
      return widget.errorBorderColor ?? AppColors.red;
    }
    if (_isFocused) {
      return widget.focusedBorderColor ?? AppColors.primary500;
    }
    return widget.borderColor ?? AppColors.getSurface(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTypography.bodyMSemibold.copyWith(
                  color: widget.labelColor ?? AppColors.getText(context),
                  fontSize: widget.labelFontSize ?? widget.fontSize ?? 14,
                  fontWeight: widget.labelFontWeight ?? widget.fontWeight ?? FontWeight.w600,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '',
                  style: AppTypography.bodyMSemibold.copyWith(
                    color: AppColors.red,
                    fontSize: widget.labelFontSize ?? widget.fontSize ?? 14,
                    fontWeight: widget.labelFontWeight ?? widget.fontWeight ?? FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Dropdown Field
        AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.showBorder ? Border.all(
              color: _getBorderColor(),
              width: widget.borderWidth,
            ) : null,
          ),
          child: DropdownButtonFormField<String>(
            initialValue: widget.value != null && widget.items.any((item) => item.value == widget.value) 
                ? widget.value 
                : null,
            hint: widget.hint != null 
                ? Text(
                    widget.hint!,
                    style: AppTypography.bodyMRegular.copyWith(
                      color: widget.hintColor ?? AppColors.getTextSecondary(context),
                      fontSize: widget.inputFontSize ?? widget.fontSize ?? 14,
                      fontWeight: widget.inputFontWeight ?? widget.fontWeight ?? FontWeight.w400,
                    ),
                  )
                : null,
            items: widget.items.map((item) {
              return DropdownMenuItem<String>(
                value: item.value,
                child: Text(
                  item.label,
                  style: AppTypography.bodyMRegular.copyWith(
                    color: widget.textColor ?? AppColors.getText(context),
                    fontSize: widget.inputFontSize ?? widget.fontSize ?? 14,
                    fontWeight: widget.inputFontWeight ?? widget.fontWeight ?? FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              _validateField(value);
              widget.onChanged(value);
            },
            validator: widget.validator,
            decoration: InputDecoration(
              contentPadding: widget.contentPadding ?? const EdgeInsets.only(
                left: 0,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              border: InputBorder.none,
              suffixIcon: widget.suffixIcon,
            ),
            dropdownColor: widget.backgroundColor ?? AppColors.getSurface(context),
            icon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Transform.scale(
                scale: 1.2,
                child: SvgPicture.asset(
                  ImageConstant.dropdownIcon,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            style: AppTypography.bodyMRegular.copyWith(
              color: widget.textColor ?? AppColors.getText(context),
              fontSize: widget.inputFontSize ?? widget.fontSize ?? 14,
              fontWeight: widget.inputFontWeight ?? widget.fontWeight ?? FontWeight.w400,
            ),
            menuMaxHeight: 300,
            onTap: () {
              setState(() {
                _isFocused = true;
              });
            },
          ),
        ),

        // Error Text
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: AppTypography.bodySBRegular.copyWith(
              color: AppColors.red,
              fontSize: 12,
            ),
          ),
        ],
        
        // Line Divider
        if (widget.showDivider) ...[
          Container(
            height: 1,
            color: AppColors.primary500,
          ),
        ],
      ],
    );
  }
}

class DropdownItem {
  final String value;
  final String label;

  const DropdownItem({
    required this.value,
    required this.label,
  });
}


