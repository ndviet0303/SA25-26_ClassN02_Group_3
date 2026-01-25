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
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MovieItem.fromJson(json)).toList();
      }
      return _getSampleMovies();
    } catch (e) {
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
        '${ApiConfig.movieServiceUrl}/movies',
        queryParameters: {'genre': slugOrName},
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

  Stream<List<MovieItem>> streamByGenre(String slugOrName) {
    return Stream.fromFuture(getByGenre(slugOrName));
  }

  /// Get movie by ID
  Future<MovieItem?> getById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.movieServiceUrl}/movies/$id');
      if (response.statusCode == 200) {
        return MovieItem.fromJson(response.data);
      }
      return _getSampleMovie(id);
    } catch (e) {
      return _getSampleMovie(id);
    }
  }

  Stream<MovieItem?> streamById(String id) {
    return Stream.fromFuture(getById(id));
  }

  /// Get movie detail
  Future<Movie?> getMovieDetail(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.movieServiceUrl}/movies/$id/detail');
      if (response.statusCode == 200) {
        return Movie.fromMap(response.data);
      }
      return _getSampleMovieDetail(id);
    } catch (e) {
      return _getSampleMovieDetail(id);
    }
  }

  /// Get similar movies
  Future<List<MovieItem>> getSimilar(String movieId, {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/$movieId/similar',
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
        '${ApiConfig.movieServiceUrl}/movies',
        queryParameters: {'franchise': franchiseId},
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

  /// Get top charts
  Future<List<MovieItem>> getTopCharts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/top-charts',
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
        '${ApiConfig.movieServiceUrl}/movies/top-free',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MovieItem.fromJson(json)).toList();
      }
      return _getSampleMovies().take(limit).toList();
    } catch (e) {
      return _getSampleMovies().take(limit).toList();
    }
  }

  Stream<List<MovieItem>> streamTopFree({int limit = 10}) {
    return Stream.fromFuture(getTopFree(limit: limit));
  }

  /// Get new releases
  Future<List<MovieItem>> getTopNewReleases({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.movieServiceUrl}/movies/new-releases',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => MovieItem.fromJson(json)).toList();
      }
      return _getSampleMovies().take(limit).toList();
    } catch (e) {
      return _getSampleMovies().take(limit).toList();
    }
  }

  Stream<List<MovieItem>> streamTopNewReleases({int limit = 10}) {
    return Stream.fromFuture(getTopNewReleases(limit: limit));
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
