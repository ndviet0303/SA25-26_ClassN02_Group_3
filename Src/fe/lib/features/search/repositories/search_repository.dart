import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/models/movie.dart';
import '../../../core/utils/api/firebase_query.dart';
import '../entities/search_result.dart';
import '../entities/search_filter.dart';
import '../entities/filter_section.dart';
import '../mappers/search_mapper.dart';
import '../services/search_query_builder.dart';
import '../services/search_logger.dart';

final firestoreProvider = Provider((_) => FirebaseFirestore.instance);

final searchRepositoryProvider = Provider((ref) => SearchRepository(
  ref.watch(firestoreProvider),
));

class SearchRepository {
  final FirebaseFirestore _db;

  SearchRepository(this._db);


  Future<SearchResultsPage<SearchResult>> search(
    String query, {
    SearchFilters filters = const SearchFilters(),
    int page = 1,
    DocumentSnapshot? startAfter,
    List<String>? wishlistMovieIds,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      const pageSize = 10;
      // Nếu search trong wishlist hoặc purchase, fetch movies trực tiếp từ IDs
      List<Movie> allMoviesData;
      var firestoreQuery = FirebaseQuery.collection('movies', firestore: _db);
      
      if (wishlistMovieIds != null && wishlistMovieIds.isNotEmpty) {
        // Firestore whereIn có giới hạn 10 items, cần chunk nếu nhiều hơn
        final chunks = <List<String>>[];
        for (int i = 0; i < wishlistMovieIds.length; i += 10) {
          chunks.add(wishlistMovieIds.sublist(
            i, 
            i + 10 > wishlistMovieIds.length ? wishlistMovieIds.length : i + 10,
          ));
        }
        
        allMoviesData = <Movie>[];
        for (final chunk in chunks) {
          final snapshot = await _db
              .collection('movies')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          allMoviesData.addAll(snapshot.docs.map((doc) => Movie.fromDoc(doc)));
        }
      } else {
        // Normal search - query từ movies collection
        firestoreQuery = SearchQueryBuilder.buildFirestoreQuery(firestoreQuery, filters);
        
        if (query.isNotEmpty && 
            query.toLowerCase() != 'trending' && 
            query.toLowerCase() != 'popular') {
          var snapshot = await firestoreQuery.limit(100).get();
          allMoviesData = snapshot.docs.map((doc) => Movie.fromDoc(doc)).toList();
        } else {
          // Handle trending/popular case - continue with existing logic
          final hasPriceFilter = filters.priceMin != null || filters.priceMax != null;
          final needsManualSort = hasPriceFilter && 
              filters.sortBy != SortOption.highestPrice && 
              filters.sortBy != SortOption.lowestPrice;
          
          if (needsManualSort) {
            var snapshot = await firestoreQuery.limit(pageSize * 10).get();
            var docs = snapshot.docs;
            allMoviesData = docs.map((doc) => Movie.fromDoc(doc)).toList();
          } else {
            var snapshot = await firestoreQuery.limit(pageSize).get();
            allMoviesData = snapshot.docs.map((doc) => Movie.fromDoc(doc)).toList();
          }
        }
      }
      
      // Process query if not empty and not trending/popular
      // Nếu search trong wishlist hoặc purchase, luôn filter theo query (không có trending/popular)
      if (wishlistMovieIds != null && wishlistMovieIds.isNotEmpty) {
        // Wishlist/Purchase search - filter theo query
        var allMovies = allMoviesData.map((m) => MovieItem.fromMovie(m)).toList();
        
        if (query.isNotEmpty) {
          final lowerQuery = query.toLowerCase();
          allMovies = allMovies.where((m) => 
            m.title.toLowerCase().contains(lowerQuery) ||
            (m.id.toLowerCase().contains(lowerQuery))
          ).toList();
        }
        
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        final paginatedMovies = allMovies.skip(startIndex).take(pageSize).toList();
        final paginatedMoviesData = paginatedMovies.map((m) {
          return allMoviesData.firstWhere((md) => md.id == m.id);
        }).toList();
        
        final hasNext = endIndex < allMovies.length;
        
        SearchLogger.logMovies(paginatedMovies, page, filters, paginatedMoviesData);
        
        final results = paginatedMovies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
        
        return SearchResultsPage<SearchResult>(
          items: results,
          page: page,
          pageSize: pageSize,
          total: allMovies.length,
          hasNext: hasNext,
        );
      } else if (query.isNotEmpty && 
          query.toLowerCase() != 'trending' && 
          query.toLowerCase() != 'popular') {
        var allMovies = allMoviesData.map((m) => MovieItem.fromMovie(m)).toList();
        
        final lowerQuery = query.toLowerCase();
        allMovies = allMovies.where((m) => 
          m.title.toLowerCase().contains(lowerQuery) ||
          (m.id.toLowerCase().contains(lowerQuery))
        ).toList();
        
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        final paginatedMovies = allMovies.skip(startIndex).take(pageSize).toList();
        final paginatedMoviesData = paginatedMovies.map((m) {
          return allMoviesData.firstWhere((md) => md.id == m.id);
        }).toList();
        
        final hasNext = endIndex < allMovies.length;
        
        SearchLogger.logMovies(paginatedMovies, page, filters, paginatedMoviesData);
        
        final results = paginatedMovies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
        
        return SearchResultsPage<SearchResult>(
          items: results,
          page: page,
          pageSize: pageSize,
          total: allMovies.length,
          hasNext: hasNext,
        );
      } else {
        final hasPriceFilter = filters.priceMin != null || filters.priceMax != null;
        final needsManualSort = hasPriceFilter && 
            filters.sortBy != SortOption.highestPrice && 
            filters.sortBy != SortOption.lowestPrice;
        
        if (needsManualSort) {
          var snapshot = await firestoreQuery.limit(pageSize * 10).get();
          var docs = snapshot.docs;
          var allMoviesData = docs.map((doc) => Movie.fromDoc(doc)).toList();
          var allMovies = allMoviesData.map((m) => MovieItem.fromMovie(m)).toList();
          
          final moviesWithData = allMovies.map((m) {
            final movieData = allMoviesData.firstWhere((md) => md.id == m.id);
            return (item: m, data: movieData);
          }).toList();
          
          moviesWithData.sort((a, b) {
            if (filters.sortBy == SortOption.trending) {
              final aView = a.data.view ?? 0;
              final bView = b.data.view ?? 0;
              return bView.compareTo(aView);
            } else if (filters.sortBy == SortOption.newReleases) {
              if (a.data.status == 'upcoming' && b.data.status != 'upcoming') return 1;
              if (b.data.status == 'upcoming' && a.data.status != 'upcoming') return -1;
              
              final yearCompare = (b.data.year ?? 0).compareTo(a.data.year ?? 0);
              if (yearCompare != 0) return yearCompare;
              final aView = a.data.view ?? 0;
              final bView = b.data.view ?? 0;
              return bView.compareTo(aView);
            } else if (filters.sortBy == SortOption.highestRating) {
              final aRating = a.item.rating ?? 0.0;
              final bRating = b.item.rating ?? 0.0;
              return bRating.compareTo(aRating);
            } else if (filters.sortBy == SortOption.lowestRating) {
              final aRating = a.item.rating ?? 0.0;
              final bRating = b.item.rating ?? 0.0;
              return aRating.compareTo(bRating);
            }
            return 0;
          });
          
          final startIndex = (page - 1) * pageSize;
          final paginated = moviesWithData.skip(startIndex).take(pageSize).toList();
          final hasNext = startIndex + pageSize < moviesWithData.length;
          
          final movies = paginated.map((e) => e.item).toList();
          final moviesData = paginated.map((e) => e.data).toList();
          
          SearchLogger.logMovies(movies, page, filters, moviesData);
          
          final results = movies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
          
          return SearchResultsPage<SearchResult>(
            items: results,
            page: page,
            pageSize: pageSize,
            total: moviesWithData.length,
            hasNext: hasNext,
          );
        } else {
          final isNewReleases = filters.sortBy == SortOption.newReleases;
          
          if (isNewReleases) {
            var snapshot = await firestoreQuery.limit(pageSize * 10).get();
            var docs = snapshot.docs;
            var allMoviesData = docs.map((doc) => Movie.fromDoc(doc)).toList();
            
            final filteredMoviesData = allMoviesData.where((m) => 
              m.status != 'upcoming' && m.year != null
            ).toList();
            
            var allMovies = filteredMoviesData.map((m) => MovieItem.fromMovie(m)).toList();
            
            final moviesWithData = allMovies.map((m) {
              final movieData = filteredMoviesData.firstWhere((md) => md.id == m.id);
              return (item: m, data: movieData);
            }).toList();
            
            moviesWithData.sort((a, b) {
              final yearCompare = (b.data.year ?? 0).compareTo(a.data.year ?? 0);
              if (yearCompare != 0) return yearCompare;
              final aView = a.data.view ?? 0;
              final bView = b.data.view ?? 0;
              return bView.compareTo(aView);
            });
            
            final startIndex = (page - 1) * pageSize;
            final paginated = moviesWithData.skip(startIndex).take(pageSize).toList();
            final hasNext = startIndex + pageSize < moviesWithData.length;
            
            final movies = paginated.map((e) => e.item).toList();
            final moviesData = paginated.map((e) => e.data).toList();
            
            SearchLogger.logMovies(movies, page, filters, moviesData);
            
            final results = movies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
            
            return SearchResultsPage<SearchResult>(
              items: results,
              page: page,
              pageSize: pageSize,
              total: moviesWithData.length,
              hasNext: hasNext,
            );
          }
          
          if (page > 1 && startAfter != null) {
            firestoreQuery = firestoreQuery.startAfter([startAfter]);
          }
          
          var snapshot = await firestoreQuery.limit(pageSize + 1).get();
          var docs = snapshot.docs;
          var moviesData = docs.map((doc) => Movie.fromDoc(doc)).toList();
          var movies = moviesData.map((m) => MovieItem.fromMovie(m)).toList();
          
          final hasNext = movies.length > pageSize;
          DocumentSnapshot? lastDoc;
          if (hasNext) {
            lastDoc = docs[pageSize - 1];
            movies = movies.take(pageSize).toList();
            moviesData = moviesData.take(pageSize).toList();
          } else if (movies.isNotEmpty) {
            lastDoc = docs.last;
          }
          
          SearchLogger.logMovies(movies, page, filters, moviesData);
          
          final results = movies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
        
          return SearchResultsPage<SearchResult>(
            items: results,
            page: page,
            pageSize: pageSize,
            total: hasNext ? page * pageSize + 1 : page * pageSize,
            hasNext: hasNext,
            lastDoc: lastDoc,
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }


  Future<List<String>> getSuggestions(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      if (query.isEmpty) return [];
      
      final snapshot = await FirebaseQuery.collection('movies', firestore: _db)
          .orderBy('year', descending: true)
          .get();
      
      final allMovies = snapshot.docs.map((doc) => Movie.fromDoc(doc)).toList();
      final suggestions = allMovies
          .where((movie) => movie.name.toLowerCase().contains(query.toLowerCase()))
          .map((movie) => movie.name)
          .toSet()
          .toList();
      
      return suggestions.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SearchResult>> getTrendingMovies() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final snapshot = await FirebaseQuery.collection('movies', firestore: _db)
          .orderBy('view', descending: true)
          .limit(8)
          .get();
      final movies = snapshot.docs
          .map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc)))
          .toList();
      return movies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
    } catch (e) {
      throw Exception('Failed to get trending movies: $e');
    }
  }

  Future<List<SearchResult>> getPopularMovies() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final snapshot = await FirebaseQuery.collection('movies', firestore: _db)
          .orderBy('view', descending: true)
          .limit(8)
          .get();
      final movies = snapshot.docs
          .map((doc) => MovieItem.fromMovie(Movie.fromDoc(doc)))
          .toList();
      return movies.map((m) => SearchMapper.movieItemToSearchResult(m)).toList();
    } catch (e) {
      throw Exception('Failed to get popular movies: $e');
    }
  }

}
