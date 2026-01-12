import '../../../../core/models/movie_item.dart';
import '../../../core/utils/data/price_utils.dart';
import '../entities/search_result.dart';

class SearchMapper {
  static Map<String, dynamic> movieItemToMap(MovieItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'subtitle': null,
      'imageUrl': item.imageUrl,
      'rating': item.rating ?? 0.0,
      'ratingCount': 0,
      'price': item.priceData ?? item.price,
      'genres': ['General'],
      'isTrending': false,
      'isNew': false,
      'releaseDate': 'Unknown',
      'views': '0',
    };
  }

  static SearchResult toSearchResult(Map<String, dynamic> movie) {
    final releaseDate = movie['releaseDate'] as String;
    final releaseYear = releaseDate.split(',').last.trim();
    
    return SearchResult(
      id: movie['id'] as String,
      title: movie['title'] as String,
      subtitle: movie['subtitle'] as String?,
      imageUrl: movie['imageUrl'] as String,
      type: SearchResultType.movie,
      rating: movie['rating'] as double,
      ratingCount: movie['ratingCount'] as int,
      genres: List<String>.from(movie['genres'] as List),
      releaseYear: releaseYear,
      metadata: {
        'popularity': (movie['views'] as String).replaceAll('M+', '').replaceAll('K+', ''),
        'vote_average': movie['rating'] as double,
        'vote_count': movie['ratingCount'] as int,
        'price': PriceUtils.getPriceValue(movie['price']),
        'priceData': movie['price'] is Map ? movie['price'] as Map<String, dynamic> : null,
      },
    );
  }

  static SearchResult movieItemToSearchResult(MovieItem item) {
    return toSearchResult(movieItemToMap(item));
  }
}
