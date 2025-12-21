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

