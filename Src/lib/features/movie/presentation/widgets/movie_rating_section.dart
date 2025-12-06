import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/data/format_utils.dart';
import '../../../../core/app_export.dart';
import '../../services/ratings_service.dart';

class MovieRatingSection extends ConsumerStatefulWidget {
  const MovieRatingSection({
    super.key,
    required this.movieId,
    required this.rating,
    required this.reviewCount,
    this.onViewAllPressed,
    this.canRate = true,
  });

  final String movieId;
  final double rating;
  final int reviewCount;
  final VoidCallback? onViewAllPressed;
  final bool canRate;

  @override
  ConsumerState<MovieRatingSection> createState() => _MovieRatingSectionState();
}

class _MovieRatingSectionState extends ConsumerState<MovieRatingSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.i18n.movie.ratings.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: AppColors.primary500,
                size: 24,
              ),
              onPressed: widget.onViewAllPressed,
            ),
          ],
        ),
        const Gap(24),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('ratings')
              .doc(widget.movieId)
              .snapshots(),
          builder: (context, snap) {
            final data = snap.data?.data();
            final avg = (data?['averageRating'] as num?)?.toDouble() ?? (widget.rating);
            final total = (data?['totalReviews'] as num?)?.toInt() ?? (widget.reviewCount);
            final stars = (data?['starsCount'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {};

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avg.toStringAsFixed(1),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 48,
                        ),
                      ),
                      const Gap(8),
                      _buildStarRating(avg),
                      const Gap(12),
                      Text(
                        '(${FormatUtils.formatCount(total)} ${context.i18n.movie.hero.reviews})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                Expanded(
                  child: _buildRatingDistribution(
                    context,
                    theme,
                    textColor,
                    secondaryText,
                    total,
                    stars,
                  ),
                ),
              ],
            );
          },
        ),
        const Gap(32),
        _buildRateSection(context, theme, textColor, secondaryText),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    // Clamp rating to 0-5 range for display (5-star system)
    final normalizedRating = rating.clamp(0.0, 5.0);
    final fullStars = normalizedRating.floor().clamp(0, 5);
    final remainder = normalizedRating - fullStars;
    final hasPartialStar = remainder > 0 && fullStars < 5;
    final emptyStars = (5 - fullStars - (hasPartialStar ? 1 : 0)).clamp(0, 5);

    return Row(
      children: [
        ...List.generate(fullStars, (_) => Icon(
              Icons.star,
              color: AppColors.primary500,
              size: 24,
            )),
        if (hasPartialStar)
          Stack(
            children: [
              Icon(
                Icons.star_border,
                color: AppColors.primary500,
                size: 24,
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: remainder.clamp(0.0, 1.0),
                  child: Icon(
                    Icons.star,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ...List.generate(emptyStars, (_) => Icon(
              Icons.star_border,
              color: AppColors.primary500.withOpacity(0.3),
              size: 24,
            )),
      ],
    );
  }

  Widget _buildRatingDistribution(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
    int totalReviews,
    Map<String, int> stars,
  ) {
    return Column(
      children: List.generate(5, (index) {
        final star = 5 - index;
        final count = stars[star.toString()] ?? 0;
        final pct = totalReviews == 0 ? 0.0 : (count / totalReviews);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '$star',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.getSurface(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary500,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRateSection(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
  ) {
    int selectedStars = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.canRate ? context.i18n.movie.ratings.rateThisFilm : context.i18n.movie.ratings.purchaseRequired,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: widget.canRate ? textColor : secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                return GestureDetector(
                  onTap: widget.canRate
                      ? () {
                          setState(() {
                            selectedStars = starNumber;
                          });
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starNumber <= selectedStars
                          ? Icons.star
                          : Icons.star_border,
                      color: widget.canRate
                          ? (starNumber <= selectedStars
                              ? AppColors.primary500
                              : secondaryText.withOpacity(0.5))
                          : secondaryText.withOpacity(0.3),
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const Gap(24),
            Center(
              child: OutlinedButton(
                onPressed: widget.canRate && selectedStars > 0
                    ? () {
                        _showReviewDialog(context, theme, textColor, secondaryText, selectedStars);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary500,
                  side: BorderSide(color: AppColors.primary500, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  context.i18n.movie.ratings.writeAReview,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: widget.canRate ? AppColors.primary500 : secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReviewDialog(
    BuildContext context,
    ThemeData theme,
    Color textColor,
    Color secondaryText,
    int initialStars,
  ) {
    int selectedStars = initialStars;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.getModalBackground(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              context.i18n.movie.ratings.dialog.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${context.i18n.movie.ratings.dialog.yourRatingPrefix} $selectedStars ${selectedStars == 1 ? context.i18n.movie.ratings.dialog.star : context.i18n.movie.ratings.dialog.stars}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedStars = starNumber;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          starNumber <= selectedStars
                              ? Icons.star
                              : Icons.star_border,
                          color: starNumber <= selectedStars
                              ? AppColors.primary500
                              : secondaryText,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                const Gap(16),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: context.i18n.movie.ratings.dialog.hint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: secondaryText),
                    filled: true,
                    fillColor: AppColors.getSurface(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const Gap(24),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.i18n.movie.ratings.dialog.cancel,
                  style: TextStyle(color: secondaryText),
                ),
              ),
              PrimaryButton(
                text: context.i18n.movie.ratings.dialog.submit,
                onPressed: () async {
                  try {
                    final svc = RatingsService();
                    await svc.submitReview(
                      movieId: widget.movieId,
                      rating: selectedStars,
                      comment: controller.text.trim().isEmpty ? null : controller.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ToastNotification.showSuccess(
                        context,
                        message: context.i18n.movie.ratings.dialog.submitted,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastNotification.showError(
                        context,
                        message: '${context.i18n.common.errorPrefix} ${e.toString()}',
                        duration: const Duration(seconds: 3),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

