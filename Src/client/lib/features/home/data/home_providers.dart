import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/core/auth/auth_providers.dart';
import 'package:movie_fe/core/models/movie_item.dart';
import 'package:movie_fe/core/repositories/movie_repository.dart';
import 'package:movie_fe/features/wishlist/repositories/wishlist_repository.dart';
import 'package:movie_fe/features/purchase/data/repositories/purchase_repository.dart';
import 'package:movie_fe/features/profile/repository/settings_repository.dart';

// User preferred genres
final userPreferredGenresProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  try {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const <String>['Action', 'Sci-Fi'];
    
    final settingsRepo = ref.watch(settingsRepositoryProvider);
    final profile = await settingsRepo.fetchProfile();
    // Return sample genres for now
    return const <String>['Action', 'Sci-Fi'];
  } catch (e) {
    return const <String>['Action', 'Sci-Fi'];
  }
});

// Recommended movies
final recommendedMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final movieRepo = ref.watch(movieRepositoryProvider);
  return movieRepo.streamAll().map((all) => all.take(10).toList());
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

// Recently watched movies
final recentMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final movieRepo = ref.watch(movieRepositoryProvider);
  return movieRepo.streamAll().map((all) => all.take(5).toList());
});
