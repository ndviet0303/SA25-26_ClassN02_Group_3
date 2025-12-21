import 'filter_section.dart';

class SearchFilters {
  final SortOption sortBy;
  final double? priceMin;
  final double? priceMax;
  final double? ratingMin;
  final List<String> genres;
  final LanguageOption language;
  final AgeOption age;

  const SearchFilters({
    this.sortBy = SortOption.trending,
    this.priceMin,
    this.priceMax,
    this.ratingMin,
    this.genres = const [],
    this.language = LanguageOption.all,
    this.age = AgeOption.all,
  });

  SearchFilters copyWith({
    SortOption? sortBy,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    List<String>? genres,
    LanguageOption? language,
    AgeOption? age,
  }) {
    return SearchFilters(
      sortBy: sortBy ?? this.sortBy,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      ratingMin: ratingMin ?? this.ratingMin,
      genres: genres ?? this.genres,
      language: language ?? this.language,
      age: age ?? this.age,
    );
  }
}

