import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/repositories/movie_repository.dart';

final movieDetailProvider = FutureProvider.autoDispose.family<Movie?, String>(
  (ref, movieId) async {
    final repo = ref.watch(movieRepoProvider);
    return await repo.getMovieDetail(movieId);
  },
);

final similarMoviesProvider = StreamProvider.autoDispose.family<List<MovieItem>, String>(
  (ref, movieId) {
    final repo = ref.watch(movieRepoProvider);
    return repo.streamSimilar(movieId);
  },
);

final seriesMoviesProvider = StreamProvider.autoDispose.family<List<MovieItem>, String>(
  (ref, franchiseId) {
    final repo = ref.watch(movieRepoProvider);
    return repo.streamByFranchise(franchiseId);
  },
);

