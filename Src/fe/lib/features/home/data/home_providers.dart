import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/core/models/movie.dart';
import 'package:movie_fe/core/models/movie_item.dart';
import 'package:movie_fe/core/utils/data/genres.dart';

final _authProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final _firestoreProvider = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final currentUserProvider = Provider<User?>((ref) => ref.watch(_authProvider).currentUser);

// User preferred genres
final preferredGenresProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  final db = ref.watch(_firestoreProvider);
  if (user == null) return const Stream<List<String>>.empty();
  return db.collection('users').doc(user.uid).snapshots().map((doc) {
    final list = (doc.data()?['preferredGenres'] as List?)?.whereType<String>().toList() ?? const <String>[];
    return list;
  });
});

// Recommended: based on user's preferred genres (users/{uid}.preferredGenres: []).
// Fallback: top charts by view.
final recommendedMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  final db = ref.watch(_firestoreProvider);

  Stream<List<MovieItem>> topViews() => db
      .collection('movies')
      .orderBy('view', descending: true)
      .limit(20)
      .snapshots()
      .map((s) => s.docs.map((d) => MovieItem.fromMovie(Movie.fromDoc(d))).toList());

  if (user == null) {
    return topViews();
  }

  final userDocStream = db.collection('users').doc(user.uid).snapshots();
  return userDocStream.asyncMap((userDoc) async {
    final raw = (userDoc.data()?['preferredGenres'] as List?)?.whereType<String>().toList() ?? const <String>[];
    if (raw.isEmpty) {
      final snap = await db
          .collection('movies')
          .orderBy('view', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((d) => MovieItem.fromMovie(Movie.fromDoc(d))).toList();
    }
    // Map possible names to slug using GenresVi
    final mapped = GenresVi.fromNames(raw);
    final slugs = mapped.map((e) => e['slug'] ?? '').where((e) => e.isNotEmpty).take(10).toList();
    // ignore: avoid_print
    print('[Recommended] mapped slugs=${slugs.join(', ')}');

    if (slugs.isEmpty) {
      // ignore: avoid_print
      print('[Recommended] no mapped slugs → fallback to top views');
      final snap = await db
          .collection('movies')
          .orderBy('view', descending: true)
          .limit(20)
          .get();
      // ignore: avoid_print
      print('[Recommended] top views count=${snap.docs.length}');
      return snap.docs.map((d) => MovieItem.fromMovie(Movie.fromDoc(d))).toList();
    }

    final snap = await db
        .collection('movies')
        .where('categorySlugs', arrayContainsAny: slugs)
        .orderBy('view', descending: true)
        .limit(40)
        .get();

    var items = snap.docs.map((d) => MovieItem.fromMovie(Movie.fromDoc(d))).toList();

    if (items.isEmpty) {
      final broad = await db
          .collection('movies')
          .orderBy('view', descending: true)
          .limit(80)
          .get();
      items = [];
      for (final d in broad.docs) {
        final data = d.data();
        final cats = (data['category'] as List?) ?? const [];
        bool match = false;
        for (final c in cats) {
          if (c is Map) {
            final slug = c['slug']?.toString();
            final name = c['name']?.toString();
            if (slug != null && slugs.contains(slug)) { match = true; break; }
            if (name != null && raw.contains(name)) { match = true; break; }
          }
        }
        if (match) items.add(MovieItem.fromMovie(Movie.fromDoc(d)));
        if (items.length >= 20) break;
      }
    }

    return items;
  });
});

// Purchased: users/{uid}/purchases -> movieId list -> fetch movies
final purchasedMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  final db = ref.watch(_firestoreProvider);
  if (user == null) return const Stream.empty();

  final idsStream = db
      .collection('users')
      .doc(user.uid)
      .collection('purchases')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toList());

  return idsStream.asyncMap((ids) async {
    if (ids.isEmpty) return const <MovieItem>[];
    // Firestore whereIn limit 10; batch if more
    final chunks = <List<String>>[];
    for (int i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    final results = <MovieItem>[];
    for (final chunk in chunks) {
      final q = await db.collection('movies').where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(q.docs.map((d) => MovieItem.fromMovie(Movie.fromDoc(d))));
    }
    return results;
  });
});

// Wishlist: users/{uid}/wishlist -> movieId list -> fetch movies
final wishlistMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  final db = ref.watch(_firestoreProvider);
  if (user == null) return const Stream.empty();

  final idsStream = db
      .collection('users')
      .doc(user.uid)
      .collection('wishlist')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toList());

  return idsStream.asyncMap((ids) async {
    if (ids.isEmpty) return const <MovieItem>[];
    final chunks = <List<String>>[];
    for (int i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    final results = <MovieItem>[];
    for (final chunk in chunks) {
      final q = await db.collection('movies').where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(q.docs.map((d) => MovieItem.fromMovie(Movie.fromDoc(d))));
    }
    return results;
  });
});

// Recently watched: users/{uid}/watch_history ordered by lastWatchedAt
final recentMoviesProvider = StreamProvider.autoDispose<List<MovieItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  final db = ref.watch(_firestoreProvider);
  if (user == null) return const Stream.empty();

  final historyStream = db
      .collection('users')
      .doc(user.uid)
      .collection('watch_history')
      .orderBy('lastWatchedAt', descending: true)
      .limit(20)
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toList());

  return historyStream.asyncMap((ids) async {
    if (ids.isEmpty) return const <MovieItem>[];
    final chunks = <List<String>>[];
    for (int i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
    }
    final results = <MovieItem>[];
    for (final chunk in chunks) {
      final q = await db.collection('movies').where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(q.docs.map((d) => MovieItem.fromMovie(Movie.fromDoc(d))));
    }
    return results;
  });
});


