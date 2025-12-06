import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:movie_fe/core/enums/movie_type.dart';

import '../../models/movie_item.dart';
import '../../theme/app_colors.dart';
import '../cards/movie_card.dart';

class MovieCarousel extends StatelessWidget {
  const MovieCarousel({
    super.key,
    this.title,
    required this.items,
    this.visibleCards = 2.2,
    this.spacing = 16.0,
    this.onMore,
    this.movieCarouselType = MovieCarouselType.normal,
  });

  /// Tiêu đề section
  final String? title;

  /// Danh sách phim
  final List<MovieItem> items;

  /// Số card hiển thị trên màn hình (vd: 2.2, 2.5)
  final double visibleCards;

  /// Khoảng cách giữa các card
  final double spacing;

  /// Callback khi bấm "Xem thêm"
  final VoidCallback? onMore;

  final MovieCarouselType movieCarouselType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTitle = title != null && title!.isNotEmpty;
    final aspectRatio = switch (movieCarouselType) {
      MovieCarouselType.minimal => 160 / 80,
      MovieCarouselType.normal => 180 / 276,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardWidth = _calculateCardWidth(screenWidth);
        final totalHeight = _calculateTotalHeight(cardWidth,aspectRatio);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTitle) ...[_buildHeader(theme, cardWidth), const Gap(10)],
            _buildMovieList(cardWidth, totalHeight, aspectRatio,movieCarouselType),
          ],
        );
      },
    );
  }

  double _calculateCardWidth(double screenWidth) {
    return (screenWidth - spacing * (visibleCards - 1)) / visibleCards;
  }

  double _calculateTotalHeight(double cardWidth,double aspectRatio) {
    final posterHeight = cardWidth / aspectRatio;
    const titleGap = 8.0;
    const metaGap = 6.0;
    const approxTitle2Lines = 48.0; // ~2 lines body
    const approxMetaRow = 24.0; // ~1 line meta

    return posterHeight +
        titleGap +
        approxTitle2Lines +
        metaGap +
        approxMetaRow;
  }

  Widget _buildHeader(ThemeData theme, double cardWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title!,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24 * (cardWidth / 180),
            ),
          ),
        ),
        const Gap(12),
        IconButton(
          onPressed: onMore,
          icon: const Icon(
            Icons.arrow_forward,
            size: 24,
            color: AppColors.primary500,
          ),
        ),
      ],
    );
  }

  Widget _buildMovieList(
    double cardWidth,
    double totalHeight,
    double aspectRatio,
    MovieCarouselType type,
  ) {
    final posterHeight = cardWidth / aspectRatio;

    return SizedBox(
      height: totalHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final movie = items[index];
          return MovieCard(
            movie: movie,
            width: cardWidth,
            height: posterHeight,
            movieCardType: type == MovieCarouselType.minimal ? MovieCardType.titleInImg : type == MovieCarouselType.normal ? MovieCardType.horizontal : MovieCardType.vertical,
            enableNavigation: true,
          );
        },
      ),
    );
  }
}
