import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/movie_item.dart';
import '../models/movie.dart';
import '../config/api_config.dart';

final dioProvider = Provider((ref) => Dio());

final movieRepositoryProvider = Provider((ref) => MovieRepository(ref.watch(dioProvider)));

/// Movie Repository - REST API based
/// Handles movie data fetching and error reporting
class MovieRepository {
  MovieRepository(this._dio);
  final Dio _dio;

  /// Get all movies
  Future<List<MovieItem>> getAll() async {
    try {
      final response = await _dio.get('${ApiConfig.movieServiceUrl}/movies');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        // Handle paginated response (data.items) or direct array
        List<dynamic> items;
        if (data is Map && data['items'] != null) {
          items = data['items'] as List<dynamic>;
        } else if (data is List) {
          items = data;
        } else {
          return _getSampleMovies();
        }
        return items.map((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies();
    } catch (e) {
      print('[MovieRepository] getAll error: $e');
      return _getSampleMovies();
    }
  }

  /// Stream all movies
  Stream<List<MovieItem>> streamAll() {
    return Stream.fromFuture(getAll());
  }

  /// Get movies by genre
  Future<List<MovieItem>> getByGenre(String slugOrName) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/genre/$slugOrName',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> items;
        if (data is Map && data['items'] != null) {
          items = data['items'] as List<dynamic>;
        } else if (data is List) {
          items = data;
        } else {
          return _getSampleMovies();
        }
        return items.map<MovieItem>((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies();
    } catch (e) {
      print('[MovieRepository] getByGenre error: $e');
      return _getSampleMovies();
    }
  }

  Stream<List<MovieItem>> streamByGenre(String slugOrName) {
    return Stream.fromFuture(getByGenre(slugOrName));
  }

  /// Get movie by ID or slug
  Future<MovieItem?> getById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.movieServiceUrl}/movies/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return MovieItem.fromJson(data as Map<String, dynamic>);
      }
      return _getSampleMovie(id);
    } catch (e) {
      print('[MovieRepository] getById error: $e');
      return _getSampleMovie(id);
    }
  }

  Stream<MovieItem?> streamById(String id) {
    return Stream.fromFuture(getById(id));
  }

  /// Get movie detail by ID or slug
  Future<Movie?> getMovieDetail(String id) async {
    try {
      // API returns movie detail at /movies/{id} or /movies/slug/{slug}
      final response = await _dio.get('${ApiConfig.movieServiceUrl}/movies/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return Movie.fromMap(data as Map<String, dynamic>);
      }
      return _getSampleMovieDetail(id);
    } catch (e) {
      print('[MovieRepository] getMovieDetail error: $e');
      return _getSampleMovieDetail(id);
    }
  }

  /// Get similar movies
  Future<List<MovieItem>> getSimilar(String movieId, {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations/similar/$movieId',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map<MovieItem>((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies().take(limit).toList();
    } catch (e) {
      return _getSampleMovies().take(limit).toList();
    }
  }

  Stream<List<MovieItem>> streamSimilar(String movieId, {int limit = 10}) {
    return Stream.fromFuture(getSimilar(movieId, limit: limit));
  }

  /// Get movies by franchise
  Future<List<MovieItem>> getByFranchise(String franchiseId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations/series/$franchiseId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map<MovieItem>((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies();
    } catch (e) {
      return _getSampleMovies();
    }
  }

  Stream<List<MovieItem>> streamByFranchise(String franchiseId) {
    return Stream.fromFuture(getByFranchise(franchiseId));
  }

  /// Get top charts (uses trending endpoint)
  Future<List<MovieItem>> getTopCharts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/trending',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> items = data is List ? data : [];
        return items.take(limit).map<MovieItem>((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies().take(limit).toList();
    } catch (e) {
      print('[MovieRepository] getTopCharts error: $e');
      return _getSampleMovies().take(limit).toList();
    }
  }

  Stream<List<MovieItem>> streamTopCharts({int limit = 10}) {
    return Stream.fromFuture(getTopCharts(limit: limit));
  }

  /// Get top selling
  Future<List<MovieItem>> getTopSelling({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/top-selling',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map<MovieItem>((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies().take(limit).toList();
    } catch (e) {
      return _getSampleMovies().take(limit).toList();
    }
  }

  Stream<List<MovieItem>> streamTopSelling({int limit = 10}) {
    return Stream.fromFuture(getTopSelling(limit: limit));
  }

  /// Get top free movies
  Future<List<MovieItem>> getTopFree({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/free',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> items = data is List ? data : [];
        return items.take(limit).map((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies().take(limit).toList();
    } catch (e) {
      print('[MovieRepository] getTopFree error: $e');
      return _getSampleMovies().take(limit).toList();
    }
  }

  Stream<List<MovieItem>> streamTopFree({int limit = 10}) {
    return Stream.fromFuture(getTopFree(limit: limit));
  }

  /// Get new releases (uses latest endpoint)
  Future<List<MovieItem>> getTopNewReleases({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/latest',
        queryParameters: {'size': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> items;
        if (data is Map && data['items'] != null) {
          items = data['items'] as List<dynamic>;
        } else if (data is List) {
          items = data;
        } else {
          return _getSampleMovies().take(limit).toList();
        }
        return items.take(limit).map((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return _getSampleMovies().take(limit).toList();
    } catch (e) {
      print('[MovieRepository] getTopNewReleases error: $e');
      return _getSampleMovies().take(limit).toList();
    }
  }

  Stream<List<MovieItem>> streamTopNewReleases({int limit = 10}) {
    return Stream.fromFuture(getTopNewReleases(limit: limit));
  }

  /// Get recommendations for user
  Future<List<MovieItem>> getRecommendations({String? userId, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/recommendations',
        queryParameters: {
          if (userId != null) 'userId': userId,
          'limit': limit,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MovieItem.fromJson(json)).toList();
      }
      // Fallback to trending if no recommendations
      return getTrending(limit: limit);
    } catch (e) {
      // Fallback to trending
      return getTrending(limit: limit);
    }
  }

  Stream<List<MovieItem>> streamRecommendations({String? userId, int limit = 10}) {
    return Stream.fromFuture(getRecommendations(userId: userId, limit: limit));
  }

  /// Get trending movies
  Future<List<MovieItem>> getTrending({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/trending',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        List<dynamic> items = data is List ? data : [];
        return items.take(limit).map((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      return getAll().then((all) => all.take(limit).toList());
    } catch (e) {
      print('[MovieRepository] getTrending error: $e');
      return getAll().then((all) => all.take(limit).toList());
    }
  }

  Stream<List<MovieItem>> streamTrending({int limit = 10}) {
    return Stream.fromFuture(getTrending(limit: limit));
  }

  /// Report a video error
  Future<void> reportError({
    required String movieId,
    required String issueType,
    required String description,
    required String videoUrl,
    required String errorMessage,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      await _dio.post(
        '${ApiConfig.movieServiceUrl}/reports',
        data: {
          'movieId': movieId,
          'issueType': issueType,
          'description': description,
          'videoUrl': videoUrl,
          'errorMessage': errorMessage,
          'deviceInfo': deviceInfo,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // For demo, just print
      print('[MovieRepository] Error submitting report: $e');
    }
  }

  // ============= SAMPLE DATA =============
  
  List<MovieItem> _getSampleMovies() {
    return [
      MovieItem(id: 'sample-1', title: 'Avengers: Endgame', imageUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg', rating: 8.4, price: 4.99),
      MovieItem(id: 'sample-2', title: 'The Dark Knight', imageUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg', rating: 9.0, price: 3.99),
      MovieItem(id: 'sample-3', title: 'Inception', imageUrl: 'https://image.tmdb.org/t/p/w500/edv5bs1pSdfS2S6yxeDYfj7JWAD.jpg', rating: 8.8, price: 2.99),
    ];
  }

  MovieItem? _getSampleMovie(String id) {
    final samples = _getSampleMovies();
    return samples.firstWhere((m) => m.id == id, orElse: () => samples.first);
  }

  Movie _getSampleMovieDetail(String id) {
    return Movie(
      id: id,
      name: 'Sample Movie',
      originName: 'Sample Movie Original',
      slug: 'sample-movie',
      originalId: 'orig-$id',
      type: 'single',
      status: 'completed',
      content: 'This is a sample movie description for testing purposes.',
      posterUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
      thumbUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
      trailerUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      year: 2024,
      view: 10000,
      category: [
        {'name': 'Action', 'slug': 'action'},
      ],
      price: {'usd': 4.99},
      accessType: AccessType.FREE,
    );
  }
}

// Additional Providers
final moviesProvider = StreamProvider.autoDispose<List<MovieItem>>(
  (ref) => ref.watch(movieRepositoryProvider).streamAll(),
);

final movieDetailProvider = FutureProvider.autoDispose.family<Movie?, String>(
  (ref, id) => ref.watch(movieRepositoryProvider).getMovieDetail(id),
);

final moviesByGenreProvider = StreamProvider.autoDispose.family<List<MovieItem>, String>(
  (ref, genre) => ref.watch(movieRepositoryProvider).streamByGenre(genre),
);
