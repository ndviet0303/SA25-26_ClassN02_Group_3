import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_fe/core/app_export.dart';

class OtpInputField extends StatelessWidget {
  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.isFocused,
    required this.onChanged,
    required this.onTap,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final bool isFocused;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final bool Function(KeyEvent) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Focus(
        onKeyEvent: (_, e) {
          if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.backspace) {
            return onKeyEvent(e) ? KeyEventResult.handled : KeyEventResult.ignored;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          style: theme.headlineLarge,
          keyboardType: TextInputType.none,
          textInputAction: TextInputAction.next,
          maxLength: 1,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onTap: () {
            onTap();
            // Nếu ô đã có số, select all để user có thể gõ đè
            if (controller.text.isNotEmpty) {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            }
          },
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: isFocused
                ? AppColors.trOrange
                : isDark
                    ? AppColors.dark2
                    : AppColors.greyscale50,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppColors.dark4 : AppColors.greyscale200,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary500,
                width: 2,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
