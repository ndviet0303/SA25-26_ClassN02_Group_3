import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../services/ratings_service.dart';
import '../../../../core/utils/data/format_utils.dart';

final _firestoreProvider = Provider((_) => FirebaseFirestore.instance);
final _authProvider = Provider((_) => FirebaseAuth.instance);

final ratingDocProvider = StreamProvider.family.autoDispose<Map<String, dynamic>?, String>((ref, movieId) {
  return ref.watch(_firestoreProvider).collection('ratings').doc(movieId).snapshots().map((d) => d.data());
});

final reviewsProvider = StreamProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, movieId) {
  return ref
      .watch(_firestoreProvider)
      .collection('ratings')
      .doc(movieId)
      .collection('reviews')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((e) => e.data()).toList());
});

final reviewLikeStatusProvider = StreamProvider.family.autoDispose<bool, Map<String, String>>((ref, params) {
  final movieId = params['movieId']!;
  final reviewUserId = params['reviewUserId']!;
  final currentUserId = ref.watch(_authProvider).currentUser?.uid;
  
  if (currentUserId == null) {
    return Stream.value(false);
  }
  
  return ref
      .watch(_firestoreProvider)
      .collection('ratings')
      .doc(movieId)
      .collection('reviews')
      .doc(reviewUserId)
      .snapshots()
      .map((snap) {
        if (!snap.exists) return false;
        final data = snap.data();
        final likedBy = List<String>.from((data?['likedBy'] as List?) ?? []);
        return likedBy.contains(currentUserId);
      });
});

class RatingsDetailScreen extends ConsumerWidget {
  const RatingsDetailScreen({super.key, required this.movieId, required this.movieTitle});

  final String movieId;
  final String movieTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    final ratingDoc = ref.watch(ratingDocProvider(movieId));
    final reviews = ref.watch(reviewsProvider(movieId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.i18n.movie.ratings.title),
      ),
      body: ratingDoc.when(
        data: (doc) {
          final avg = (doc?['averageRating'] as num?)?.toDouble() ?? 0.0;
          final total = (doc?['totalReviews'] as num?)?.toInt() ?? 0;
          final stars = (doc?['starsCount'] as Map?)?.map((k, v) => MapEntry(int.tryParse(k.toString()) ?? 0, (v as num).toInt())) ?? {};
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
                          Text(avg.toStringAsFixed(1), style: t.textTheme.headlineLarge?.copyWith(color: textColor, fontWeight: FontWeight.w700)),
                          const Gap(8),
                          _buildStars(avg),
                          const Gap(8),
                          Text('(${FormatUtils.formatCount(total)} reviews)', style: t.textTheme.bodyMedium?.copyWith(color: secondaryText)),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        children: List.generate(5, (i) {
                          final star = 5 - i;
                          final count = stars[star] ?? 0;
                          final pct = total == 0 ? 0.0 : (count / total);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                SizedBox(width: 16, child: Text('$star', style: t.textTheme.bodySmall?.copyWith(color: secondaryText, fontWeight: FontWeight.w600))),
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
                child: reviews.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(child: Text(context.i18n.movie.ratings.noReviews, style: t.textTheme.bodyLarge?.copyWith(color: secondaryText)));
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
                        final createdAt = (r['updatedAt'] ?? r['createdAt']);
                        return _ReviewTile(
                          name: name,
                          avatar: avatar,
                          rating: rating,
                          comment: comment,
                          likes: likes,
                          userId: userId,
                          movieId: movieId,
                          timestamp: createdAt is Timestamp ? createdAt.toDate() : null,
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
    final t = Theme.of(context);
    final text = AppColors.getText(context);
    final secondary = AppColors.getTextSecondary(context);
    final me = ref.watch(_authProvider).currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: (avatar.isNotEmpty) ? NetworkImage(avatar) : null),
            const Gap(12),
            Expanded(child: Text(name, style: t.textTheme.titleMedium?.copyWith(color: text, fontWeight: FontWeight.w700))),
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
                  Text('$rating', style: t.textTheme.bodyMedium?.copyWith(color: AppColors.primary500, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Gap(8),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ],
        ),
        const Gap(8),
        Text(comment, style: t.textTheme.bodyMedium?.copyWith(color: text, height: 1.5)),
        const Gap(8),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                await RatingsService().toggleLike(movieId: movieId, reviewUserId: userId);
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
            Text('${likes}', style: t.textTheme.bodySmall?.copyWith(color: secondary)),
            const Gap(12),
            if (timestamp != null)
              Text(FormatUtils.timeAgo(timestamp!), style: t.textTheme.bodySmall?.copyWith(color: secondary)),
          ],
        )
      ],
    );
  }
}


