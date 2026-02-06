import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import '../config/api_config.dart';
import '../models/movie.dart';
import '../models/movie_item.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepository(Dio(), ref);
});

/// Recommendation Repository - REST API based
/// API: RecommendationController endpoints
class RecommendationRepository {
  RecommendationRepository(this._dio, this._ref);

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Get personalized recommendations for user
  /// API: GET /recommendations/{userId}
  Future<List<Movie>> getRecommendations({int limit = 12}) async {
    if (_userId == null) {
      return getTrending(limit: limit);
    }

    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations/$_userId',
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
      return getTrending(limit: limit);
    }
  }

  /// Get similar movies for a given movie
  /// API: GET /recommendations/similar/{movieId}
  Future<List<MovieItem>> getSimilarMovies(String movieId, {int limit = 12}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations/similar/$movieId',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> movies = data['data'] ?? data;
        return movies.map((m) => MovieItem.fromJson(m as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get series/franchise movies for a given movie
  /// API: GET /recommendations/series/{movieId}
  Future<List<MovieItem>> getSeriesMovies(String movieId, {int limit = 12}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations/series/$movieId',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> movies = data['data'] ?? data;
        return movies.map((m) => MovieItem.fromJson(m as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get trending movies
  /// API: GET /recommendations/trending
  Future<List<Movie>> getTrending({int limit = 12}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations/trending',
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

// Providers
final recommendationsProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(recommendationRepositoryProvider).getRecommendations();
});

final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(recommendationRepositoryProvider).getTrending();
});

final similarMoviesProvider = FutureProvider.autoDispose.family<List<MovieItem>, String>((ref, movieId) {
  return ref.watch(recommendationRepositoryProvider).getSimilarMovies(movieId);
});

final seriesMoviesProvider = FutureProvider.autoDispose.family<List<MovieItem>, String>((ref, movieId) {
  return ref.watch(recommendationRepositoryProvider).getSeriesMovies(movieId);
});
