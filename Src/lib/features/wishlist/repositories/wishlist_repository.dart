import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/repositories/movie_repository.dart';

final wishlistRepositoryProvider = Provider((ref) => WishlistRepository(
  ref.watch(firestoreProvider),
  FirebaseAuth.instance,
));

class WishlistRepository {
  WishlistRepository(this._db, this._auth);
  
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _userId => _auth.currentUser?.uid;

  /// Stream wishlist items cho user hiện tại
  Stream<List<MovieItem>> streamWishlist() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return <MovieItem>[];

      // Fetch movie details từ movies collection
      final movieIds = snapshot.docs.map((doc) => doc.id).toList();
      final movies = <MovieItem>[];

      for (final movieId in movieIds) {
        try {
          final movieDoc = await _db.collection('movies').doc(movieId).get();
          if (movieDoc.exists) {
            final movie = Movie.fromDoc(movieDoc);
            movies.add(MovieItem.fromMovie(movie));
          }
        } catch (e) {
          // Ignore errors for missing movies
          continue;
        }
      }

      return movies;
    });
  }

  /// Thêm movie vào wishlist
  Future<void> addToWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(movieId)
        .set({
      'movieId': movieId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xóa movie khỏi wishlist
  Future<void> removeFromWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(movieId)
        .delete();
  }

  /// Kiểm tra movie có trong wishlist không
  Future<bool> isInWishlist(String movieId) async {
    final userId = _userId;
    if (userId == null) return false;

    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(movieId)
        .get();

    return doc.exists;
  }

  /// Toggle wishlist (thêm nếu chưa có, xóa nếu đã có)
  Future<void> toggleWishlist(String movieId) async {
    final isIn = await isInWishlist(movieId);
    if (isIn) {
      await removeFromWishlist(movieId);
    } else {
      await addToWishlist(movieId);
    }
  }

  /// Lấy số lượng items trong wishlist
  Future<int> getWishlistCount() async {
    final userId = _userId;
    if (userId == null) return 0;

    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}

// Providers
final wishlistProvider = StreamProvider.autoDispose<List<MovieItem>>(
  (ref) {
    final repo = ref.watch(wishlistRepositoryProvider);
    return repo.streamWishlist();
  },
);

final wishlistCountProvider = StreamProvider.autoDispose<int>(
  (ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  },
);

// Provider để check movie có trong wishlist không (real-time)
final isInWishlistProvider = StreamProvider.autoDispose.family<bool, String>(
  (ref, movieId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(false);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(movieId)
        .snapshots()
        .map((doc) => doc.exists);
  },
);
