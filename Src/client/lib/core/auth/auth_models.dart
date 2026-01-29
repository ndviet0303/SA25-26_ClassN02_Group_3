import 'package:equatable/equatable.dart';

/// Holds the authentication tokens from the API
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
  });

  final String accessToken;
  final String refreshToken;
  final String? userId;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, userId];
}

/// Authenticated user information from API
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    this.roles = const [],
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.country,
    this.dateOfBirth,
  });

  final String id;
  final String username;
  final String email;
  final List<String> roles;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String? country;
  final String? dateOfBirth;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'country': country,
      'dateOfBirth': dateOfBirth,
    };
  }

  @override
  List<Object?> get props => [id, username, email, roles, fullName, avatarUrl];
}

/// Login request payload
class LoginRequest {
  const LoginRequest({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

/// Register request payload
class RegisterRequest {
  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
    this.country,
    this.dateOfBirth,
    this.gender,
    this.age,
    this.genres,
    this.avatarUrl,
  });

  final String username;
  final String email;
  final String password;
  final String? fullName;
  final String? phone;
  final String? country;
  final String? dateOfBirth;
  final String? gender;
  final String? age;
  final List<String>? genres;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (country != null) 'country': country,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (genres != null) 'genres': genres,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

/// Update Profile request payload
class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.fullName,
    this.phone,
    this.country,
    this.dateOfBirth,
    this.gender,
    this.age,
    this.genres,
    this.avatarUrl,
  });

  final String? fullName;
  final String? phone;
  final String? country;
  final String? dateOfBirth;
  final String? gender;
  final String? age;
  final List<String>? genres;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (country != null) 'country': country,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (genres != null) 'genres': genres,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

/// Refresh token request payload
class RefreshRequest {
  const RefreshRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

/// Logout request payload
class LogoutRequest {
  const LogoutRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  final bool success;
  final String? message;
  final T? data;
  final String? error;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
    );
  }
}

/// Combined authentication state
class AuthState extends Equatable {
  const AuthState({
    this.tokens,
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AuthTokens? tokens;
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  bool get isLoggedIn => tokens != null && tokens!.accessToken.isNotEmpty;

  String? get currentUserId => user?.id ?? tokens?.userId;

  String? get accessToken => tokens?.accessToken;

  AuthState copyWith({
    AuthTokens? tokens,
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearTokens = false,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      tokens: clearTokens ? null : (tokens ?? this.tokens),
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [tokens, user, isLoading, error];
}
