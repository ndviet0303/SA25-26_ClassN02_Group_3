import 'package:equatable/equatable.dart';

class SecuritySettings extends Equatable {
  const SecuritySettings({
    required this.rememberMe,
    required this.biometricId,
    required this.faceId,
    required this.smsAuthenticator,
    required this.googleAuthenticator,
    required this.sessions,
  });

  final bool rememberMe;
  final bool biometricId;
  final bool faceId;
  final bool smsAuthenticator;
  final bool googleAuthenticator;
  final List<DeviceSession> sessions;

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    final sessionsJson = json['sessions'] as List<dynamic>? ?? const [];
    return SecuritySettings(
      rememberMe: json['rememberMe'] as bool? ?? true,
      biometricId: json['biometricId'] as bool? ?? true,
      faceId: json['faceId'] as bool? ?? true,
      smsAuthenticator: json['smsAuthenticator'] as bool? ?? false,
      googleAuthenticator: json['googleAuthenticator'] as bool? ?? true,
      sessions: sessionsJson
          .map((e) => DeviceSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rememberMe': rememberMe,
      'biometricId': biometricId,
      'faceId': faceId,
      'smsAuthenticator': smsAuthenticator,
      'googleAuthenticator': googleAuthenticator,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }

  SecuritySettings copyWith({
    bool? rememberMe,
    bool? biometricId,
    bool? faceId,
    bool? smsAuthenticator,
    bool? googleAuthenticator,
    List<DeviceSession>? sessions,
  }) {
    return SecuritySettings(
      rememberMe: rememberMe ?? this.rememberMe,
      biometricId: biometricId ?? this.biometricId,
      faceId: faceId ?? this.faceId,
      smsAuthenticator: smsAuthenticator ?? this.smsAuthenticator,
      googleAuthenticator: googleAuthenticator ?? this.googleAuthenticator,
      sessions: sessions ?? this.sessions,
    );
  }

  static const defaults = SecuritySettings(
    rememberMe: true,
    biometricId: true,
    faceId: true,
    smsAuthenticator: false,
    googleAuthenticator: true,
    sessions: DeviceSession.defaults,
  );

  @override
  List<Object?> get props => [
        rememberMe,
        biometricId,
        faceId,
        smsAuthenticator,
        googleAuthenticator,
        sessions,
      ];
}

class DeviceSession extends Equatable {
  const DeviceSession({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.lastActive,
    required this.platform,
    this.isCurrent = false,
  });

  final String id;
  final String name;
  final String location;
  final String status;
  final String lastActive;
  final DevicePlatform platform;
  final bool isCurrent;

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      status: json['status'] as String? ?? '',
      lastActive: json['lastActive'] as String? ?? '',
      platform: DevicePlatformX.fromString(json['platform'] as String?),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'status': status,
      'lastActive': lastActive,
      'platform': platform.toShortString(),
      'isCurrent': isCurrent,
    };
  }

  DeviceSession copyWith({
    String? status,
    String? lastActive,
    bool? isCurrent,
  }) {
    return DeviceSession(
      id: id,
      name: name,
      location: location,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      platform: platform,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  static const defaults = <DeviceSession>[
    DeviceSession(
      id: 'device-iphone',
      name: 'iPhone 16 Plus',
      location: 'Hanoi, Vietnam',
      status: 'Active now',
      lastActive: 'Just now',
      platform: DevicePlatform.ios,
      isCurrent: true,
    ),
  ];


  @override
  List<Object?> get props => [
        id,
        name,
        location,
        status,
        lastActive,
        platform,
        isCurrent,
      ];
}

enum DevicePlatform { ios, android, macos, web }

extension DevicePlatformX on DevicePlatform {
  String toShortString() {
    switch (this) {
      case DevicePlatform.ios:
        return 'ios';
      case DevicePlatform.android:
        return 'android';
      case DevicePlatform.macos:
        return 'macos';
      case DevicePlatform.web:
        return 'web';
    }
  }

  static DevicePlatform fromString(String? value) {
    switch (value) {
      case 'android':
        return DevicePlatform.android;
      case 'macos':
        return DevicePlatform.macos;
      case 'web':
        return DevicePlatform.web;
      case 'ios':
      default:
        return DevicePlatform.ios;
    }
  }
}


