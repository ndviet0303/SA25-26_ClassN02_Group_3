import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/enums/movie_type.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/utils/data/image_constant.dart';
import '../../../../core/utils/data/genres.dart';
import '../../../../core/widgets/cards/movie_card.dart';
import '../../../../routes/app_router.dart';
import '../../../../core/repositories/movie_repository.dart';
import '../../../../i18n/translations.g.dart';
import '../../../../core/extension/context_extensions.dart';
import 'package:go_router/go_router.dart';

class ExploreGenre extends ConsumerWidget {
  const ExploreGenre({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.i18n;
    final genresAsync = ref.watch(genresProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.home.sections.exploreByGenre),
      ),
      body: genresAsync.when(
        data: (apiGenres) {
          if (apiGenres.isEmpty) {
            return Center(child: Text(t.common.empty));
          }
          
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 2;
                const double spacing = 12;
                const aspectRatio = 160 / 80;
                final screenWidth = constraints.maxWidth;

                final cardWidth = (screenWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
                final cardHeight = cardWidth / aspectRatio;

                // Match API genres with local images
                final localGenres = GenresVi.all;

                return GridView.builder(
                  itemCount: apiGenres.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: aspectRatio,
                  ),
                  itemBuilder: (context, i) {
                    final g = apiGenres[i];
                    final name = g['name'] ?? '';
                    final slug = g['slug'] ?? name;
                    
                    // Find image from local list
                    final localMatch = localGenres.firstWhere(
                      (lg) => lg['slug'] == slug || lg['name']?.toLowerCase() == name.toLowerCase(),
                      orElse: () => {},
                    );
                    
                    final img = localMatch['imageUrl'] ?? ImageConstant.imgCard;

                    return MovieCard(
                      width: cardWidth,
                      height: cardHeight,
                      movie: MovieItem(
                        id: slug,
                        title: name,
                        imageUrl: img,
                      ),
                      movieCardType: MovieCardType.titleInImg,
                      onMore: () {
                        context.push('${AppRouter.movieCarouselGenre}$slug');
                      },
                      enableNavigation: false,
                      titleFontSize: 16,
                      overlayOpacity: 0.22,
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${t.common.errorPrefix} $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(genresProvider),
                child: Text(t.common.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
