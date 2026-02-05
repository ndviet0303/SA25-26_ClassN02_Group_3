import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/core/auth/auth_providers.dart';
import 'package:movie_fe/core/models/movie_item.dart';
import 'package:movie_fe/core/repositories/movie_repository.dart';
import 'package:movie_fe/features/wishlist/repositories/wishlist_repository.dart';
import 'package:movie_fe/features/purchase/data/repositories/purchase_repository.dart';
import 'package:movie_fe/features/profile/repository/settings_repository.dart';

// User preferred genres from profile
final userPreferredGenresProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  try {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const <String>['hanh-dong', 'vien-tuong'];
    
    // UserProfile doesn't have genres field yet, use defaults based on common genres
    // TODO: Add genres field to UserProfile when available from API
    return const <String>['hanh-dong', 'vien-tuong', 'kinh-di', 'hai-huoc'];
  } catch (e) {
    return const <String>['hanh-dong', 'vien-tuong'];
  }
});

// Trending movies for auto-slide banner
final trendingMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final movieRepo = ref.watch(movieRepositoryProvider);
  return movieRepo.streamTrending(limit: 8);
});

// Recommended movies based on user preferences
final recommendedMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final movieRepo = ref.watch(movieRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return movieRepo.streamRecommendations(userId: userId, limit: 10);
});

// Purchased movies
final purchasedMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final repo = ref.watch(purchaseRepositoryProvider);
  return repo.streamPurchases().map((purchases) => purchases.map((p) => MovieItem(
    id: p.id,
    title: p.title,
    imageUrl: p.imageUrl,
    rating: p.rating,
    price: p.price,
  )).toList());
});

// Wishlist movies
final wishlistMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final repo = ref.watch(wishlistRepositoryProvider);
  return repo.streamWishlist();
});

// Recently watched movies (use new releases as fallback)
final recentMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final movieRepo = ref.watch(movieRepositoryProvider);
  return movieRepo.streamTopNewReleases(limit: 8);
});
