import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_export.dart';
import '../../../../core/constants/app_padding.dart';
import '../../../../routes/app_router.dart';
import '../../../../features/search/application/search_state_notifier.dart';
import '../../../../core/widgets/lists/movie_carousel.dart';
import '../../data/repositories/discover_repository.dart';
import '../../domain/enums/discover_section_type.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: context.responsivePadding(
            horizontalPercent: AppPadding.contentHorizontalPercent,
            topPercent: 0,
            bottomPercent: AppPadding.contentVerticalPercent,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _DiscoverSection(
                sectionType: DiscoverSectionType.topCharts,
              ),
              const Gap(24),
              _DiscoverSection(
                sectionType: DiscoverSectionType.topSelling,
              ),
              const Gap(24),
              _DiscoverSection(
                sectionType: DiscoverSectionType.topFree,
              ),
              const Gap(24),
              _DiscoverSection(
                sectionType: DiscoverSectionType.topNewReleases,
              ),
              const Gap(24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _DiscoverSection extends ConsumerWidget {
  const _DiscoverSection({
    required this.sectionType,
  });

  final DiscoverSectionType sectionType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionAsync = ref.watch(discoverSectionProvider(sectionType));

    return sectionAsync.when(
      data: (items) => MovieCarousel(
        title: sectionType.title,
        items: items,
        onMore: () => _handleMoreTap(context, ref, sectionType),
      ),
      loading: () => _LoadingSection(title: sectionType.title),
      error: (error, stack) => _ErrorSection(
        title: sectionType.title,
        error: error.toString(),
        onRetry: () {
          ref.invalidate(discoverSectionProvider(sectionType));
        },
      ),
    );
  }

  void _handleMoreTap(
    BuildContext context,
    WidgetRef ref,
    DiscoverSectionType sectionType,
  ) {
    final filters = sectionType.filters;
    // Không set query text vào search bar, chỉ dùng filters
    final emptyQuery = '';

    ref.read(searchStateProvider.notifier).searchWithFilters(emptyQuery, filters);

    context.push(AppRouter.search);
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 24,
              color: AppColors.primary500,
            ),
          ],
        ),
        const Gap(16),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 24,
              color: AppColors.primary500,
            ),
          ],
        ),
        const Gap(16),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(
                  '${context.i18n.common.errorPrefix} $error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                      ),
                ),
                const Gap(16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text(context.i18n.common.retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
