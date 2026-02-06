import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../auth/auth_providers.dart';
import '../config/api_config.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(Dio(), ref);
});

/// Customer Repository - REST API based
/// Handles customer profile, interests, watchlist, and viewing history
class CustomerRepository {
  CustomerRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // ============= PROFILE =============

  /// Get customer by ID
  Future<CustomerProfile?> getCustomerById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.customerServiceUrl}/$id',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return CustomerProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get customer by user ID
  Future<CustomerProfile?> getCustomerByUserId(int userId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.customerServiceUrl}/user/$userId',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return CustomerProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update customer profile
  Future<CustomerProfile?> updateCustomer(int id, CustomerUpdateRequest request) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.customerServiceUrl}/$id',
        data: request.toJson(),
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return CustomerProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============= INTERESTS =============

  /// Get customer interests (genre preferences)
  Future<List<String>> getInterests(int customerId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.customerServiceUrl}/$customerId/interests',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data is List) {
          return data.map<String>((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Set customer interests (replace all)
  Future<void> setInterests(int customerId, List<String> genreSlugs) async {
    try {
      await _dio.put(
        '${ApiConfig.customerServiceUrl}/$customerId/interests',
        data: {'genres': genreSlugs},
        options: Options(headers: _headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Add a single interest
  Future<void> addInterest(int customerId, String genreSlug) async {
    try {
      await _dio.put(
        '${ApiConfig.customerServiceUrl}/$customerId/interests/$genreSlug',
        options: Options(headers: _headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a single interest
  Future<void> removeInterest(int customerId, String genreSlug) async {
    try {
      await _dio.delete(
        '${ApiConfig.customerServiceUrl}/$customerId/interests/$genreSlug',
        options: Options(headers: _headers),
      );
    } catch (e) {
      rethrow;
    }
  }

  // ============= VIEWING HISTORY =============

  /// Get viewing history
  Future<List<ViewingHistoryItem>> getViewingHistory(int customerId, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.customerServiceUrl}/$customerId/viewing-history',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((e) => ViewingHistoryItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Record a viewing event
  Future<void> recordViewing(int customerId, String movieId, {int? progress, int? duration}) async {
    try {
      await _dio.post(
        '${ApiConfig.customerServiceUrl}/$customerId/viewing-history',
        data: {
          'movieId': movieId,
          if (progress != null) 'progress': progress,
          if (duration != null) 'duration': duration,
        },
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Silently ignore errors for viewing tracking
    }
  }

  // ============= SUBSCRIPTION STATUS =============

  /// Update subscription status
  Future<void> updateSubscriptionStatus(int customerId, bool isSubscribed) async {
    try {
      await _dio.patch(
        '${ApiConfig.customerServiceUrl}/$customerId/subscription',
        queryParameters: {'isSubscribed': isSubscribed},
        options: Options(headers: _headers),
      );
    } catch (e) {
      rethrow;
    }
  }
}

// ============= MODELS =============

class CustomerProfile {
  final int id;
  final int userId;
  final String? fullName;
  final String? phoneNumber;
  final String? country;
  final String? dateOfBirth;
  final String? gender;
  final String? avatarUrl;
  final String? bio;
  final bool isSubscribed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerProfile({
    required this.id,
    required this.userId,
    this.fullName,
    this.phoneNumber,
    this.country,
    this.dateOfBirth,
    this.gender,
    this.avatarUrl,
    this.bio,
    this.isSubscribed = false,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      country: json['country'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      isSubscribed: json['isSubscribed'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'country': country,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'avatarUrl': avatarUrl,
    'bio': bio,
    'isSubscribed': isSubscribed,
  };
}

class CustomerUpdateRequest {
  final String? fullName;
  final String? phoneNumber;
  final String? country;
  final String? dateOfBirth;
  final String? gender;
  final String? bio;
  final String? avatarUrl;

  CustomerUpdateRequest({
    this.fullName,
    this.phoneNumber,
    this.country,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    if (fullName != null) 'fullName': fullName,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (country != null) 'country': country,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (gender != null) 'gender': gender,
    if (bio != null) 'bio': bio,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}

class ViewingHistoryItem {
  final String movieId;
  final String? movieTitle;
  final String? moviePoster;
  final int? progress;
  final int? duration;
  final DateTime? watchedAt;

  ViewingHistoryItem({
    required this.movieId,
    this.movieTitle,
    this.moviePoster,
    this.progress,
    this.duration,
    this.watchedAt,
  });

  factory ViewingHistoryItem.fromJson(Map<String, dynamic> json) {
    return ViewingHistoryItem(
      movieId: json['movieId'] ?? '',
      movieTitle: json['movieTitle'],
      moviePoster: json['moviePoster'],
      progress: json['progress'],
      duration: json['duration'],
      watchedAt: json['watchedAt'] != null ? DateTime.parse(json['watchedAt']) : null,
    );
  }

  double get progressPercent {
    if (progress == null || duration == null || duration == 0) return 0;
    return (progress! / duration!).clamp(0.0, 1.0);
  }
}

// ============= PROVIDERS =============

final customerProfileProvider = FutureProvider.autoDispose<CustomerProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(customerRepositoryProvider).getCustomerByUserId(int.parse(userId));
});

final customerInterestsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final profile = await ref.watch(customerProfileProvider.future);
  if (profile == null) return [];
  return ref.watch(customerRepositoryProvider).getInterests(profile.id);
});

final viewingHistoryProvider = FutureProvider.autoDispose<List<ViewingHistoryItem>>((ref) async {
  final profile = await ref.watch(customerProfileProvider.future);
  if (profile == null) return [];
  return ref.watch(customerRepositoryProvider).getViewingHistory(profile.id);
});
