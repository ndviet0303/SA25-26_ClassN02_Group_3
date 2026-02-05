import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/api_config.dart';
import '../../../core/models/movie.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(Dio(), ref);
});

/// Recommendation Service - fetches personalized movie recommendations
class RecommendationService {
  RecommendationService(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Get personalized recommendations for user
  Future<List<Movie>> getRecommendations({int limit = 10}) async {
    if (_userId == null) {
      // Return trending movies for anonymous users
      return getTrending(limit: limit);
    }

    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations',
        queryParameters: {
          'userId': _userId,
          'limit': limit,
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> movies = data['data'] ?? data;
        return movies.map((m) => Movie.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      // Fallback to trending
      return getTrending(limit: limit);
    }
  }

  /// Get trending movies (fallback for new users)
  Future<List<Movie>> getTrending({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/trending',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> movies = data['data'] ?? data;
        return movies.map((m) => Movie.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

/// Provider to fetch recommendations
final recommendationsProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(recommendationServiceProvider).getRecommendations();
});

/// Provider to fetch trending movies
final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(recommendationServiceProvider).getTrending();
});
