import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../auth/auth_providers.dart';
import '../models/movie_item.dart';
import '../config/api_config.dart';
import 'customer_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) => WishlistRepository(Dio(), ref));

/// Wishlist Repository - REST API based
/// API: MovieService - Watchlist endpoints
class WishlistRepository {
  WishlistRepository(this._dio, this._ref);
  
  final Dio _dio;
  final Ref _ref;

  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // In-memory cache for sample data
  final List<MovieItem> _sampleWishlist = [];

  /// Get watchlist items for a user
  /// API: GET /api/movies/user/{userId}/watchlist
  Future<List<MovieItem>> getWatchlist(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/movies/user/$userId/watchlist',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MovieItem.fromJson(json)).toList();
      }
      return _sampleWishlist;
    } catch (e) {
      debugPrint('[WishlistRepository] Error fetching watchlist: $e');
      return _sampleWishlist;
    }
  }

  /// Add movie to watchlist
  /// API: POST /api/movies/user/{userId}/watchlist
  Future<void> addToWatchlist(String userId, String movieId) async {
    try {
      await _dio.post(
        '${ApiConfig.baseUrl}/api/movies/user/$userId/watchlist',
        data: {'movieId': movieId},
        options: Options(headers: _headers),
      );
    } catch (e) {
      debugPrint('[WishlistRepository] Error adding to watchlist: $e');
      // For demo, add to local sample
      if (!_sampleWishlist.any((m) => m.id == movieId)) {
        _sampleWishlist.add(MovieItem(
          id: movieId,
          title: 'Movie $movieId',
          imageUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
          rating: 8.0,
          price: 4.99,
        ));
      }
    }
  }

  /// Remove movie from watchlist
  /// API: DELETE /api/movies/user/{userId}/watchlist/{movieId}
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    try {
      await _dio.delete(
        '${ApiConfig.baseUrl}/api/movies/user/$userId/watchlist/$movieId',
        options: Options(headers: _headers),
      );
    } catch (e) {
      debugPrint('[WishlistRepository] Error removing from watchlist: $e');
      _sampleWishlist.removeWhere((m) => m.id == movieId);
    }
  }

  /// Check if movie is in watchlist
  Future<bool> isInWatchlist(String userId, String movieId) async {
    try {
      final watchlist = await getWatchlist(userId);
      return watchlist.any((m) => m.id == movieId);
    } catch (e) {
      return _sampleWishlist.any((m) => m.id == movieId);
    }
  }
}

// Providers moved to features/wishlist/application/wishlist_state_notifier.dart

