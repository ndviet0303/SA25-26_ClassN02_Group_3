import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/models/movie_item.dart';
import '../../../core/repositories/wishlist_repository.dart';

/// Notifier for managing the wishlist state (AsyncNotifier)
class WishlistNotifier extends AutoDisposeAsyncNotifier<List<MovieItem>> {
  @override
  FutureOr<List<MovieItem>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];
    
    // Fetch initial watchlist from repository
    return ref.read(wishlistRepositoryProvider).getWatchlist(userId);
  }

  /// Remove an item from the wishlist with optimistic update
  Future<void> removeFromWishlist(String movieId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final previousState = state;
    
    // Optimistic UI update: remove item immediately from state
    state = AsyncValue.data(
      state.value?.where((item) => item.id != movieId).toList() ?? [],
    );

    try {
      // API call to remove from server
      await ref.read(wishlistRepositoryProvider).removeFromWatchlist(userId, movieId);
    } catch (e) {
      // Rollback on error
      state = previousState;
      rethrow;
    }
  }

  /// Add an item to the wishlist (placeholder if needed)
  Future<void> addToWishlist(MovieItem movie) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final previousState = state;
    
    // Optimistic UI update
    if (state.value != null && !state.value!.any((item) => item.id == movie.id)) {
      state = AsyncValue.data([...state.value!, movie]);
    }

    try {
      await ref.read(wishlistRepositoryProvider).addToWatchlist(userId, movie.id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  /// Check if a movie is in the wishlist
  bool isInWishlist(String movieId) {
    return state.value?.any((item) => item.id == movieId) ?? false;
  }
}

/// Provider for the wishlist notifier
final wishlistProvider = AsyncNotifierProvider.autoDispose<WishlistNotifier, List<MovieItem>>(WishlistNotifier.new);

/// Provider to check if a specific movie is in the wishlist (watches wishlistProvider)
final isInWishlistProvider = Provider.autoDispose.family<AsyncValue<bool>, String>((ref, movieId) {
  return ref.watch(wishlistProvider).whenData(
    (wishlist) => wishlist.any((item) => item.id == movieId),
  );
});
