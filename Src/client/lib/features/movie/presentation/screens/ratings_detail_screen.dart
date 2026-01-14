import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../services/ratings_service.dart';
import '../../../../core/utils/data/format_utils.dart';

final ratingSummaryProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, movieId) {
  return ref.watch(ratingsServiceProvider).getRatingSummary(movieId);
});

final reviewsProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, movieId) {
  return ref.watch(ratingsServiceProvider).getReviews(movieId);
});

final reviewLikeStatusProvider = FutureProvider.family.autoDispose<bool, Map<String, String>>((ref, params) {
  final movieId = params['movieId']!;
  final reviewUserId = params['reviewUserId']!;
  return ref.watch(ratingsServiceProvider).hasLikedReview(movieId, reviewUserId);
});

class RatingsDetailScreen extends ConsumerWidget {
  const RatingsDetailScreen({super.key, required this.movieId, required this.movieTitle});

  final String movieId;
  final String movieTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    final ratingSummaryAsync = ref.watch(ratingSummaryProvider(movieId));
    final reviewsAsync = ref.watch(reviewsProvider(movieId));

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(context.i18n.movie.ratings.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ratingSummaryAsync.when(
        data: (summary) {
          final avg = (summary['averageRating'] as num?)?.toDouble() ?? 0.0;
          final total = (summary['totalReviews'] as num?)?.toInt() ?? 0;
          final stars = (summary['starsCount'] as Map?)?.map((k, v) => MapEntry(int.tryParse(k.toString()) ?? 0, (v as num).toInt())) ?? {};
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(avg.toStringAsFixed(1), style: theme.textTheme.headlineLarge?.copyWith(color: textColor, fontWeight: FontWeight.w700)),
                          const Gap(8),
                          _buildStars(avg),
                          const Gap(8),
                          Text('(${FormatUtils.formatCount(total)} reviews)', style: theme.textTheme.bodyMedium?.copyWith(color: secondaryText)),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        children: List.generate(5, (i) {
                          final star = 5 - i;
                          final count = stars[star.toString()] ?? stars[star] ?? 0;
                          final pct = total == 0 ? 0.0 : (count / total);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                SizedBox(width: 16, child: Text('$star', style: theme.textTheme.bodySmall?.copyWith(color: secondaryText, fontWeight: FontWeight.w600))),
                                const Gap(8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: AppColors.getSurface(context),
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: reviewsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(child: Text(context.i18n.movie.ratings.noReviews, style: theme.textTheme.bodyLarge?.copyWith(color: secondaryText)));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Gap(16),
                      itemBuilder: (context, i) {
                        final r = items[i];
                        final name = (r['userName'] as String?) ?? 'Anonymous';
                        final avatar = (r['userAvatar'] as String?) ?? '';
                        final rating = (r['rating'] as num?)?.toInt() ?? 0;
                        final comment = (r['comment'] as String?) ?? '';
                        final likes = (r['likes'] as num?)?.toInt() ?? 0;
                        final userId = (r['userId'] as String?) ?? '';
                        final createdAtStr = r['createdAt'] as String?;
                        final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
                        
                        return _ReviewTile(
                          name: name,
                          avatar: avatar,
                          rating: rating,
                          comment: comment,
                          likes: likes,
                          userId: userId,
                          movieId: movieId,
                          timestamp: createdAt,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('${context.i18n.common.errorPrefix} $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStars(double rating) {
    final normalized = rating.clamp(0.0, 5.0);
    final full = normalized.floor();
    final rem = normalized - full;
    return Row(
      children: [
        ...List.generate(full, (_) => Icon(Icons.star, color: AppColors.primary500, size: 22)),
        if (rem > 0) Stack(children: [
          Icon(Icons.star_border, color: AppColors.primary500, size: 22),
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: rem.clamp(0.0, 1.0),
              child: Icon(Icons.star, color: AppColors.primary500, size: 22),
            ),
          )
        ]),
        ...List.generate(5 - full - (rem > 0 ? 1 : 0), (_) => Icon(Icons.star_border, color: AppColors.primary500.withOpacity(0.3), size: 22)),
      ],
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  const _ReviewTile({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.comment,
    required this.likes,
    required this.userId,
    required this.movieId,
    this.timestamp,
  });

  final String name;
  final String avatar;
  final int rating;
  final String comment;
  final int likes;
  final String userId;
  final String movieId;
  final DateTime? timestamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final text = AppColors.getText(context);
    final secondary = AppColors.getTextSecondary(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20, 
              backgroundColor: AppColors.getSurface(context),
              backgroundImage: (avatar.isNotEmpty) ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? Icon(Icons.person, color: secondary) : null,
            ),
            const Gap(12),
            Expanded(child: Text(name, style: theme.textTheme.titleMedium?.copyWith(color: text, fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary500, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: AppColors.primary500, size: 16),
                  const Gap(4),
                  Text('$rating', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Gap(8),
            IconButton(
              icon: Icon(Icons.more_horiz, color: secondary),
              onPressed: () {},
            ),
          ],
        ),
        const Gap(8),
        Text(comment, style: theme.textTheme.bodyMedium?.copyWith(color: text, height: 1.5)),
        const Gap(8),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final svc = ref.read(ratingsServiceProvider);
                await svc.toggleLike(movieId: movieId, reviewUserId: userId);
                ref.invalidate(reviewLikeStatusProvider({'movieId': movieId, 'reviewUserId': userId}));
              },
              child: ref.watch(reviewLikeStatusProvider({'movieId': movieId, 'reviewUserId': userId})).when(
                data: (isLiked) => SvgPicture.asset(
                  ImageConstant.heartIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isLiked ? AppColors.primary500 : secondary,
                    BlendMode.srcIn,
                  ),
                ),
                loading: () => SvgPicture.asset(
                  ImageConstant.heartIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(secondary, BlendMode.srcIn),
                ),
                error: (_, __) => SvgPicture.asset(
                  ImageConstant.heartIcon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(secondary, BlendMode.srcIn),
                ),
              ),
            ),
            const Gap(8),
            Text('$likes', style: theme.textTheme.bodySmall?.copyWith(color: secondary)),
            const Gap(12),
            if (timestamp != null)
              Text(FormatUtils.timeAgo(timestamp!), style: theme.textTheme.bodySmall?.copyWith(color: secondary)),
          ],
        )
      ],
    );
  }
}
