import 'package:flutter/cupertino.dart';

import '../../../i18n/translations.g.dart';

enum FilterSection { sort, price, rating, genre, language, age }

extension FilterSectionX on FilterSection {
  String label(BuildContext context) {
    final t = Translations.of(context);
    switch (this) {
      case FilterSection.sort:
        return t.search.filter.sections.sort;
      case FilterSection.price:
        return t.search.filter.sections.price;
      case FilterSection.rating:
        return t.search.filter.sections.rating;
      case FilterSection.genre:
        return t.search.filter.sections.genre;
      case FilterSection.language:
        return t.search.filter.sections.language;
      case FilterSection.age:
        return t.search.filter.sections.age;
    }
  }
}

enum SortOption {
  trending,
  newReleases,
  highestRating,
  lowestRating,
  highestPrice,
  lowestPrice,
}

extension SortOptionX on SortOption {
  String label(BuildContext context) {
    final t = Translations.of(context);
    switch (this) {
      case SortOption.trending:
        return t.search.filter.sortOptions.trending;
      case SortOption.newReleases:
        return t.search.filter.sortOptions.newReleases;
      case SortOption.highestRating:
        return t.search.filter.sortOptions.highestRating;
      case SortOption.lowestRating:
        return t.search.filter.sortOptions.lowestRating;
      case SortOption.highestPrice:
        return t.search.filter.sortOptions.highestPrice;
      case SortOption.lowestPrice:
        return t.search.filter.sortOptions.lowestPrice;
    }
  }
}

enum RatingOption { all, above45, above40 }

extension RatingOptionX on RatingOption {
  String label(BuildContext context) {
    final t = Translations.of(context);
    switch (this) {
      case RatingOption.all:
        return t.search.all;
      case RatingOption.above45:
        return '4.5+';
      case RatingOption.above40:
        return '4.0+';
    }
  }
}

enum GenreOption {
  all,
  action,
  adventure,
  romance,
  comics,
  comedy,
  fantasy,
  mystery,
  horror,
  scienceFiction,
  thriller,
  travel,
}

extension GenreOptionX on GenreOption {
  String label(BuildContext context) {
    final t = Translations.of(context);
    switch (this) {
      case GenreOption.all:
        return t.search.all;
      case GenreOption.action:
        return t.search.filter.genres.action;
      case GenreOption.adventure:
        return t.search.filter.genres.adventure;
      case GenreOption.romance:
        return t.search.filter.genres.romance;
      case GenreOption.comics:
        return t.search.filter.genres.comics;
      case GenreOption.comedy:
        return t.search.filter.genres.comedy;
      case GenreOption.fantasy:
        return t.search.filter.genres.fantasy;
      case GenreOption.mystery:
        return t.search.filter.genres.mystery;
      case GenreOption.horror:
        return t.search.filter.genres.horror;
      case GenreOption.scienceFiction:
        return t.search.filter.genres.scienceFiction;
      case GenreOption.thriller:
        return t.search.filter.genres.thriller;
      case GenreOption.travel:
        return t.search.filter.genres.travel;
    }
  }
}

enum LanguageOption { all, english, vietnam, others }

extension LanguageOptionX on LanguageOption {
  String label(BuildContext context) {
    final t = Translations.of(context);
    switch (this) {
      case LanguageOption.all:
        return t.search.all;
      case LanguageOption.english:
        return t.search.filter.languages.english;
      case LanguageOption.vietnam:
        return t.search.filter.languages.vietnamese;
      case LanguageOption.others:
        return t.search.filter.languages.others;
    }
  }
}

enum AgeOption { all, above12, above16, above18 }

extension AgeOptionX on AgeOption {
  String label(BuildContext context) {
    final t = Translations.of(context);
    switch (this) {
      case AgeOption.all:
        return t.search.all;
      case AgeOption.above12:
        return t.search.filter.age.above12;
      case AgeOption.above16:
        return t.search.filter.age.above16;
      case AgeOption.above18:
        return t.search.filter.age.above18;
    }
  }
}
