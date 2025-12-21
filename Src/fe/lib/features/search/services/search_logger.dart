import '../../../../core/models/movie_item.dart';
import '../../../../core/models/movie.dart';
import '../../../core/utils/data/price_utils.dart';
import '../entities/filter_section.dart';
import '../entities/search_filter.dart';

class SearchLogger {
  static void logMovies(
    List<MovieItem> movies,
    int page,
    SearchFilters filters,
    List<Movie> moviesData,
  ) {
    print('[Search] Page $page - Loaded ${movies.length} items:');
    final movieDataMap = <String, Movie>{};
    for (final movie in moviesData) {
      movieDataMap[movie.id] = movie;
    }
    
    for (final movieItem in movies) {
      final movie = movieDataMap[movieItem.id];
      final info = <String>[];
      info.add('Movie ID: ${movieItem.id}');
      
      if (filters.sortBy == SortOption.trending && movie != null) {
        info.add('view: ${movie.view ?? 0}');
      }
      if (filters.sortBy == SortOption.highestRating || filters.sortBy == SortOption.lowestRating) {
        info.add('rating: ${movieItem.rating?.toStringAsFixed(1) ?? 'N/A'}');
      }
      if (filters.sortBy == SortOption.highestPrice || filters.sortBy == SortOption.lowestPrice) {
        final price = PriceUtils.getPriceValue(movieItem.priceData ?? movieItem.price);
        if (price != null) {
          info.add('price: ${price.toStringAsFixed(2)}');
        }
      }
      if (movieItem.rating != null && !info.any((i) => i.contains('rating'))) {
        info.add('rating: ${movieItem.rating!.toStringAsFixed(1)}');
      }
      if (movie != null && movie.view != null && !info.any((i) => i.contains('view'))) {
        info.add('view: ${movie.view}');
      }
      
      print('  - ${info.join(' | ')}');
    }
  }
}
