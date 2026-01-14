import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/config/api_config.dart';
import '../entities/search_result.dart';
import '../entities/search_filter.dart';
import '../entities/filter_section.dart';
import '../mappers/search_mapper.dart';

final dioProvider = Provider((ref) => Dio());

final searchRepositoryProvider = Provider((ref) => SearchRepository(
  ref.watch(dioProvider),
));

/// Search Repository - REST API based
/// Handles movie search and filtering
class SearchRepository {
  final Dio _dio;

  SearchRepository(this._dio);

  /// Search movies with filters and pagination
  Future<SearchResultsPage<SearchResult>> search(
    String query, {
    SearchFilters filters = const SearchFilters(),
    int page = 1,
    dynamic startAfter,
    List<String>? wishlistMovieIds,
  }) async {
    try {
      const pageSize = 10;

      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (filters.genres.isNotEmpty) {
        queryParams['genres'] = filters.genres.join(',');
      }

      if (filters.year != null) {
        queryParams['year'] = filters.year;
      }

      if (filters.priceMin != null) {
        queryParams['priceMin'] = filters.priceMin;
      }

      if (filters.priceMax != null) {
        queryParams['priceMax'] = filters.priceMax;
      }

      if (filters.sortBy != SortOption.trending) {
        queryParams['sortBy'] = filters.sortBy.name;
      }

      if (wishlistMovieIds != null && wishlistMovieIds.isNotEmpty) {
        queryParams['movieIds'] = wishlistMovieIds.join(',');
      }

      try {
        final response = await _dio.get(
          '${ApiConfig.searchServiceUrl}/movies',
          queryParameters: queryParams,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final List<dynamic> items = data['data'] ?? data['items'] ?? [];
          final total = data['total'] ?? items.length;
          final hasNext = data['hasNext'] ?? (page * pageSize < total);

          final movies = items.map<MovieItem>((json) => MovieItem.fromJson(json as Map<String, dynamic>)).toList();
          final results = movies.map<SearchResult>((m) => SearchMapper.movieItemToSearchResult(m)).toList();

          return SearchResultsPage<SearchResult>(
            items: results,
            page: page,
            pageSize: pageSize,
            total: total,
            hasNext: hasNext,
          );
        }
      } catch (e) {
        // Fall back to sample data
      }

      // Return sample data for demo
      final sampleMovies = _getSampleMovies();
      final filteredMovies = _filterMovies(sampleMovies, query, filters);
      
      final startIndex = (page - 1) * pageSize;
      final paginatedMovies = filteredMovies.skip(startIndex).take(pageSize).toList();
      final hasNext = startIndex + pageSize < filteredMovies.length;

      final results = paginatedMovies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();

      return SearchResultsPage<SearchResult>(
        items: results,
        page: page,
        pageSize: pageSize,
        total: filteredMovies.length,
        hasNext: hasNext,
      );
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }

  /// Get search suggestions
  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        '${ApiConfig.searchServiceUrl}/suggestions',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.cast<String>();
      }
    } catch (e) {
      // Fall back to sample suggestions
    }

    // Sample suggestions
    final sampleMovies = _getSampleMovies();
    final suggestions = sampleMovies
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .map((m) => m.title)
        .take(5)
        .toList();
    return suggestions;
  }

  /// Get trending movies
  Future<List<SearchResult>> getTrendingMovies() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.searchServiceUrl}/movies/trending',
        queryParameters: {'limit': 8},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final movies = data.map((json) => MovieItem.fromJson(json)).toList();
        return movies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
      }
    } catch (e) {
      // Fall back to sample data
    }

    final sampleMovies = _getSampleMovies().take(8).toList();
    return sampleMovies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
  }

  /// Get popular movies
  Future<List<SearchResult>> getPopularMovies() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.searchServiceUrl}/movies/popular',
        queryParameters: {'limit': 8},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final movies = data.map((json) => MovieItem.fromJson(json)).toList();
        return movies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
      }
    } catch (e) {
      // Fall back to sample data
    }

    final sampleMovies = _getSampleMovies().take(8).toList();
    return sampleMovies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
  }

  // ============= SAMPLE DATA =============
  
  List<MovieItem> _getSampleMovies() {
    return [
      MovieItem(
        id: 'sample-1',
        title: 'Avengers: Endgame',
        imageUrl: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
        rating: 8.4,
        price: 4.99,
      ),
      MovieItem(
        id: 'sample-2',
        title: 'The Dark Knight',
        imageUrl: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        rating: 9.0,
        price: 3.99,
      ),
      MovieItem(
        id: 'sample-3',
        title: 'Inception',
        imageUrl: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Ber.jpg',
        rating: 8.8,
        price: 2.99,
      ),
      MovieItem(
        id: 'sample-4',
        title: 'Interstellar',
        imageUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        rating: 8.6,
        price: 4.99,
      ),
      MovieItem(
        id: 'sample-5',
        title: 'The Matrix',
        imageUrl: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
        rating: 8.7,
        price: 1.99,
      ),
      MovieItem(
        id: 'sample-6',
        title: 'Pulp Fiction',
        imageUrl: 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
        rating: 8.9,
        price: 2.99,
      ),
      MovieItem(
        id: 'sample-7',
        title: 'Fight Club',
        imageUrl: 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        rating: 8.8,
        price: 3.99,
      ),
      MovieItem(
        id: 'sample-8',
        title: 'Forrest Gump',
        imageUrl: 'https://image.tmdb.org/t/p/w500/saHP97rTPS5eLmrLQEcANmKrsFl.jpg',
        rating: 8.8,
        price: 2.99,
      ),
    ];
  }

  List<MovieItem> _filterMovies(List<MovieItem> movies, String query, SearchFilters filters) {
    var filtered = movies;

    // Filter by query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((m) => m.title.toLowerCase().contains(lowerQuery)).toList();
    }

    // Filter by price
    if (filters.priceMin != null) {
      filtered = filtered.where((m) => (m.price ?? 0) >= filters.priceMin!).toList();
    }
    if (filters.priceMax != null) {
      filtered = filtered.where((m) => (m.price ?? 0) <= filters.priceMax!).toList();
    }

    // Sort
    switch (filters.sortBy) {
      case SortOption.highestRating:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.lowestRating:
        filtered.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
        break;
      case SortOption.highestPrice:
        filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case SortOption.lowestPrice:
        filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      default:
        break;
    }

    return filtered;
  }
}
