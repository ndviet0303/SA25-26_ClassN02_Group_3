import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/language_notifier.dart';
import '../notifiers/notification_notifier.dart';
import '../notifiers/payment_notifier.dart';
import '../notifiers/preferences_notifier.dart';
import '../notifiers/profile_notifier.dart';
import '../notifiers/security_notifier.dart';
import '../repository/settings_repository.dart';

/// Service to handle user logout by clearing all user data
class LogoutService {
  static Future<void> logout(WidgetRef ref) async {
    try {
      // Clear all user data from SharedPreferences
      final repository = ref.read(settingsRepositoryProvider);
      await repository.clearUserData();

      // Invalidate all Riverpod providers to reset their state
      ref.invalidate(profileNotifierProvider);
      ref.invalidate(notificationNotifierProvider);
      ref.invalidate(preferencesNotifierProvider);
      ref.invalidate(securityNotifierProvider);
      ref.invalidate(languageNotifierProvider);
      ref.invalidate(paymentNotifierProvider);
      
      debugPrint('[LogoutService] User data cleared and providers invalidated');
    } catch (error) {
      debugPrint('[LogoutService] Error during logout: $error');
    }
  }
}
