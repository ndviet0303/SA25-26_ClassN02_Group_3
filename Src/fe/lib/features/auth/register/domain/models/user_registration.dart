class UserReg {
  final String? gender;
  final String? age;
  final List<String> genres;
  final UserProfile profile;
  final UserAccount account;

  const UserReg({
    this.gender,
    this.age,
    this.genres = const [],
    required this.profile,
    required this.account,
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'age': age,
      'genres': genres,
      'profile': profile.toJson(),
      'account': account.toJson(),
    };
  }

  factory UserReg.fromJson(Map<String, dynamic> json) {
    return UserReg(
      gender: json['gender'],
      age: json['age'],
      genres: List<String>.from(json['genres'] ?? []),
      profile: UserProfile.fromJson(json['profile'] ?? const <String, dynamic>{}),
      account: UserAccount.fromJson(json['account'] ?? const <String, dynamic>{}),
    );
  }
}

class UserProfile {
  final String fullName;
  final String phone;
  final String dateOfBirth;
  final String country;

  const UserProfile({
    required this.fullName,
    required this.phone,
    required this.dateOfBirth,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'country': country,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class UserAccount {
  final String username;
  final String email;
  final String password;
  final bool rememberMe;

  const UserAccount({
    required this.username,
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rememberMe: json['rememberMe'] ?? false,
    );
  }
}


