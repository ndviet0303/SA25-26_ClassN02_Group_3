import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/data/format_utils.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/utils/data/price_utils.dart';
import '../../../../core/utils/data/format_utils.dart';
import '../../../../core/utils/data/text_utils.dart';
import '../../../../core/widgets/image_utils.dart';

class MovieHeroSection extends StatelessWidget {
  const MovieHeroSection({
    super.key,
    required this.movie,
    required this.author,
    required this.genres,
    required this.metadata,
    required this.description,
    required this.onBuyPressed,
    required this.onViewMorePressed,
    this.isPurchased = false,
    this.ratingCount,
    this.durationText,
    this.qualityText,
    this.viewsText,
  });

  final MovieItem movie;
  final String author;
  final List<String> genres;
  final String metadata;
  final String description;
  final VoidCallback? onBuyPressed;
  final VoidCallback? onViewMorePressed;
  final bool isPurchased;
  final int? ratingCount;
  final String? durationText; // e.g., "2h 10m"
  final String? qualityText;  // e.g., "1080p"
  final String? viewsText;    // e.g., "50M+ views"

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroInfo(context, theme, textColor, secondaryText),
        const Gap(24),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('ratings')
              .doc(movie.id)
              .snapshots(),
          builder: (context, snap) {
            final data = snap.data?.data();
            final avg = (data?['averageRating'] as num?)?.toDouble() ?? (movie.rating ?? 0.0);
            final total = (data?['totalReviews'] as num?)?.toInt() ?? (ratingCount ?? 0);
            return _buildMetrics(context, theme, textColor, secondaryText, avg, total);
          },
        ),
        const Gap(16),
        _buildBuyButton(context, theme),
        const Gap(32),
        _buildAboutSection(context, theme, textColor, secondaryText),
      ],
    );
  }

  Widget _buildHeroInfo(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: NetworkOrAssetImage(
            imageUrl: movie.imageUrl,
            width: 120,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(8),
              Text(
                '$author',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: secondaryText,
                ),
              ),
              const Gap(16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.getSurface(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      genre,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Gap(16),
              
            ],
          ),
        ),

        

      ],
    );
  }

  Widget _buildMetrics(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
    double avgRating,
    int totalReviews,
  ) {
    final ratingVal = avgRating.toStringAsFixed(1);
    final ratingCountShort = FormatUtils.formatCount(totalReviews);
    final ratingCaption = ratingCountShort == '—'
        ? context.i18n.movie.hero.ratings
        : '$ratingCountShort ${context.i18n.movie.hero.reviews}';
    final duration = FormatUtils.formatDuration(durationText);
    final quality = (qualityText == null || qualityText!.isEmpty) ? context.i18n.movie.details.quality1080p : qualityText!;
    final watchedShort = FormatUtils.formatWatched(viewsText);

    Widget metric(String value, String caption) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(color: secondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            metric(ratingVal, ratingCaption),
            const SizedBox(width: 12),
            metric(duration, context.i18n.movie.hero.duration),
            const SizedBox(width: 12),
            metric(quality, context.i18n.movie.hero.quality),
            const SizedBox(width: 12),
            metric(watchedShort, context.i18n.movie.hero.watched),
          ],
        ),
      ],
    );
  }

  

  Widget _buildBuyButton(BuildContext context, ThemeData theme) {
    final isFree = PriceUtils.isFree(movie);
    final shouldShowWatchNow = isFree || isPurchased;
    
    final buttonText = shouldShowWatchNow 
        ? context.i18n.movie.hero.watchNow 
        : PriceUtils.formatPriceForButton(movie);
    
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: buttonText,
        onPressed: onBuyPressed,
      ),
    );
  }

  Widget _buildAboutSection(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.i18n.movie.hero.aboutThisFilm,
              style: theme.textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: onViewMorePressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.i18n.movie.hero.viewMore,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.primary500,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(12),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryText,
              height: 1.5,
            ),
            children: TextUtils.buildDescriptionSpans(description, theme, secondaryText),
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

