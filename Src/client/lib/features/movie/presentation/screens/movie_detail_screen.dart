import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_export.dart';
import '../../../../core/models/movie_item.dart';
import '../../../../core/models/movie.dart';
import '../../../../core/widgets/image_utils.dart';
import '../../../../core/widgets/feedback/toast_notification.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../routes/app_router.dart';
import '../../data/repositories/movie_repository.dart';
import 'package:movie_fe/core/repositories/wishlist_repository.dart';
import '../widgets/movie_hero_section.dart';
import '../widgets/movie_rating_section.dart';
import '../widgets/movie_series_section.dart';
import '../widgets/movie_similar_section.dart';
import '../widgets/movie_info_panel.dart';
import 'package:movie_fe/core/repositories/customer_repository.dart';
import 'package:movie_fe/core/repositories/subscription_repository.dart';


class _WishlistButton extends ConsumerWidget {
  const _WishlistButton({required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWishlistAsync = ref.watch(isInWishlistProvider(movieId));

    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: isInWishlistAsync.when(
          data: (isInWishlist) => Icon(
            isInWishlist ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
            size: 20,
          ),
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          error: (_, __) => const Icon(
            Icons.bookmark_border,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
      onPressed: () async {
        try {
          final userId = ref.read(currentUserIdProvider);
          if (userId == null) {
            if (context.mounted) {
              ToastNotification.showError(context, message: "Please login to use this feature");
            }
            return;
          }

          final repo = ref.read(wishlistRepositoryProvider);
          final isInWishlist = isInWishlistAsync.value ?? false;

          if (isInWishlist) {
            await repo.removeFromWatchlist(userId, movieId);
          } else {
            await repo.addToWatchlist(userId, movieId);
          }

          // Invalidate to refresh UI and list
          ref.invalidate(isInWishlistProvider(movieId));
          ref.invalidate(wishlistProvider);

          if (context.mounted) {
            ToastNotification.showSuccess(
              context,
              message: !isInWishlist ? 'Added to watchlist' : 'Removed from watchlist',
              duration: const Duration(seconds: 2),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ToastNotification.showError(
              context,
              message: 'Error: ${e.toString()}',
              duration: const Duration(seconds: 2),
            );
          }
        }
      },
    );
  }
}

class MovieDetailScreen extends ConsumerStatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  final String movieId;

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);
    final movieDetailAsync = ref.watch(movieDetailProvider(widget.movieId));

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      extendBodyBehindAppBar: true,
      body: movieDetailAsync.when(
        data: (movie) {
          if (movie == null) {
            return Scaffold(
              appBar: _buildAppBar(context, textColor, null),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.movie, size: 64, color: Colors.grey),
                    const Gap(16),
                    Text(
                      context.i18n.movie.details.notFound,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      ImageConstant.sendIcon,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement share
                  },
                ),
                _WishlistButton(movieId: movie.id),
                const SizedBox(width: 8),
              ],
            ),
            body: _buildMovieContent(context, theme, movie),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const Gap(16),
              Text(
                '${context.i18n.common.errorPrefix} ${error.toString()}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieContent(
    BuildContext context,
    ThemeData theme,
    Movie movie,
  ) {
    final user = ref.watch(currentAuthUserProvider);
    final userId = user?.id ?? '';
    final isSubscribed = ref.watch(isUserSubscribedProvider(userId)).value ?? false;
    
    bool shouldWatchNow = false;
    String? buttonOverrideText;
    
    if (movie.accessType == AccessType.FREE) {
      shouldWatchNow = true;
    } else if (movie.accessType == AccessType.PREMIUM) {
      // Treat RENTAL as PREMIUM now or just ignore it
      shouldWatchNow = isSubscribed;
      if (!isSubscribed) {
        buttonOverrideText = context.i18n.movie.hero.getPremium;
      }
    }

    final movieItem = MovieItem(
      id: movie.id,
      title: movie.title,
      imageUrl: movie.imageUrl,
      rating: movie.rating,
      price: movie.priceValue,
      priceData: movie.price,
      accessType: movie.accessType,
    );

    return CustomScrollView(
      slivers: [
        // Hero Image with Gradient Overlay
        SliverToBoxAdapter(
          child: Stack(
            children: [
              _buildHeroImage(context, movieItem.imageUrl),
              // Gradient overlay for better text visibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        SliverPadding(
          padding: ResponsivePadding.content(context),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              MovieHeroSection(
                movie: movieItem,
                author: movie.directorString.isEmpty ? 'Unknown' : movie.directorString,
                genres: movie.genres,
                metadata: movie.metadata,
                description: movie.description,
                buttonOverrideText: buttonOverrideText,
                ratingCount: movie.ratingCount,
                durationText: (movie.time ?? '').isEmpty ? null : movie.time,
                qualityText: context.i18n.movie.details.quality1080p,
                viewsText: (movie.view == null) ? null : movie.viewsString,
                onActionPressed: () async {
                  if (shouldWatchNow) {
                    if (context.mounted) {
                      final videoUrl = _getVideoUrl(movie);
                      context.push(
                        '${AppRouter.videoPlayer}/${movie.id}',
                        extra: {
                          'movie': movie,
                          'videoUrl': videoUrl,
                        },
                      );
                    }
                    return;
                  }

                  // If not accessible and not subscribed, go to subscription
                  if (!isSubscribed) {
                    context.push(AppRouter.subscription);
                  }
                },
                onViewMorePressed: () {
                  context.push(
                    '${AppRouter.movieInfo}/${movie.id}',
                    extra: {'movie': movie},
                  );
                },
              ),
              Gap(32),
              MovieRatingSection(
                movieId: movie.id,
                rating: movie.rating ?? 0.0,
                reviewCount: movie.ratingCount ?? 0,
                canRate: shouldWatchNow,
                onViewAllPressed: () {
                  context.push('${AppRouter.ratings}/${movie.id}', extra: {'title': movie.title});
                },
              ),
              if (movie.franchiseId != null) ...[
                Gap(32),
                _buildSeriesSection(context, movie.franchiseId!, movie.franchiseName ?? 'Series'),
              ],
              Gap(32),
              _buildSimilarSection(context, widget.movieId),
              Gap(24),
            ]),
          ),
        ),
      ],
    );
  }


  Widget _buildSeriesSection(BuildContext context, String franchiseId, String seriesTitle) {
    final seriesAsync = ref.watch(seriesMoviesProvider(franchiseId));

    return seriesAsync.when(
      data: (seriesMovies) {
        if (seriesMovies.isEmpty) return const SizedBox.shrink();

        return MovieSeriesSection(
          seriesTitle: seriesTitle,
          seriesMovies: seriesMovies,
          onViewAllPressed: () {
            // TODO: Navigate to series page
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSimilarSection(BuildContext context, String movieId) {
    final similarAsync = ref.watch(similarMoviesProvider(movieId));

    return similarAsync.when(
      data: (similarMovies) {
        if (similarMovies.isEmpty) return const SizedBox.shrink();
        
        return MovieSimilarSection(
          similarMovies: similarMovies,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Color textColor, Movie? movie) {
    final isInWishlistAsync = movie != null 
        ? ref.watch(isInWishlistProvider(movie.id))
        : null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              ImageConstant.sendIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          onPressed: () {
            // TODO: Implement share
          },
        ),
        if (movie != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: isInWishlistAsync?.when(
                data: (isInWishlist) => Icon(
                  isInWishlist ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                  size: 20,
                ),
                loading: () => const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                error: (_, __) => const Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                  size: 20,
                ),
              ) ?? const Icon(
                Icons.bookmark_border,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () async {
                    try {
                      final userId = ref.read(currentUserIdProvider);
                      if (userId == null) return;
                      
                      final repo = ref.read(wishlistRepositoryProvider);
                      final isInWishlist = isInWishlistAsync?.value ?? false;

                      if (isInWishlist) {
                        await repo.removeFromWatchlist(userId, movie.id);
                      } else {
                        await repo.addToWatchlist(userId, movie.id);
                      }

                      // Invalidate to refresh UI and list
                      ref.invalidate(isInWishlistProvider(movie.id));
                      ref.invalidate(wishlistProvider);

                      if (context.mounted) {
                        ToastNotification.showSuccess(
                          context,
                          message: isInWishlist
                              ? 'Removed from wishlist'
                              : 'Added to wishlist',
                          duration: const Duration(seconds: 2),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ToastNotification.showError(
                          context,
                          message: 'Error: ${e.toString()}',
                          duration: const Duration(seconds: 2),
                        );
                      }
                    }
                  },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context, String imageUrl) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      child: NetworkOrAssetImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  String? _getVideoUrl(Movie movie) {
    // Prefer direct stream in trailer only if it's a real media URL (not YouTube)
    if (movie.trailerUrl != null && movie.trailerUrl!.isNotEmpty) {
      final t = movie.trailerUrl!;
      final isDirectStream = t.contains('.m3u8') || t.contains('.mp4');
      final isYouTube = t.contains('youtube.com') || t.contains('youtu.be');
      if (isDirectStream && !isYouTube) {
        return t;
      }
    }
    
    if (movie.episodes != null && movie.episodes!.isNotEmpty) {
      // Try to get first episode's video URL
      final firstEpisode = movie.episodes!.first;
      
      // Check if it's a server structure (has server_data)
      if (firstEpisode['server_data'] != null && firstEpisode['server_data'] is List) {
        final serverData = firstEpisode['server_data'] as List;
        if (serverData.isNotEmpty) {
          final firstVideo = serverData.first;
          if (firstVideo['link_m3u8'] != null &&
              (firstVideo['link_m3u8'].toString().contains('.m3u8') ||
               firstVideo['link_m3u8'].toString().contains('.mp4'))) {
            return firstVideo['link_m3u8'].toString();
          }
          if (firstVideo['link_embed'] != null) {
            return firstVideo['link_embed'].toString();
          }
        }
      }
      
      // Direct episode structure
      if (firstEpisode['url'] != null) {
        return firstEpisode['url'].toString();
      }
      if (firstEpisode['videoUrl'] != null) {
        return firstEpisode['videoUrl'].toString();
      }
      if (firstEpisode['link_m3u8'] != null) {
        return firstEpisode['link_m3u8'].toString();
      }
      if (firstEpisode['link_embed'] != null) {
        return firstEpisode['link_embed'].toString();
      }
    }
    
    return null;
  }
}
