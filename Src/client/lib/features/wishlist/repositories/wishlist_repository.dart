import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/models/movie_item.dart';
import '../../../core/config/api_config.dart';

final wishlistRepositoryProvider = Provider((ref) => WishlistRepository(
  ref.watch(dioProvider),
  ref,
));

final dioProvider = Provider((ref) => Dio());

/// Wishlist Repository - REST API based
/// TODO: Connect to actual REST API endpoints
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
  Future<List<MovieItem>> getWishlist() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.wishlistServiceUrl}/users/$userId/wishlist',
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

  /// Stream wishlist items (converts Future to Stream for backward compatibility)
  Stream<List<MovieItem>> streamWishlist() {
    return Stream.fromFuture(getWishlist());
  }

  /// Add movie to wishlist
  Future<void> addToWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _dio.post(
        '${ApiConfig.wishlistServiceUrl}/users/$userId/wishlist',
        data: {'movieId': movieId},
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Add to local sample for demo
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
  Future<void> removeFromWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _dio.delete(
        '${ApiConfig.wishlistServiceUrl}/users/$userId/wishlist/$movieId',
        options: Options(headers: _headers),
      );
    } catch (e) {
      // Remove from local sample for demo
      _sampleWishlist.removeWhere((m) => m.id == movieId);
    }
  }

  /// Check if movie is in wishlist
  Future<bool> isInWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final response = await _dio.get(
        '${ApiConfig.wishlistServiceUrl}/users/$userId/wishlist/$movieId',
        options: Options(headers: _headers),
      );
      return response.statusCode == 200;
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
final wishlistProvider = StreamProvider.autoDispose<List<MovieItem>>(
  (ref) {
    final repo = ref.watch(wishlistRepositoryProvider);
    return repo.streamWishlist();
  },
);

final wishlistCountProvider = FutureProvider.autoDispose<int>(
  (ref) async {
    final repo = ref.watch(wishlistRepositoryProvider);
    return repo.getWishlistCount();
  },
);

// Provider to check if movie is in wishlist (not real-time, but update on change)
final isInWishlistProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, movieId) async {
    final repo = ref.watch(wishlistRepositoryProvider);
    return repo.isInWishlist(movieId);
  },
);
