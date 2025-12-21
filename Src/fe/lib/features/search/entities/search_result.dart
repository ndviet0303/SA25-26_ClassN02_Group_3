import 'package:cloud_firestore/cloud_firestore.dart';

class Money {
  final String currency; // e.g., "USD"
  final double amount;
  const Money({required this.currency, required this.amount});
}

enum MediaType { movie, series, short, documentary }
enum AgeRating { all, under12, teen13, mature17, adult18 }
enum LanguageCode { en, vi, zh, other }

class MovieSearchItem {
  final String id;
  final String title;               // Movie title
  final String? subtitle;           // Optional (e.g., "Part II")
  final String director;            // or main creator
  final List<String> cast;          // Main actors
  final List<String> genres;        // ["Fantasy","Mystery"]
  final double rating;              // 0.0–5.0
  final int ratingCount;            // number of votes
  final Money price;                // rent/buy
  final Money? discountPrice;       // sale
  final String posterUrl;           // poster image
  final MediaType type;             // movie/series/etc
  final LanguageCode language;
  final AgeRating ageRating;

  // Series info (for franchises like Harry Potter, LOTR)
  final String? franchiseId;
  final String? franchiseName;
  final int? partNumber;            // e.g., 7

  final DateTime? releaseDate;
  final bool isTrending;
  final bool isNew;

  const MovieSearchItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.director,
    this.cast = const [],
    required this.genres,
    required this.rating,
    required this.ratingCount,
    required this.price,
    this.discountPrice,
    required this.posterUrl,
    required this.type,
    required this.language,
    required this.ageRating,
    this.franchiseId,
    this.franchiseName,
    this.partNumber,
    this.releaseDate,
    this.isTrending = false,
    this.isNew = false,
  });
}

class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final SearchResultType type;
  final double? rating;
  final int? ratingCount;
  final List<String> genres;
  final String? releaseYear;
  final Map<String, dynamic> metadata;

  const SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.type,
    this.rating,
    this.ratingCount,
    this.genres = const [],
    this.releaseYear,
    this.metadata = const {},
  });
}

enum SearchResultType {
  movie,
  tvShow,
  actor,
  director,
  genre,
}

class SearchResultsPage<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int total;
  final bool hasNext;
  final DocumentSnapshot? lastDoc;

  const SearchResultsPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    this.hasNext = false,
    this.lastDoc,
  });
}
