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

  const MovieItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.rating,
    this.price,
    this.priceData,
    this.type = MovieItemType.movie,
  });

  factory MovieItem.fromMovie(Movie movie) {
    // Fallback image URL nếu không có poster hoặc thumb
    String imageUrl = movie.imageUrl;
    if (imageUrl.isEmpty) {
      imageUrl = 'lib/assets/images/common/img_card.png';
    }

    return MovieItem(
      id: movie.id,
      title: movie.title,
      imageUrl: imageUrl,
      rating: movie.rating,
      price: movie.priceValue,
      priceData: movie.price,
      type: MovieItemType.movie,
    );
  }

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
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
      'type': type.toString().split('.').last,
    };
  }

  @override
  List<Object?> get props => [id, title, imageUrl, rating, price, priceData, type];
}