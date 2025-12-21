import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/widgets/lists/movie_carousel.dart';

class MovieSimilarSection extends StatelessWidget {
  const MovieSimilarSection({
    super.key,
    required this.similarMovies,
  });

  final List<MovieItem> similarMovies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.i18n.movie.similar.title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(12),
        MovieCarousel(
          items: similarMovies,
          visibleCards: 2.5,
        ),
      ],
    );
  }
}

