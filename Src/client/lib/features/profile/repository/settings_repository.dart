import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/shared_prefs_provider.dart';
import '../models/language_settings.dart';
import '../models/notification_settings.dart';
import '../models/preferences.dart';
import '../models/security_settings.dart';
import '../models/user_profile.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/customer_repository.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/auth_models.dart';

class SettingsRepository {
  SettingsRepository(this._prefs, this._authRepository, this._ref);

  static const _keyProfile = 'profile:user_profile';
  static const _keyNotification = 'profile:notification';
  static const _keyPreferences = 'profile:preferences';
  static const _keySecurity = 'profile:security';
  static const _keyLanguage = 'profile:language';

  final SharedPreferences _prefs;
  final AuthRepository _authRepository;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);

  String _getKey(String baseKey) {
    if (_userId == null) return baseKey;
    return '$baseKey:$_userId';
  }

  Future<UserProfile> fetchProfile() async {
    // Try to get from Customer Service first for full data
    try {
      final userId = _ref.read(currentUserIdProvider);
      if (userId != null) {
        final customerRepo = _ref.read(customerRepositoryProvider);
        final customerProfile = await customerRepo.getCustomerByUserId(int.parse(userId));
        if (customerProfile != null) {
          final authUser = _ref.read(authStateNotifierProvider).user;
          final profile = UserProfile(
            id: userId,
            fullName: customerProfile.fullName ?? authUser?.fullName ?? '',
            username: authUser?.username ?? '',
            email: authUser?.email ?? '',
            phoneNumber: customerProfile.phoneNumber ?? authUser?.phone ?? '',
            dateOfBirth: customerProfile.dateOfBirth ?? authUser?.dateOfBirth ?? '',
            country: customerProfile.country ?? authUser?.country ?? '',
            avatarUrl: customerProfile.avatarUrl ?? authUser?.avatarUrl ?? '',
            gender: customerProfile.gender ?? '',
            bio: customerProfile.bio ?? '',
          );
          await _prefs.setString(_getKey(_keyProfile), jsonEncode(profile.toJson()));
          return profile;
        }
      }
    } catch (e) {
      debugPrint('[SettingsRepository] Failed to fetch customer profile, falling back: $e');
    }

    // Fallback to Auth state
    final authUser = _ref.read(authStateNotifierProvider).user;
    if (authUser != null) {
      final profile = UserProfile(
        id: authUser.id,
        fullName: authUser.fullName ?? '',
        username: authUser.username,
        email: authUser.email,
        phoneNumber: authUser.phone ?? '',
        dateOfBirth: authUser.dateOfBirth ?? '',
        country: authUser.country ?? '',
        avatarUrl: authUser.avatarUrl ?? '',
        gender: '',
        bio: '',
      );
      // Sync local storage
      await _prefs.setString(_getKey(_keyProfile), jsonEncode(profile.toJson()));
      return profile;
    }

    final jsonString = _prefs.getString(_getKey(_keyProfile));
    if (jsonString == null) {
      const fallback = UserProfile(
        id: 'user_1',
        fullName: 'Noah Noah',
        username: 'nhat.noah.dev',
        email: 'vnhat.dev@gmail.com',
        phoneNumber: '+84 123 456 789',
        dateOfBirth: '1990-01-01',
        country: 'Vietnam',
        avatarUrl: '',
        gender: 'male',
        bio: 'I love movies and coding!',
      );
      await _prefs.setString(_getKey(_keyProfile), jsonEncode(fallback.toJson()));
      return fallback;
    }
    return UserProfile.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final accessToken = _ref.read(accessTokenProvider);
    if (accessToken == null) throw Exception('Not authenticated');

    // 1. Check if email changed - handled separately in UI as per request, 
    // but keeping here as safety check
    final currentAuthUser = _ref.read(authStateNotifierProvider).user;
    if (currentAuthUser != null && currentAuthUser.email != profile.email) {
      debugPrint('[SettingsRepository] Email changed, updating via Identity Service');
      await _authRepository.updateEmail(profile.email, accessToken);
    }

    // 2. Update other profile fields via Customer Service
    final customerRepo = _ref.read(customerRepositoryProvider);
    final customerProfile = await customerRepo.getCustomerByUserId(int.parse(profile.id));
    
    if (customerProfile != null) {
      debugPrint('[SettingsRepository] Updating customer profile via Customer Service');
      await customerRepo.updateCustomer(
        customerProfile.id,
        CustomerUpdateRequest(
          fullName: profile.fullName,
          phoneNumber: profile.phoneNumber,
          country: profile.country,
          dateOfBirth: profile.dateOfBirth,
          avatarUrl: profile.avatarUrl,
          gender: profile.gender,
          bio: profile.bio,
        ),
      );
    }

    // 3. Save locally
    await _prefs.setString(_getKey(_keyProfile), jsonEncode(profile.toJson()));

    // 4. Sync with AuthState
    if (currentAuthUser != null) {
      final updatedAuthUser = AuthUser(
        id: currentAuthUser.id,
        username: currentAuthUser.username,
        email: profile.email,
        fullName: profile.fullName,
        phone: profile.phoneNumber,
        country: profile.country,
        dateOfBirth: profile.dateOfBirth,
        avatarUrl: profile.avatarUrl,
        roles: currentAuthUser.roles,
      );
      _ref.read(authStateNotifierProvider.notifier).updateUser(updatedAuthUser);
    }

    _log('Profile updated locally and via services', profile.toJson());
    return profile;
  }

  Future<NotificationSettings> fetchNotificationSettings() async {
    final jsonString = _prefs.getString(_getKey(_keyNotification));
    if (jsonString == null) {
      final defaults = NotificationSettings.defaults;
      await _prefs.setString(_getKey(_keyNotification), jsonEncode(defaults.toJson()));
      return defaults;
    }
    return NotificationSettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<NotificationSettings> updateNotificationSettings(
    NotificationSettings settings,
  ) async {
    await _prefs.setString(_getKey(_keyNotification), jsonEncode(settings.toJson()));
    _log('Notification settings updated', settings.toJson());
    return settings;
  }

  Future<Preferences> fetchPreferences() async {
    final jsonString = _prefs.getString(_getKey(_keyPreferences));
    if (jsonString == null) {
      final defaults = Preferences.defaults;
      await _prefs.setString(_getKey(_keyPreferences), jsonEncode(defaults.toJson()));
      return defaults;
    }
    return Preferences.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  Future<Preferences> updatePreferences(Preferences preferences) async {
    await _prefs.setString(_getKey(_keyPreferences), jsonEncode(preferences.toJson()));
    _log('Preferences updated', preferences.toJson());
    return preferences;
  }

  Future<SecuritySettings> fetchSecuritySettings() async {
    final jsonString = _prefs.getString(_getKey(_keySecurity));
    if (jsonString == null) {
      final defaults = SecuritySettings.defaults;
      await _prefs.setString(_getKey(_keySecurity), jsonEncode(defaults.toJson()));
      return defaults;
    }
    return SecuritySettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<SecuritySettings> updateSecuritySettings(SecuritySettings settings) async {
    await _prefs.setString(_getKey(_keySecurity), jsonEncode(settings.toJson()));
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
    final jsonString = _prefs.getString(_getKey(_keyLanguage));
    if (jsonString == null) {
      final defaults = LanguageSettings.defaults;
      await _prefs.setString(_getKey(_keyLanguage), jsonEncode(defaults.toJson()));
      return defaults;
    }
    return LanguageSettings.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<LanguageSettings> updateLanguage(LanguageSettings settings) async {
    await _prefs.setString(_getKey(_keyLanguage), jsonEncode(settings.toJson()));
    _log('Language updated', settings.toJson());
    return settings;
  }

  Future<void> clearUserData() async {
    try {
      await _prefs.remove(_getKey(_keyProfile));
      await _prefs.remove(_getKey(_keyNotification));
      await _prefs.remove(_getKey(_keyPreferences));
      await _prefs.remove(_getKey(_keySecurity));
      await _prefs.remove(_getKey(_keyLanguage));
      _log('User data cleared', {});
    } catch (error) {
      debugPrint('[SettingsRepository] Failed to clear user data: $error');
    }
  }

  void _log(String message, Map<String, dynamic> payload) {
    debugPrint('[SettingsRepository] $message: $payload');
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  // Watch current user ID to ensure repository is recreated or aware of user changes
  ref.watch(currentUserIdProvider);
  
  final prefs = ref.watch(sharedPreferencesProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return SettingsRepository(prefs, authRepo, ref);
});
