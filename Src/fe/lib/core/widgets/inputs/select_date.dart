import 'package:flutter/material.dart';
import '../../app_export.dart';

Future<DateTime?> pickDate(BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime now = DateTime.now();
  final DateTime init = initialDate ?? now.subtract(const Duration(days: 6570));
  final DateTime first = firstDate ?? DateTime(1900);
  final DateTime last = lastDate ?? now;

  return showDatePicker(
    context: context,
    initialDate: init,
    firstDate: first,
    lastDate: last,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).brightness == Brightness.dark
              ? ColorScheme.dark(
                  primary: AppColors.primary500,
                  onPrimary: AppColors.white,
                  surface: AppColors.dark2,
                  onSurface: AppColors.white,
                )
              : ColorScheme.light(
                  primary: AppColors.primary500,
                  onPrimary: AppColors.white,
                  surface: AppColors.white,
                  onSurface: AppColors.greyscale900,
                ),
        ),
        child: child!,
      );
    },
  );
}

String formatDateDDMMYYYY(DateTime date) {
  final String d = date.day.toString().padLeft(2, '0');
  final String m = date.month.toString().padLeft(2, '0');
  final String y = date.year.toString();
  return "$d/$m/$y";
}


