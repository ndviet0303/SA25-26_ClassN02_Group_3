import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_item.dart';
import '../models/movie.dart';

final firestoreProvider = Provider((_) => FirebaseFirestore.instance);

class MovieRepository {
  MovieRepository(this._db);
  final FirebaseFirestore _db;

  Stream<List<MovieItem>> streamAll() => _db
      .collection('movies')
      .orderBy('year', descending: true)
      .snapshots()
      .map((s) => s.docs.map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc))).toList());

  Stream<List<MovieItem>> streamByGenre(String slugOrName) => _db
      .collection('movies')
      .orderBy('view', descending: true)
      .snapshots()
      .map((s) {
        final docs = s.docs;
        final filtered = <MovieItem>[];
        for (final doc in docs) {
          final data = doc.data();
          bool match = false;
          final slugs = (data['categorySlugs'] as List?)?.map((e) => e.toString()).toList() ?? const [];
          if (slugs.contains(slugOrName)) {
            match = true;
          } else {
            final cats = (data['category'] as List?) ?? const [];
            for (final c in cats) {
              if (c is Map) {
                final slug = c['slug']?.toString();
                final name = c['name']?.toString();
                if (slug == slugOrName || name == slugOrName) {
                  match = true;
                  break;
                }
              }
            }
          }
          if (match) {
            filtered.add(MovieItem.fromMovie(Movie.fromDoc(doc)));
          }
        }
        return filtered;
      });

  Stream<MovieItem?> streamById(String id) => _db
      .collection('movies')
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? MovieItem.fromMovie(Movie.fromDoc(doc)) : null);

  Future<MovieItem?> getById(String id) async {
    final movie = await getMovieDetail(id);
    return movie != null ? MovieItem.fromMovie(movie) : null;
  }

  Stream<List<MovieItem>> streamSimilar(String movieId, {int limit = 10}) {
    return _db.collection('movies')
        .orderBy('view', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc))).toList());
  }

  Stream<List<MovieItem>> streamByFranchise(String franchiseId) => _db
      .collection('movies')
      .where('slug', isGreaterThanOrEqualTo: franchiseId)
      .where('slug', isLessThan: '${franchiseId}z')
      .orderBy('slug')
      .snapshots()
      .map((s) => s.docs.map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc))).toList());

  Stream<List<MovieItem>> streamTopCharts({int limit = 10}) => _db
      .collection('movies')
      .orderBy('view', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc))).toList());

  Stream<List<MovieItem>> streamTopSelling({int limit = 10}) => _db
      .collection('movies')
      .orderBy('tmdb.vote_average', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc))).toList());

  Stream<List<MovieItem>> streamTopFree({int limit = 10}) => _db
      .collection('movies')
      .where('price.usd', isLessThanOrEqualTo: 0)
      .orderBy('price.usd', descending: false)
      .limit(limit * 5)
      .snapshots()
      .map((s) {
        final moviesWithItems = s.docs.map((doc) {
          final movie = Movie.fromDoc(doc);
          return (movie: movie, item: MovieItem.fromMovie(movie));
        }).toList();
        
        final filtered = moviesWithItems
            .where((e) => e.item.price == null || (e.item.price != null && e.item.price! <= 0))
            .toList();
        
        filtered.sort((a, b) {
          final aView = a.movie.view ?? 0;
          final bView = b.movie.view ?? 0;
          return bView.compareTo(aView);
        });
        
        return filtered.take(limit).map((e) => e.item).toList();
      });

  Stream<List<MovieItem>> streamTopNewReleases({int limit = 10}) {
    final currentYear = DateTime.now().year;
    final minYear = currentYear - 2;
    
    return _db
        .collection('movies')
        .where('year', isGreaterThanOrEqualTo: minYear)
        .orderBy('year', descending: true)
        .limit(limit * 5)
        .snapshots()
        .map((s) {
          final movies = <Movie>[];
          final items = <MovieItem>[];
          for (final doc in s.docs) {
            final movie = Movie.fromDoc(doc);
            if (movie.status != 'upcoming' && movie.year != null) {
              movies.add(movie);
              items.add(MovieItem.fromMovie(movie));
            }
          }
          
          final indexed = List.generate(movies.length, (i) => i);
          
          indexed.sort((a, b) {
            final yearCompare = (movies[b].year ?? 0).compareTo(movies[a].year ?? 0);
            if (yearCompare != 0) return yearCompare;
            final aView = movies[a].view ?? 0;
            final bView = movies[b].view ?? 0;
            return bView.compareTo(aView);
          });
          
          return indexed.take(limit).map((i) => items[i]).toList();
        });
  }

  Stream<List<MovieItem>> streamTrending({int limit = 10}) => _db
      .collection('movies')
      .where('chieurap', isEqualTo: true)
      .orderBy('view', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc))).toList());

  Future<Movie?> getMovieDetail(String id) async {
    // Try by document ID first
    var doc = await _db.collection('movies').doc(id).get();
    if (doc.exists) {
      return Movie.fromDoc(doc);
    }

    // Try by slug
    final slugQuery = await _db
        .collection('movies')
        .where('slug', isEqualTo: id)
        .limit(1)
        .get();
    if (slugQuery.docs.isNotEmpty) {
      return Movie.fromDoc(slugQuery.docs.first);
    }

    // Try by originalId
    final originalIdQuery = await _db
        .collection('movies')
        .where('originalId', isEqualTo: id)
        .limit(1)
        .get();
    if (originalIdQuery.docs.isNotEmpty) {
      return Movie.fromDoc(originalIdQuery.docs.first);
    }

    return null;
  }
}

final movieRepoProvider = Provider((ref) => MovieRepository(ref.watch(firestoreProvider)));

final moviesProvider = StreamProvider.autoDispose<List<MovieItem>>(
  (ref) => ref.watch(movieRepoProvider).streamAll(),
);

final moviesByGenreProvider =
    StreamProvider.autoDispose.family<List<MovieItem>, String>(
  (ref, genre) => ref.watch(movieRepoProvider).streamByGenre(genre),
);

