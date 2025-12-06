import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/repositories/movie_repository.dart';
import '../../domain/enums/discover_section_type.dart';

final discoverSectionProvider = StreamProvider.autoDispose.family<List<MovieItem>, DiscoverSectionType>(
  (ref, sectionType) {
    final repo = ref.watch(movieRepoProvider);

    Stream<List<MovieItem>> stream;
    switch (sectionType) {
      case DiscoverSectionType.topCharts:
        stream = repo.streamTopCharts(limit: 5);
        break;
      case DiscoverSectionType.topSelling:
        stream = repo.streamTopSelling(limit: 4);
        break;
      case DiscoverSectionType.topFree:
        stream = repo.streamTopFree(limit: 4);
        break;
      case DiscoverSectionType.topNewReleases:
        stream = repo.streamTopNewReleases(limit: 4);
        break;
    }

    return stream;
  },
);
