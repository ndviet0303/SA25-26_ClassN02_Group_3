import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    required this.avatarUrl,
    required this.bio,
  });

  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;
  final String gender;
  final String country;
  final String avatarUrl;
  final String bio;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      country: json['country'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'country': country,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? country,
    String? avatarUrl,
    String? bio,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }

  static const empty = UserProfile(
    id: '',
    fullName: '',
    username: '',
    email: '',
    phoneNumber: '',
    dateOfBirth: '',
    gender: '',
    country: '',
    avatarUrl: '',
    bio: '',
  );

  @override
  List<Object?> get props => [
        id,
        fullName,
        username,
        email,
        phoneNumber,
        dateOfBirth,
        gender,
        country,
        avatarUrl,
        bio,
      ];
}


