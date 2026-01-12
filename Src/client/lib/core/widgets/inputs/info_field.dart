import 'package:flutter/material.dart';
import 'package:movie_fe/core/theme/app_colors.dart';
import 'package:movie_fe/core/theme/app_typography.dart';

class InfoField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final bool isRequired;
  final bool isEnabled;
  final bool isReadOnly;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? focusedBackgroundColor;
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
  final double? cursorHeight;
  final Color? cursorColor;
  final double? inputHeight;

  const InfoField({
    super.key,
    this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.isRequired = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.contentPadding,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.focusedBackgroundColor,
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
    this.cursorHeight,
    this.cursorColor,
    this.inputHeight,
  });

  @override
  State<InfoField> createState() => _InfoFieldState();
}

class _InfoFieldState extends State<InfoField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscured = false;
  String? _errorText;
  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _isObscured = widget.isPassword;
    _focusListener = () {
      if (!mounted) return;
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    };
    _focusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    // Always remove listener regardless of ownership
    _focusNode.removeListener(_focusListener);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _validateField(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTypography.bodyMSemibold.copyWith(
                  color: widget.labelColor ?? AppColors.getText(context),
                  fontSize: widget.labelFontSize ?? widget.fontSize ?? 14,
                  fontWeight:
                  widget.labelFontWeight ??
                      widget.fontWeight ??
                      FontWeight.w600,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),

              ],
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Text Field
        AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          height: widget.inputHeight,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.showBorder
                ? Border.all(
              color: _getBorderColor(),
              width: widget.borderWidth,
            )
                : null,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: _isObscured,
            obscuringCharacter: "●",
            enabled: widget.isEnabled,
            readOnly: widget.isReadOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            cursorHeight: widget.cursorHeight,
            cursorColor: widget.cursorColor,
            onChanged: (value) {
              _validateField(value);
              widget.onChanged?.call(value);
            },
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: AppTypography.bodyMRegular.copyWith(
              color: widget.textColor ?? AppColors.getText(context),
              fontSize: widget.inputFontSize ?? widget.fontSize ?? 14,
              fontWeight:
              widget.inputFontWeight ??
                  widget.fontWeight ??
                  FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.bodyMRegular.copyWith(
                color: widget.hintColor ?? AppColors.getTextSecondary(context),
                fontSize: widget.inputFontSize ?? widget.fontSize ?? 14,
                fontWeight:
                widget.inputFontWeight ??
                    widget.fontWeight ??
                    FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: _buildSuffixIcon(),
              contentPadding:
              widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              border: InputBorder.none,
              counterText: '',
            ),
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
          Container(height: 1, color: AppColors.primary500),
        ],
      ],
    );
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

  Color _getBackgroundColor() {
    if (_isFocused) {
      return widget.focusedBackgroundColor ?? AppColors.getSurface(context);
    }
    return widget.backgroundColor ?? Colors.transparent;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility : Icons.visibility_off,
          color: AppColors.primary500,
          size: 28,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}