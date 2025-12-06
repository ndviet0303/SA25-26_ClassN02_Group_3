import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/widgets/lists/movie_carousel.dart';

class MovieSeriesSection extends StatelessWidget {
  const MovieSeriesSection({
    super.key,
    required this.seriesTitle,
    required this.seriesMovies,
    this.onViewAllPressed,
  });

  final String seriesTitle;
  final List<MovieItem> seriesMovies;
  final VoidCallback? onViewAllPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                seriesTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: AppColors.primary500,
              ),
              onPressed: onViewAllPressed,
            ),
          ],
        ),
        const Gap(12),
        MovieCarousel(
          items: seriesMovies,
          visibleCards: 2.5,
        ),
      ],
    );
  }
}

