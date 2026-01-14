import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/api_config.dart';

final dioProvider = Provider((ref) => Dio());

final ratingsServiceProvider = Provider((ref) => RatingsService(
  dio: ref.watch(dioProvider),
  ref: ref,
));

/// Ratings Service - REST API based
/// Handles movie reviews and ratings
class RatingsService {
  RatingsService({required Dio dio, required Ref ref})
      : _dio = dio,
        _ref = ref;

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Submit a review for a movie
  Future<void> submitReview({
    required String movieId,
    required int rating,
    String? comment,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('User not logged in');
    }

    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }

    final authUser = _ref.read(currentAuthUserProvider);
    final userName = authUser?.fullName ?? authUser?.username ?? userId;
    final userAvatar = authUser?.avatarUrl ?? '';

    try {
      await _dio.post(
        '${ApiConfig.ratingServiceUrl}/movies/$movieId/reviews',
        data: {
          'userId': userId,
          'rating': rating,
          'comment': comment,
          'userName': userName,
          'userAvatar': userAvatar,
        },
        options: Options(headers: _headers),
      );
    } catch (e) {
      // For demo, just print error
      print('[RatingsService] Error submitting review: $e');
    }
  }

  /// Toggle like on a review
  Future<void> toggleLike({
    required String movieId,
    required String reviewUserId,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('User not logged in');
    }

    try {
      await _dio.post(
        '${ApiConfig.ratingServiceUrl}/movies/$movieId/reviews/$reviewUserId/like',
        data: {'userId': userId},
        options: Options(headers: _headers),
      );
    } catch (e) {
      // For demo, just print error
      print('[RatingsService] Error toggling like: $e');
    }
  }

  /// Get rating summary for a movie
  Future<Map<String, dynamic>> getRatingSummary(String movieId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.ratingServiceUrl}/movies/$movieId/ratings',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return _getSampleRatingSummary();
    } catch (e) {
      return _getSampleRatingSummary();
    }
  }

  /// Get reviews for a movie
  Future<List<Map<String, dynamic>>> getReviews(String movieId, {int limit = 50}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.ratingServiceUrl}/movies/$movieId/reviews',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.cast<Map<String, dynamic>>();
      }
      return _getSampleReviews();
    } catch (e) {
      return _getSampleReviews();
    }
  }

  /// Check if current user has liked a review
  Future<bool> hasLikedReview(String movieId, String reviewUserId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final response = await _dio.get(
        '${ApiConfig.ratingServiceUrl}/movies/$movieId/reviews/$reviewUserId/like-status',
        queryParameters: {'userId': userId},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        return response.data['liked'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Sample data for demo
  Map<String, dynamic> _getSampleRatingSummary() {
    return {
      'averageRating': 4.2,
      'totalReviews': 156,
      'starsCount': {
        '5': 80,
        '4': 45,
        '3': 20,
        '2': 8,
        '1': 3,
      },
    };
  }

  List<Map<String, dynamic>> _getSampleReviews() {
    return [
      {
        'userId': 'user-1',
        'userName': 'John Doe',
        'userAvatar': 'https://i.pravatar.cc/150?img=1',
        'rating': 5,
        'comment': 'Amazing movie! Loved every minute of it.',
        'likes': 24,
        'likedBy': [],
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'userId': 'user-2',
        'userName': 'Jane Smith',
        'userAvatar': 'https://i.pravatar.cc/150?img=2',
        'rating': 4,
        'comment': 'Great storyline and amazing visuals.',
        'likes': 12,
        'likedBy': [],
        'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
    ];
  }
}
