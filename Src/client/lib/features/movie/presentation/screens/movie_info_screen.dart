import 'package:flutter/material.dart';
import 'package:movie_fe/core/auth/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie.dart';
import '../../data/repositories/movie_repository.dart';
import '../widgets/movie_info_panel.dart';
import '../widgets/movie_series_section.dart';
import '../widgets/movie_similar_section.dart';
import '../widgets/movie_rating_section.dart';
import 'package:movie_fe/core/repositories/wishlist_repository.dart';
import 'package:movie_fe/core/repositories/customer_repository.dart';

class MovieInfoScreen extends ConsumerWidget {
  const MovieInfoScreen({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch complete movie detail to ensure we have all metadata
    final movieDetailAsync = ref.watch(movieDetailProvider(movie.id));
    final textColor = AppColors.getText(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _buildWriteReviewButton(context),
          IconButton(
            icon: Icon(Icons.send_outlined, color: textColor),
            onPressed: () {
              // Share logic
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final isInWishlist = ref.watch(isInWishlistProvider(movie.id)).value ?? false;
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.bookmark : Icons.bookmark_border,
                  color: isInWishlist ? AppColors.primary500 : textColor,
                ),
                onPressed: () async {
                  try {
                    final userId = ref.read(currentUserIdProvider);
                    if (userId == null) {
                      if (context.mounted) {
                        ToastNotification.showError(context, message: "Vui lòng đăng nhập để sử dụng tính năng này");
                      }
                      return;
                    }

                    final repo = ref.read(wishlistRepositoryProvider);
                    if (isInWishlist) {
                      await repo.removeFromWatchlist(userId, movie.id);
                      if (context.mounted) {
                        ToastNotification.showSuccess(context, message: "Đã xóa khỏi danh sách xem sau");
                      }
                    } else {
                      await repo.addToWatchlist(userId, movie.id);
                      if (context.mounted) {
                        ToastNotification.showSuccess(context, message: "Đã thêm vào danh sách xem sau");
                      }
                    }
                    
                    // Refresh state
                    ref.invalidate(isInWishlistProvider(movie.id));
                    ref.invalidate(wishlistProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ToastNotification.showError(context, message: "Lỗi: $e");
                    }
                  }
                },
              );
            },
          ),
          const Gap(12),
        ],
      ),
      body: movieDetailAsync.when(
        data: (fullMovie) => _buildBody(context, ref, fullMovie ?? movie),
        loading: () => _buildBody(context, ref, movie, isLoading: true),
        error: (e, _) => _buildBody(context, ref, movie),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Movie movie, {bool isLoading = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading) const LinearProgressIndicator(),
          MovieInfoPanel(movie: movie),
          const Gap(24),
          _ImagesCarousel(movie: movie),
          const Gap(32),

          // Series Section
          if (movie.franchiseId != null)
            _SeriesSection(franchiseId: movie.franchiseId!, currentMovieTitle: movie.title),

          const Gap(32),

          // Similar Section
          _SimilarSection(movieId: movie.id),

          const Gap(32),

          // Rating Section
          MovieRatingSection(
            movieId: movie.id,
            rating: movie.rating ?? 0.0,
            reviewCount: movie.ratingCount ?? 0,
          ),

          const Gap(48),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          // Open rating section or dialog
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          side: const BorderSide(color: Colors.orange, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: const Text('Viết đánh giá', 
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}

class _SeriesSection extends ConsumerWidget {
  const _SeriesSection({required this.franchiseId, required this.currentMovieTitle});
  final String franchiseId;
  final String currentMovieTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(seriesMoviesProvider(franchiseId));
    return seriesAsync.when(
      data: (items) => items.isEmpty
          ? const SizedBox.shrink()
          : MovieSeriesSection(
              seriesTitle: '"${currentMovieTitle}"',
              seriesMovies: items,
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _SimilarSection extends ConsumerWidget {
  const _SimilarSection({required this.movieId});
  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarAsync = ref.watch(similarMoviesProvider(movieId));
    return similarAsync.when(
      data: (items) => items.isEmpty
          ? const SizedBox.shrink()
          : MovieSimilarSection(similarMovies: items),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _ImagesCarousel extends StatefulWidget {
  const _ImagesCarousel({required this.movie});

  final Movie movie;

  @override
  State<_ImagesCarousel> createState() => _ImagesCarouselState();
}

class _ImagesCarouselState extends State<_ImagesCarousel> {
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _current = 0;
  
  // Static list of images as fallback
  final List<String> _backdropsFallbacks = [
    'https://image.tmdb.org/t/p/original/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
    'https://image.tmdb.org/t/p/original/mXLOHHc1Z3vslZPPiQDDoubleXP.jpg',
    'https://image.tmdb.org/t/p/original/rM5YpT2N65E5K4zAnY9DscQ4R3M.jpg',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final secondaryText = AppColors.getTextSecondary(context);

    final images = [
      if (widget.movie.posterUrl != null && widget.movie.posterUrl!.isNotEmpty) widget.movie.posterUrl!,
      if (widget.movie.thumbUrl != null && widget.movie.thumbUrl!.isNotEmpty) widget.movie.thumbUrl!,
      ..._backdropsFallbacks,
    ].toSet().where((url) => url.startsWith('http')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.i18n.movie.info.images,
          style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
        const Gap(8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) {
                    if (!mounted) return;
                    setState(() => _current = i.clamp(0, images.length - 1));
                  },
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final url = images[index];
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary500,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.getSurface(context),
                        alignment: Alignment.center,
                        child: Text(
                          context.i18n.movie.info.cannotLoadImage,
                          style: theme.textTheme.bodySmall?.copyWith(color: secondaryText),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_current + 1}/${images.length}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
