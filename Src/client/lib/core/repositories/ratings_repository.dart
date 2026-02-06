import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../auth/auth_providers.dart';
import '../config/api_config.dart';

final ratingsRepositoryProvider = Provider<RatingsRepository>((ref) {
  return RatingsRepository(Dio(), ref);
});

/// Ratings Repository - REST API based
/// Handles movie ratings and reviews (UC13)
class RatingsRepository {
  RatingsRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Rate a movie (UC13: POST /api/movies/{id}/rate)
  /// 
  /// [movieId] - The movie ID to rate
  /// [rating] - Rating value (typically 1-10 or 1-5)
  /// [review] - Optional review text
  Future<RatingResult> rateMovie(String movieId, int rating, {String? review}) async {
    if (_userId == null) {
      return RatingResult(success: false, error: 'User not authenticated');
    }

    try {
      final response = await _dio.post(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/rate',
        data: {
          'userId': int.parse(_userId!),
          'rating': rating,
          if (review != null && review.isNotEmpty) 'review': review,
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return RatingResult(
          success: true,
          data: MovieRating.fromJson(data),
          message: response.data['message'] ?? 'Rating submitted',
        );
      }
      return RatingResult(success: false, error: 'Failed to submit rating');
    } on DioException catch (e) {
      return RatingResult(
        success: false,
        error: e.response?.data?['message'] ?? e.message ?? 'Network error',
      );
    } catch (e) {
      return RatingResult(success: false, error: e.toString());
    }
  }

  /// Get movie ratings/reviews (optional - if API supports it)
  Future<List<MovieRating>> getMovieRatings(String movieId, {int page = 1, int size = 20}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/ratings',
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> items;
        if (data is Map && data['items'] != null) {
          items = data['items'] as List<dynamic>;
        } else if (data is List) {
          items = data;
        } else {
          return [];
        }
        return items.map((e) => MovieRating.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get current user's rating for a movie
  Future<MovieRating?> getUserRating(String movieId) async {
    if (_userId == null) return null;

    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/ratings/me',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data != null) {
          return MovieRating.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete user's rating for a movie
  Future<bool> deleteRating(String movieId) async {
    if (_userId == null) return false;

    try {
      final response = await _dio.delete(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/ratings/me',
        options: Options(headers: _headers),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Update user's rating for a movie
  Future<RatingResult> updateRating(String movieId, int rating, {String? review}) async {
    return rateMovie(movieId, rating, review: review);
  }
}

// ============= MODELS =============

class RatingResult {
  final bool success;
  final MovieRating? data;
  final String? message;
  final String? error;

  RatingResult({
    required this.success,
    this.data,
    this.message,
    this.error,
  });
}

class MovieRating {
  final String? id;
  final String movieId;
  final int userId;
  final int rating;
  final String? review;
  final String? username;
  final String? userAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MovieRating({
    this.id,
    required this.movieId,
    required this.userId,
    required this.rating,
    this.review,
    this.username,
    this.userAvatar,
    this.createdAt,
    this.updatedAt,
  });

  factory MovieRating.fromJson(Map<String, dynamic> json) {
    return MovieRating(
      id: json['id']?.toString(),
      movieId: json['movieId'] ?? '',
      userId: json['userId'] ?? 0,
      rating: json['rating'] ?? 0,
      review: json['review'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'movieId': movieId,
    'userId': userId,
    'rating': rating,
    if (review != null) 'review': review,
  };
}

// ============= PROVIDERS =============

/// Provider to get movie ratings
final movieRatingsProvider = FutureProvider.autoDispose.family<List<MovieRating>, String>((ref, movieId) {
  return ref.watch(ratingsRepositoryProvider).getMovieRatings(movieId);
});

/// Provider to get current user's rating for a movie
final userRatingProvider = FutureProvider.autoDispose.family<MovieRating?, String>((ref, movieId) {
  return ref.watch(ratingsRepositoryProvider).getUserRating(movieId);
});

/// StateNotifier for managing rating submission
class RatingNotifier extends StateNotifier<AsyncValue<RatingResult?>> {
  RatingNotifier(this._repository) : super(const AsyncValue.data(null));

  final RatingsRepository _repository;

  Future<void> submitRating(String movieId, int rating, {String? review}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.rateMovie(movieId, rating, review: review);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final ratingNotifierProvider = StateNotifierProvider.autoDispose<RatingNotifier, AsyncValue<RatingResult?>>((ref) {
  return RatingNotifier(ref.watch(ratingsRepositoryProvider));
});
