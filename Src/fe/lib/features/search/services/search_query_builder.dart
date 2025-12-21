import '../../../core/utils/api/firebase_query.dart';
import '../entities/filter_section.dart';
import '../entities/search_filter.dart';

class SearchQueryBuilder {
  static FirebaseQuery buildFirestoreQuery(
    FirebaseQuery query,
    SearchFilters filters,
  ) {
    if (filters.sortBy == SortOption.newReleases) {
      final currentYear = DateTime.now().year;
      final minYear = currentYear - 2;
      query = query.gte('year', minYear);
    }
    
    if (filters.genres.isNotEmpty) {
      query = query.arrayContains('category', filters.genres.first);
    }
    
    if (filters.priceMin != null) {
      query = query.gte('price.usd', filters.priceMin!);
    }
    
    if (filters.priceMax != null) {
      query = query.lte('price.usd', filters.priceMax!);
    }
    
    if (filters.ratingMin != null) {
      query = query.gte('tmdb.vote_average', filters.ratingMin! * 2);
    }
    
    final hasPriceFilter = filters.priceMin != null || filters.priceMax != null;
    
    switch (filters.sortBy) {
      case SortOption.trending:
        if (hasPriceFilter) {
          query = query.orderBy('price.usd', descending: false);
        } else {
          query = query.orderBy('view', descending: true);
        }
        break;
      case SortOption.newReleases:
        if (hasPriceFilter) {
          query = query.orderBy('price.usd', descending: false);
        } else {
          query = query.orderBy('year', descending: true);
        }
        break;
      case SortOption.highestRating:
        if (hasPriceFilter) {
          query = query.orderBy('price.usd', descending: false);
        } else {
          query = query.orderBy('tmdb.vote_average', descending: true);
        }
        break;
      case SortOption.lowestRating:
        if (hasPriceFilter) {
          query = query.orderBy('price.usd', descending: false);
        } else {
          query = query.orderBy('tmdb.vote_average', descending: false);
        }
        break;
      case SortOption.highestPrice:
        query = query.orderBy('price.usd', descending: true);
        break;
      case SortOption.lowestPrice:
        query = query.orderBy('price.usd', descending: false);
        break;
    }
    
    return query;
  }
}
