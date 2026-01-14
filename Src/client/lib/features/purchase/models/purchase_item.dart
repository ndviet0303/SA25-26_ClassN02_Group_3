import '../../../../core/models/movie_item.dart';

class PurchaseItem extends MovieItem {
  final bool isDownloaded;
  final bool isFinished;

  const PurchaseItem({
    required super.id,
    required super.title,
    required super.imageUrl,
    super.rating,
    super.price,
    this.isDownloaded = false,
    this.isFinished = false,
  }) : super();

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id']?.toString() ?? json['movieId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['posterUrl']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      isDownloaded: json['isDownloaded'] ?? false,
      isFinished: json['isFinished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'rating': rating,
      'price': price,
      'isDownloaded': isDownloaded,
      'isFinished': isFinished,
    };
  }

  PurchaseItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? rating,
    double? price,
    bool? isDownloaded,
    bool? isFinished,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
