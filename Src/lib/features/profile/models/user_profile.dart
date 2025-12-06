import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.country,
    required this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String country;
  final String avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      country: json['country'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'country': country,
      'avatarUrl': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? country,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  static const empty = UserProfile(
    id: '',
    fullName: '',
    username: '',
    email: '',
    phone: '',
    dateOfBirth: '',
    country: '',
    avatarUrl: '',
  );

  @override
  List<Object?> get props => [
        id,
        fullName,
        username,
        email,
        phone,
        dateOfBirth,
        country,
        avatarUrl,
      ];
}


