import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/enums/movie_type.dart';
import 'package:movie_fe/core/models/movie_item.dart';
import 'package:movie_fe/core/utils/data/image_constant.dart';
import 'package:movie_fe/core/utils/data/genres.dart';
import 'package:movie_fe/core/widgets/cards/movie_card.dart';
import 'package:movie_fe/routes/app_router.dart';

class ExploreGenre extends ConsumerWidget {
  const ExploreGenre({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24,16,24,16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = 2;
            final double spacing = 12;
            final aspectRatio = 160 / 80;
            final screenWidth = constraints.maxWidth;

            final cardWidth =
                (screenWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

            final cardHeight = cardWidth / aspectRatio;

            final genres = GenresVi.all;
            return GridView.builder(
              itemCount: genres.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, i) {
                final g = genres[i];
                final name = g['name'] ?? '';
                final slug = g['slug'] ?? name;
                final img = g['imageUrl'] ?? ImageConstant.imgCard;
                return MovieCard(
                  width: cardWidth,
                  height: cardHeight,
                  movie: MovieItem(
                    id: slug,
                    title: name,
                    imageUrl: img,
                  ),
                  movieCardType: MovieCardType.titleInImg,
                  onMore: (){
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
      ),
    );
  }
}
