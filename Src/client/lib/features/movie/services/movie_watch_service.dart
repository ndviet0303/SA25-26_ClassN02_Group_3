import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/api_config.dart';

final dioProvider = Provider((ref) => Dio());

final movieWatchServiceProvider = Provider((ref) => MovieWatchService(
  dio: ref.watch(dioProvider),
  ref: ref,
));

/// Movie Watch Service - REST API based
/// Handles access control, view counting, and watch history
class MovieWatchService {
  MovieWatchService({required Dio dio, required Ref ref})
      : _dio = dio,
        _ref = ref;

  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Check if user has access to watch a movie
  Future<bool> hasAccess(String movieId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/access',
        queryParameters: {'userId': userId},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        return response.data['hasAccess'] == true;
      }
      // For demo, return true
      return true;
    } catch (e) {
      // For demo, return true to allow watching
      return true;
    }
  }

  /// Increment view count for a movie
  Future<void> incrementView(String movieId) async {
    try {
      await _dio.post(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/view',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Add movie to user's watch history
  Future<void> addWatchHistory(String movieId) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _dio.post(
        '${ApiConfig.movieServiceUrl}/users/$userId/watch-history',
        data: {'movieId': movieId},
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Get user's watch history
  Future<List<Map<String, dynamic>>> getWatchHistory({int limit = 20}) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/users/$userId/watch-history',
        queryParameters: {'limit': limit},
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
