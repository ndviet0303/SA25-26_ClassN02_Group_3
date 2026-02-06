import 'package:equatable/equatable.dart';
import 'package:movie_fe/core/enums/movie_item_type.dart';
import 'movie.dart';

class MovieItem extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final double? rating;
  final double? price;
  final Map<String, dynamic>? priceData; // Full price object with USD and VND
  final MovieItemType type;
  final AccessType accessType;

  const MovieItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.rating,
    this.price,
    this.priceData,
    this.type = MovieItemType.movie,
    this.accessType = AccessType.FREE,
  });

  factory MovieItem.fromMovie(Movie movie) {
    // Fallback image URL nếu không có poster hoặc thumb
    String imageUrl = movie.imageUrl;
    if (imageUrl.isEmpty) {
      imageUrl = 'lib/assets/images/common/card.png';
    }

    return MovieItem(
      id: movie.id,
      title: movie.title,
      imageUrl: imageUrl,
      rating: movie.rating,
      price: movie.priceValue,
      priceData: movie.price,
      type: MovieItemType.movie,
      accessType: movie.accessType,
    );
  }

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    AccessType parseAccessType(dynamic value) {
      if (value == null) return AccessType.FREE;
      final typeStr = value.toString().toUpperCase();
      if (typeStr == 'PREMIUM' || typeStr == 'RENTAL') return AccessType.PREMIUM;
      return AccessType.FREE;
    }

    // Parse image URL - prefer posterUrl, fallback to thumbUrl, then image_url
    String imageUrl = json['posterUrl'] ?? json['thumbUrl'] ?? json['image_url'] ?? '';
    if (imageUrl.isEmpty) {
      imageUrl = 'lib/assets/images/common/card.png';
    }

    // Parse title - prefer name, fallback to title
    String title = json['name'] ?? json['title'] ?? '';

    // Parse rating from tmdbRating, imdbRating, or rating
    double rating = 0.0;
    if (json['tmdbRating'] != null) {
      rating = (json['tmdbRating'] as num).toDouble();
    } else if (json['imdbRating'] != null) {
      rating = (json['imdbRating'] as num).toDouble();
    } else if (json['rating'] != null) {
      rating = (json['rating'] as num).toDouble();
    }

    return MovieItem(
      id: json['id']?.toString() ?? json['slug']?.toString() ?? '',
      title: title,
      imageUrl: imageUrl,
      rating: rating,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      accessType: parseAccessType(json['accessType']),
      type: MovieItemType.values.firstWhere(
          (e) => e.toString() == 'MovieItemType.${json['type']}',
          orElse: () => MovieItemType.movie),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'rating': rating,
      'price': price,
      'accessType': accessType.name,
      'type': type.toString().split('.').last,
    };
  }

  @override
  List<Object?> get props => [id, title, imageUrl, rating, price, priceData, type, accessType];
}