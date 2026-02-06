import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/enums/movie_type.dart';
import 'package:movie_fe/core/models/movie_item.dart';
import 'package:movie_fe/core/widgets/cards/movie_card.dart';
import 'package:movie_fe/core/widgets/lists/movie_carousel.dart';
import 'package:movie_fe/routes/app_router.dart';
import 'package:movie_fe/features/home/data/home_providers.dart';
import 'package:movie_fe/core/utils/data/genres.dart';
import 'package:movie_fe/core/utils/data/countries.dart';
import 'package:movie_fe/core/repositories/movie_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ContentWrappers.page(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            title: '',
            provider: trendingMoviesProvider,
            onMore: () {},
          ),
          _Section(
            title: context.i18n.home.sections.recommendedForYou,
            provider: recommendedMoviesProvider,
            onMore: () => context.push('${AppRouter.movieType}/recommended'),
          ),
          const Gap(16),
          const _ExploreByGenreSection(),
          const Gap(16),
          const _ExploreByCountrySection(),
          const Gap(16),
          const _ExploreByYearSection(),

          _Section(
            title: context.i18n.home.sections.yourWishlist,
            provider: wishlistMoviesProvider,
            onMore: () => context.push('${AppRouter.movieType}/wishlist'),
            minimal: false,
          ),
          _Section(
            title: context.i18n.home.sections.recentlyWatched,
            provider: recentMoviesProvider,
            onMore: () => context.push('${AppRouter.movieType}/recent'),
          ),
        ],
      ),
    );
  }
}

class _Section extends ConsumerWidget {
  const _Section({
    required this.title,
    required this.provider,
    this.onMore,
    this.minimal = false,
  });

  final String title;
  final AutoDisposeStreamProvider<List<MovieItem>> provider;
  final VoidCallback? onMore;
  final bool minimal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);
    return async.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        if (title.isEmpty) {
          return _AutoSlideMovies(items: items);
        }
        return MovieCarousel(
          title: title,
          items: items,
          onMore: onMore ?? () {},
          movieCarouselType: minimal ? MovieCarouselType.minimal : MovieCarouselType.normal,
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: const LoadingCustom(assetName: ImageConstant.loadingIcon, size: 40),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AutoSlideMovies extends StatefulWidget {
  const _AutoSlideMovies({required this.items});
  final List<MovieItem> items;

  @override
  State<_AutoSlideMovies> createState() => _AutoSlideMoviesState();
}

class _AutoSlideMoviesState extends State<_AutoSlideMovies> {
  final PageController _controller = PageController(viewportFraction: 0.8);
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _start() {
    _timer?.cancel();
    if (widget.items.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      _index = (_index + 1) % widget.items.length;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.8;
    final aspect = 160 / 80; // title-in-image card aspect
    final posterHeight = cardWidth / aspect;
    final totalHeight = posterHeight; // no extra metadata below to avoid overflow

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: totalHeight,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.items.length,
            itemBuilder: (context, i) {
              final m = widget.items[i];
              final compact = MovieItem(id: m.id, title: m.title, imageUrl: m.imageUrl);
              final currentPage = _controller.hasClients ? (_controller.page ?? _index.toDouble()) : _index.toDouble();
              final delta = (i - currentPage).abs().clamp(0.0, 1.0);
              final scale = 0.9 + (0.2 * (1 - delta));
              final dimOpacity = 0.4 * delta; // center bright, sides darker
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      MovieCard(
                        movie: compact,
                        width: cardWidth,
                        height: posterHeight,
                        movieCardType: MovieCardType.titleInImg,
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(color: Colors.black.withOpacity(dimOpacity)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(8),
      ],
    );
  }
}

class _ExploreByGenreSection extends ConsumerWidget {
  const _ExploreByGenreSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genresProvider);
    
    return genresAsync.when(
      data: (apiGenres) {
        if (apiGenres.isEmpty) return const SizedBox.shrink();
        
        final theme = Theme.of(context);
        final localGenres = GenresVi.all;
        
        // Show first 6 genres on home or based on some logic
        final displayGenres = apiGenres.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.i18n.home.sections.exploreByGenre,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary500),
                  onPressed: () => context.push('${AppRouter.explore}/genre'),
                ),
              ],
            ),
            const Gap(10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 24),
                itemCount: displayGenres.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  final g = displayGenres[index];
                  final name = g['name'] ?? '';
                  final slug = g['slug'] ?? name;
                  
                  // Find image from local list
                  final localMatch = localGenres.firstWhere(
                    (lg) => lg['slug'] == slug || lg['name']?.toLowerCase() == name.toLowerCase(),
                    orElse: () => {},
                  );
                  
                  final img = localMatch['imageUrl'] ?? ImageConstant.imgCard;
                  
                  final m = MovieItem(
                    id: slug,
                    title: name,
                    imageUrl: img,
                  );
                  return MovieCard(
                    movie: m,
                    width: 160,
                    height: 80,
                    movieCardType: MovieCardType.titleInImg,
                    enableNavigation: false,
                    onMore: () => context.push('${AppRouter.movieCarouselGenre}$slug'),
                    titleFontSize: 16,
                    overlayOpacity: 0.18,
                  );
                },
              ),
            ),
            const Gap(10),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ExploreByCountrySection extends ConsumerWidget {
  const _ExploreByCountrySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);
    
    return countriesAsync.when(
      data: (apiCountries) {
        if (apiCountries.isEmpty) return const SizedBox.shrink();
        
        final theme = Theme.of(context);
        final localCountries = CountriesVi.all;
        
        // Show first 6 countries on home
        final displayCountries = apiCountries.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.i18n.home.sections.exploreByCountry,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary500),
                  onPressed: () => context.push('${AppRouter.explore}/country'),
                ),
              ],
            ),
            const Gap(10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 24),
                itemCount: displayCountries.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  final c = displayCountries[index];
                  final name = c['name'] ?? '';
                  final slug = c['slug'] ?? name;
                  
                  // Find image from local list
                  final localMatch = localCountries.firstWhere(
                    (lc) => lc['slug'] == slug || lc['name']?.toLowerCase() == name.toLowerCase(),
                    orElse: () => {},
                  );
                  
                  final img = localMatch['imageUrl'] ?? ImageConstant.imgCard;
                  
                  final m = MovieItem(
                    id: slug,
                    title: name,
                    imageUrl: img,
                  );
                  return MovieCard(
                    movie: m,
                    width: 160,
                    height: 80,
                    movieCardType: MovieCardType.titleInImg,
                    enableNavigation: false,
                    onMore: () => context.push('${AppRouter.movieCarouselCountry}$slug'),
                    titleFontSize: 16,
                    overlayOpacity: 0.18,
                  );
                },
              ),
            ),
            const Gap(10),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ExploreByYearSection extends ConsumerWidget {
  const _ExploreByYearSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(yearsProvider);
    
    return yearsAsync.when(
      data: (apiYears) {
        if (apiYears.isEmpty) return const SizedBox.shrink();
        
        final theme = Theme.of(context);
        
        // Show first 8 years on home
        final displayYears = apiYears.take(8).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.i18n.home.sections.exploreByYear,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary500),
                  onPressed: () => context.push('${AppRouter.explore}/year'),
                ),
              ],
            ),
            const Gap(10),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 24),
                itemCount: displayYears.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (context, index) {
                  final year = displayYears[index];
                  return GestureDetector(
                    onTap: () => context.push('${AppRouter.movieCarouselYear}$year'),
                    child: Container(
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary500, AppColors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        year.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(10),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

