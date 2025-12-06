import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/enums/movie_type.dart';

import '../../models/movie_item.dart';
import '../../theme/app_colors.dart';
import '../../utils/data/image_constant.dart';
import '../../utils/data/price_utils.dart';
import '../../../routes/app_router.dart';
import '../image_utils.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.width = 180,
    this.height = 276,
    this.movieCardType = MovieCardType.horizontal,
    this.onMore,
    this.genres,
    this.enableNavigation = true,
    this.titleFontSize,
    this.overlayOpacity,
  });

  final MovieItem movie;
  final double width;
  final double height;

  final MovieCardType movieCardType;

  final List<String>? genres;

  final VoidCallback? onMore;
  
  final bool enableNavigation;
  
  /// Custom fontSize for title when using titleInImg type. If null, uses default (9 * scale)
  final double? titleFontSize;

  /// Optional overlay opacity for title-in-image cards to improve text contrast
  final double? overlayOpacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scale = width / 180;

    void _handleTap(BuildContext context) {
      if (onMore != null) {
        onMore!();
      } else if (enableNavigation) {
        context.push('${AppRouter.movie}/${movie.id}');
      }
    }

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: movieCardType == MovieCardType.vertical
          ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: _buildPosterImage(),
            ),
            const Gap(12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(theme, scale),
                  const Gap(4),
                  if (genres != null) ...[
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: genres!.map((g) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.greyscale800 : AppColors.greyscale200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(g),
                      )).toList(),
                    ),
                    const Gap(12),
                  ],
                  if (movie.price != null && movie.rating != null)
                    _buildMetadata(theme, isDark, scale, type: movieCardType),
                ],
              ),
            ),
          ],
        )
          : SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (movieCardType != MovieCardType.titleInImg) ...[
              _buildPosterImage(),
              const Gap(8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitle(theme, scale),
                    const Spacer(),
                    if (movie.price != null && movie.rating != null)
                      _buildMetadata(theme, isDark, scale),
                  ],
                ),
              ),
            ] else ...[
              Stack(
                children: [
                  _buildPosterImage(),
                  if (overlayOpacity != null)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(overlayOpacity!.clamp(0.0, 1.0)),
                      ),
                    ),
                  Positioned(
                    bottom: 6,
                    left: 8,
                    child: _buildTitle2(scale, titleFontSize),
                  ),
                ],
              ),
              if (movie.price != null && movie.rating != null) ...[
                const Gap(6),
                _buildMetadata(theme, isDark, scale),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPosterImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: NetworkOrAssetImage(
        imageUrl: movie.imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, double scale) {
    return Text(
      movie.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18 * scale,
      ),
    );
  }

  Widget _buildTitle2(double scale, double? customFontSize) {
    final fontSize = customFontSize ?? (9 * scale);
    return Text(
      movie.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
      ),
    );
  }

  Widget _buildMetadata(ThemeData theme, bool isDark, double scale, { MovieCardType type = MovieCardType.horizontal}) {
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14 * scale,
      color: isDark ? AppColors.greyscale300 : AppColors.greyscale700,
    );

    return type == MovieCardType.horizontal ? Row(
      children: [
        _buildRating(textStyle, scale),
        const Gap(12),
        _buildPrice(textStyle),
      ],
    ) : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRating(textStyle, scale),
        const Gap(12),
        _buildPrice(textStyle),
      ],
    );
  }

  Widget _buildRating(TextStyle? textStyle, double scale) {
    return Row(
      children: [
        SvgPicture.asset(
          ImageConstant.groupIcon,
          width: 16 * scale,
          height: 16 * scale,
        ),
        const Gap(6),
        Text(movie.rating?.toStringAsFixed(1) ?? '0.0', style: textStyle),
      ],
    );
  }

  Widget _buildPrice(TextStyle? textStyle) {
    final priceText = PriceUtils.formatPrice(movie);
    
    if (priceText.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Text(priceText, style: textStyle);
  }
}
