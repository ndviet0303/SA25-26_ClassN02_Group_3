import 'package:flutter/widgets.dart';
import 'package:movie_fe/i18n/translations.g.dart';

extension LocalizationExtension on BuildContext {
  /// Hierarchical i18n access method
  Translations get i18n => t;
}