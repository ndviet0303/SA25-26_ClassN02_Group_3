import 'package:flutter/material.dart';
import 'package:movie_fe/features/auth/forgot_password/presentation/widgets/otp_input_field.dart';

class OtpInputGroup extends StatelessWidget {
  const OtpInputGroup({
    super.key,
    required this.length,
    required this.controllers,
    required this.focusNodes,
    required this.currentIndex,
    required this.onChanged,
    required this.onTap,
    required this.onKeyEvent,
  });

  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final int currentIndex;
  final void Function(String value, int index) onChanged;
  final void Function(int index) onTap;
  final bool Function(int index, KeyEvent event) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: List.generate(length, (index) {
        return OtpInputField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          index: index,
          isFocused: currentIndex == index && focusNodes[index].hasFocus,
          onChanged: (value) => onChanged(value, index),
          onTap: () => onTap(index),
          onKeyEvent: (event) => onKeyEvent(index, event),
        );
      }),
    );
  }
}
