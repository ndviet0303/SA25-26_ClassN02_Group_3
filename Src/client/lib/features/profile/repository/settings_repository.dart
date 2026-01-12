import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/shared_prefs_provider.dart';
import '../models/language_settings.dart';
import '../models/notification_settings.dart';
import '../models/payment_method.dart';
import '../models/preferences.dart';
import '../models/security_settings.dart';
import '../models/user_profile.dart';

class SettingsRepository {
  SettingsRepository(this._prefs, {FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const _keyProfile = 'profile:user_profile';
  static const _keyNotification = 'profile:notification';
  static const _keyPreferences = 'profile:preferences';
  static const _keySecurity = 'profile:security';
  static const _keyLanguage = 'profile:language';
  static const _keyPayments = 'profile:payments';

  final SharedPreferences _prefs;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<UserProfile> fetchProfile() async {
    final jsonString = _prefs.getString(_keyProfile);
    if (jsonString == null) {
      const fallback = UserProfile(
        id: 'user_1',
        fullName: 'Noah Noah',
        username: 'nhat.noah.dev',
        email: 'vnhat.dev@gmail.com',
        phone: '+84 123 456 789',
        dateOfBirth: '01/01/1990',
        country: 'vn',
        avatarUrl: '',
      );
      await _prefs.setString(_keyProfile, jsonEncode(fallback.toJson()));
      return fallback;
    }
    return UserProfile.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
    _log('Profile updated', profile.toJson());
    await _syncProfileToFirestore(profile);
    return profile;
  }

  Future<NotificationSettings> fetchNotificationSettings() async {
    final jsonString = _prefs.getString(_keyNotification);
    if (jsonString == null) {
      final defaults = NotificationSettings.defaults;
      await _prefs.setString(_keyNotification, jsonEncode(defaults.toJson()));
      return defaults;
    }
    return NotificationSettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<NotificationSettings> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    await _prefs.setString(_keyNotification, jsonEncode(settings.toJson()));
    _log('Notification settings updated', settings.toJson());
    return settings;
  }

  Future<Preferences> fetchPreferences() async {
    final jsonString = _prefs.getString(_keyPreferences);
    if (jsonString == null) {
      final defaults = Preferences.defaults;
      await _prefs.setString(_keyPreferences, jsonEncode(defaults.toJson()));
      return defaults;
    }
    return Preferences.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<Preferences> updatePreferences(Preferences preferences) async {
    await _prefs.setString(_keyPreferences, jsonEncode(preferences.toJson()));
    _log('Preferences updated', preferences.toJson());
    return preferences;
  }

  Future<SecuritySettings> fetchSecuritySettings() async {
    final jsonString = _prefs.getString(_keySecurity);
    if (jsonString == null) {
      final defaults = SecuritySettings.defaults;
      await _prefs.setString(_keySecurity, jsonEncode(defaults.toJson()));
      return defaults;
    }
    return SecuritySettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<SecuritySettings> updateSecuritySettings(SecuritySettings settings) async {
    await _prefs.setString(_keySecurity, jsonEncode(settings.toJson()));
    _log('Security settings updated', settings.toJson());
    return settings;
  }

  Future<SecuritySettings> signOutDevice(String deviceId) async {
    final current = await fetchSecuritySettings();
    final updatedSessions = current.sessions
        .where((element) => element.id != deviceId)
        .toList();
    final updated = current.copyWith(sessions: updatedSessions);
    _log('Signed out device $deviceId', {
      'remainingSessions': updated.sessions.map((e) => e.toJson()).toList(),
    });
    return updateSecuritySettings(updated);
  }

  Future<SecuritySettings> signOutAllDevices() async {
    final current = await fetchSecuritySettings();
    final updated = current.copyWith(sessions: const []);
    _log('Signed out all devices', {});
    return updateSecuritySettings(updated);
  }

  Future<LanguageSettings> fetchLanguageSettings() async {
    final jsonString = _prefs.getString(_keyLanguage);
    if (jsonString == null) {
      final defaults = LanguageSettings.defaults;
      await _prefs.setString(_keyLanguage, jsonEncode(defaults.toJson()));
      return defaults;
    }
    return LanguageSettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<LanguageSettings> updateLanguage(LanguageSettings settings) async {
    await _prefs.setString(_keyLanguage, jsonEncode(settings.toJson()));
    _log('Language updated', settings.toJson());
    return settings;
  }

  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    final jsonString = _prefs.getString(_keyPayments);
    if (jsonString == null) {
      final defaults = PaymentMethod.sampleMethods;
      await _prefs.setString(
        _keyPayments,
        jsonEncode(defaults.map((e) => e.toJson()).toList()),
      );
      return defaults;
    }
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PaymentMethod>> setDefaultPayment(String id) async {
    final current = await fetchPaymentMethods();
    final updated = current
        .map((e) => e.copyWith(isDefault: e.id == id))
        .toList(growable: false);
    await _prefs.setString(
      _keyPayments,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    _log('Default payment set', {'id': id});
    return updated;
  }

  Future<void> clearUserData() async {
    try {
      await _prefs.remove(_keyProfile);
      await _prefs.remove(_keyNotification);
      await _prefs.remove(_keyPreferences);
      await _prefs.remove(_keySecurity);
      await _prefs.remove(_keyLanguage);
      await _prefs.remove(_keyPayments);
      _log('User data cleared', {});
    } catch (error) {
      debugPrint('[SettingsRepository] Failed to clear user data: $error');
    }
  }

  void _log(String message, Map<String, dynamic> payload) {
    debugPrint('[SettingsRepository] $message: $payload');
  }

  Future<void> _syncProfileToFirestore(UserProfile profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final data = {
        'displayName': profile.fullName,
        'username': profile.username,
        'email': profile.email,
        'phone': profile.phone,
        'dateOfBirth': profile.dateOfBirth,
        'country': profile.country,
        'avatarUrl': profile.avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    } catch (error) {
      debugPrint('[SettingsRepository] Failed to sync to Firestore: $error');
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});


