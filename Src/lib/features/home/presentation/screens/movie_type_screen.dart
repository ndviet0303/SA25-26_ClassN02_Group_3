import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:movie_fe/core/widgets/cards/movie_card.dart';
import 'package:movie_fe/core/widgets/lists/list_title_movie.dart';
import '../../data/home_providers.dart';

enum MovieListType { recommended, purchase, wishlist, recent }
enum ViewMode { grid, list }
final viewModeProvider = StateProvider<ViewMode>((_) => ViewMode.grid);

class MovieTypeScreen extends ConsumerWidget {
  const MovieTypeScreen({super.key, required this.type});

  final MovieListType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textColor = AppColors.getText(context);

    final title = () {
      final t = context.i18n.home.sections;
      switch (type) {
        case MovieListType.recommended:
          return t.recommendedForYou;
        case MovieListType.purchase:
          return t.yourPurchases;
        case MovieListType.wishlist:
          return t.yourWishlist;
        case MovieListType.recent:
          return t.recentlyWatched;
      }
    }();

    final provider = () {
      switch (type) {
        case MovieListType.recommended:
          return recommendedMoviesProvider;
        case MovieListType.purchase:
          return purchasedMoviesProvider;
        case MovieListType.wishlist:
          return wishlistMoviesProvider;
        case MovieListType.recent:
          return recentMoviesProvider;
      }
    }();

    final async = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: async.when(
            data: (movies) {
              if (movies.isEmpty) {
                return Center(
                  child: Text(
                    context.i18n.common.empty,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.getTextSecondary(context)),
                  ),
                );
              }
              final mode = ref.watch(viewModeProvider);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.i18n.cards.showIn, style: theme.textTheme.headlineMedium),
                      Row(
                        children: [
                          _ModeButton(
                            asset: ImageConstant.categoryIcon,
                            isActive: mode == ViewMode.grid,
                            onTap: () {
                              ref.read(viewModeProvider.notifier).state = ViewMode.grid;
                            },
                          ),
                          const Gap(16),
                          _ModeButton(
                            asset: ImageConstant.listCategoryIcon,
                            isActive: mode == ViewMode.list,
                            onTap: () {
                              ref.read(viewModeProvider.notifier).state = ViewMode.list;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(24),
                  Expanded(
                    child: mode == ViewMode.grid
                        ? GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 180 / 350,
                            ),
                            itemCount: movies.length,
                            itemBuilder: (context, index) {
                              final movie = movies[index];
                              return MovieCard(movie: movie);
                            },
                          )
                        : ListTitleMovie(movies: movies),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.warning),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String asset;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.asset,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        asset,
        colorFilter: ColorFilter.mode(
          isActive ? AppColors.primary500 : AppColors.greyscale700,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}


