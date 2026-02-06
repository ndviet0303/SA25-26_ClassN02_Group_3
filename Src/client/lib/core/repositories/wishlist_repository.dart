import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../auth/auth_providers.dart';
import '../models/movie_item.dart';
import '../config/api_config.dart';

final wishlistRepositoryProvider = Provider((ref) => WishlistRepository(Dio(), ref));

/// Wishlist Repository - REST API based
/// API: CustomerController - Watchlist endpoints
class WishlistRepository {
  WishlistRepository(this._dio, this._ref);
  
  final Dio _dio;
  final Ref _ref;

  String? get _userId => _ref.read(currentUserIdProvider);
  String? get _accessToken => _ref.read(accessTokenProvider);

  Map<String, String> get _headers => {
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // In-memory cache for sample data
  final List<MovieItem> _sampleWishlist = [];

  /// Get wishlist items for current user
  /// API: GET /customers/{id}/watchlist
  Future<List<MovieItem>> getWishlist() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.customerServiceUrl}/$userId/watchlist',
        options: Options(headers: _headers),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MovieItem.fromJson(json)).toList();
      }
      return _sampleWishlist;
    } catch (e) {
      return _sampleWishlist;
    }
  }

  /// Stream wishlist items
  Stream<List<MovieItem>> streamWishlist() {
    return Stream.fromFuture(getWishlist());
  }

  /// Add movie to wishlist
  /// API: POST /customers/{id}/watchlist
  Future<void> addToWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _dio.post(
        '${ApiConfig.customerServiceUrl}/$userId/watchlist',
        data: {'movieId': movieId},
        options: Options(headers: _headers),
      );
    } catch (e) {
      _sampleWishlist.add(MovieItem(
        id: movieId,
        title: 'Movie $movieId',
        imageUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
        rating: 8.0,
        price: 4.99,
      ));
    }
  }

  /// Remove movie from wishlist
  /// API: DELETE /customers/{id}/watchlist/{movieId}
  Future<void> removeFromWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _dio.delete(
        '${ApiConfig.customerServiceUrl}/$userId/watchlist/$movieId',
        options: Options(headers: _headers),
      );
    } catch (e) {
      _sampleWishlist.removeWhere((m) => m.id == movieId);
    }
  }

  /// Check if movie is in wishlist
  Future<bool> isInWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final wishlist = await getWishlist();
      return wishlist.any((m) => m.id == movieId);
    } catch (e) {
      return _sampleWishlist.any((m) => m.id == movieId);
    }
  }

  /// Toggle wishlist (add if not exists, remove if exists)
  Future<void> toggleWishlist(String movieId) async {
    final isIn = await isInWishlist(movieId);
    if (isIn) {
      await removeFromWishlist(movieId);
    } else {
      await addToWishlist(movieId);
    }
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    final items = await getWishlist();
    return items.length;
  }
}

// Providers
final wishlistProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  return ref.watch(wishlistRepositoryProvider).streamWishlist();
});

final wishlistCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.watch(wishlistRepositoryProvider).getWishlistCount();
});

final isInWishlistProvider = FutureProvider.autoDispose.family<bool, String>((ref, movieId) {
  return ref.watch(wishlistRepositoryProvider).isInWishlist(movieId);
});
