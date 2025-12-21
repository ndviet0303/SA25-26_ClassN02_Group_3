import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_fe/core/app_export.dart';

class DateUtil {
  static String formatRelativeDate(DateTime time,BuildContext context) {
    DateTime now = DateTime.now();
    Duration diff = now.difference(time);
    final t = context.i18n;
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return t.notification.today;
    } else if (diff.inDays < 7) {
      return "${diff.inDays} ${t.notification.dayAgo}";
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }
}
