import 'package:flutter/material.dart';

enum SnackBarType { success, warning, info, error }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
  }) {
    Color bg;
    IconData icon;
    Color iconColor;

    switch (type) {
      case SnackBarType.success:
        bg = Colors.green.shade100;
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case SnackBarType.warning:
        bg = Colors.yellow.shade100;
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
        break;
      case SnackBarType.info:
        bg = Colors.blue.shade100;
        icon = Icons.info;
        iconColor = Colors.blue;
        break;
      case SnackBarType.error:
        bg = Colors.red.shade100;
        icon = Icons.error;
        iconColor = Colors.red;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
