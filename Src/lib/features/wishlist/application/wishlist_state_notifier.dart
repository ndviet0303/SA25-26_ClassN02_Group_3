import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/movie_item.dart';
import '../repositories/wishlist_repository.dart';

final wishlistStateProvider =
    StateNotifierProvider<WishlistStateNotifier, WishlistState>(
  (ref) => WishlistStateNotifier(ref),
);

class WishlistState {
  final List<MovieItem> items;
  final Set<String> removedIds;

  const WishlistState({
    this.items = const [],
    this.removedIds = const {},
  });

  WishlistState copyWith({
    List<MovieItem>? items,
    Set<String>? removedIds,
  }) {
    return WishlistState(
      items: items ?? this.items,
      removedIds: removedIds ?? this.removedIds,
    );
  }
}

class WishlistStateNotifier extends StateNotifier<WishlistState> {
  WishlistStateNotifier(this._ref) : super(const WishlistState()) {
    _ref.listen(wishlistProvider, (previous, next) {
      next.whenData((items) {
        state = state.copyWith(
          items: items.where((item) => !state.removedIds.contains(item.id)).toList(),
        );
      });
    });
  }

  final Ref _ref;

  void removeFromWishlist(String itemId) {
    state = state.copyWith(
      removedIds: {...state.removedIds, itemId},
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }
}

