import '../../../../features/search/entities/search_filter.dart';
import '../../../../features/search/entities/filter_section.dart';
import '../../../../i18n/translations.g.dart';

enum DiscoverSectionType {
  topCharts,
  recommendations,
  topFree,
  topNewReleases,
}

extension DiscoverSectionTypeExtension on DiscoverSectionType {
  String get title {
    switch (this) {
      case DiscoverSectionType.topCharts:
        return t.discover.sections.topCharts;
      case DiscoverSectionType.recommendations:
        return t.home.sections.recommendedForYou;
      case DiscoverSectionType.topFree:
        return t.discover.sections.topFree;
      case DiscoverSectionType.topNewReleases:
        return t.discover.sections.topNewReleases;
    }
  }

  String get searchQuery {
    switch (this) {
      case DiscoverSectionType.topCharts:
        return 'trending';
      case DiscoverSectionType.recommendations:
        return 'recommended';
      case DiscoverSectionType.topFree:
        return 'free';
      case DiscoverSectionType.topNewReleases:
        return 'new releases';
    }
  }

  SearchFilters get filters {
    switch (this) {
      case DiscoverSectionType.topCharts:
        return const SearchFilters(
          sortBy: SortOption.trending,
        );
      case DiscoverSectionType.recommendations:
        return const SearchFilters(
          sortBy: SortOption.highestRating,
        );
      case DiscoverSectionType.topFree:
        return const SearchFilters(
          priceMax: 0.0,
        );
      case DiscoverSectionType.topNewReleases:
        return const SearchFilters(
          sortBy: SortOption.newReleases,
        );
    }
  }
}

