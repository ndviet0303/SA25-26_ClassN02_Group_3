import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/auto_layout.dart';
import 'package:movie_fe/core/widgets/price_range_slider.dart';
import 'package:movie_fe/core/widgets/selection/app_checkbox.dart';
import 'package:movie_fe/features/search/application/filter_section_notifier.dart';
import 'package:movie_fe/features/search/application/filter_page_notifier.dart';
import 'package:movie_fe/features/search/entities/filter_section.dart';
import 'package:movie_fe/features/search/entities/search_filter.dart';
import 'package:movie_fe/features/search/application/search_state_notifier.dart';

class SearchFilterPage extends ConsumerStatefulWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onFiltersChanged;

  const SearchFilterPage({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<SearchFilterPage> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends ConsumerState<SearchFilterPage> {

  // key mỗi layout
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _priceKey = GlobalKey();
  final GlobalKey _ratingKey = GlobalKey();
  final GlobalKey _genreKey = GlobalKey();
  final GlobalKey _languageKey = GlobalKey();
  final GlobalKey _ageKey = GlobalKey();

  GlobalKey _keyFor(FilterSection section) {
    switch (section) {
      case FilterSection.sort:
        return _sortKey;
      case FilterSection.price:
        return _priceKey;
      case FilterSection.rating:
        return _ratingKey;
      case FilterSection.genre:
        return _genreKey;
      case FilterSection.language:
        return _languageKey;
      case FilterSection.age:
        return _ageKey;
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(filterPageNotifierProvider.notifier)
          .initializeFromFilters(ref.read(searchStateProvider).filters);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedSection = ref.watch(filterSectionNotifierProvider);
    final filterSectionNotifier = ref.read(filterSectionNotifierProvider.notifier);

    final filterPageState = ref.watch(filterPageNotifierProvider);
    final filterPageNotifier = ref.read(filterPageNotifierProvider.notifier);

    final minPrice = double.parse(context.i18n.search.filter.rangePrice.min);
    final maxPrice = double.parse(context.i18n.search.filter.rangePrice.max);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [

                  // header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          filterSectionNotifier.clearSelection();
                          context.pop();
                        },
                        icon: SvgPicture.asset(
                          ImageConstant.closeIcon,
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            AppColors.getText(context),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),

                      Text(
                        context.i18n.search.filter.header,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getText(context),
                        ),
                      ),
                    ],
                  ),

                  // filter type
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: FilterSection.values.map((section) {
                        final isSelected = selectedSection == section;
                        return Tag(
                          text: section.label(context),
                          isSelected: isSelected,
                          onTap: () {
                            filterSectionNotifier.selectSection(section);

                            // scroll tới
                            final ctx = _keyFor(section).currentContext;
                            if (ctx != null) {
                              Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut, alignment: 0.0);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),


                ],
              ),
            ),

            // filter content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16,),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 16,
                    children: [

                      // Sort section
                      AutoLayout(
                        key: _sortKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.i18n.search.filter.sections.sort,
                              style: AppTypography.h5.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.getText(context),
                              ),
                            ),

                            Divider(color: AppColors.getLine(context)),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: SortOption.values.length,
                              itemBuilder: (context, index) {
                                final option = SortOption.values[index];
                                final isSelected = filterPageState.selectedSort == option;
                                return RadioBox(
                                  value: option.name,
                                  title: option.label(context),
                                  isSelected: isSelected,
                                  fontSize: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0,),
                                  iconSpacing: 16,
                                  onTap: () => filterPageNotifier.updateSort(option),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                color: AppColors.getLine(context),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Price section
                      AutoLayout(
                        key: _priceKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.i18n.search.filter.sections.price,
                              style: AppTypography.h5.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.getText(context),
                              ),
                            ),

                            Divider(color: AppColors.getLine(context)),

                            const SizedBox(height: 36),

                            Column(
                              children: [
                                PriceRangeSlider(
                                  values: RangeValues(
                                      filterPageState.tempFilters.priceMin?.toDouble() ?? minPrice,
                                      filterPageState.tempFilters.priceMax?.toDouble() ?? maxPrice
                                  ),
                                  min: minPrice,
                                  max: maxPrice,
                                  divisions: context.i18n.locale == 'vi' ? 25000 : 1,
                                  onChanged: (RangeValues values) {
                                    filterPageNotifier.updatePriceRange(values.start, values.end,);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Rating section
                      AutoLayout(
                        key: _ratingKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.i18n.search.filter.sections.rating,
                              style: AppTypography.h5.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.getText(context),
                              ),
                            ),

                            Divider(color: AppColors.getLine(context)),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: RatingOption.values.length,
                              itemBuilder: (context, index) {
                                final rating = RatingOption.values[index];
                                var isSelected = filterPageState.selectedRating == rating;
                                return RadioBox(
                                  title: rating.label(context),
                                  value: rating.name,
                                  isSelected: isSelected,
                                  fontSize: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  iconSpacing: 16,
                                  onTap: () => filterPageNotifier.updateRating(rating),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                color: AppColors.getLine(context),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Genre section
                      AutoLayout(
                        key: _genreKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.i18n.search.filter.sections.genre,
                              style: AppTypography.h5.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.getText(context),
                              ),
                            ),

                            Divider(color: AppColors.getLine(context)),

                            const SizedBox(height: 8),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: GenreOption.values.length,
                              itemBuilder: (context, index) {
                                final genre = GenreOption.values[index];
                                final isSelected = filterPageState.tempFilters.genres.contains(
                                  genre.name,
                                );
                                return AppCheckbox(
                                  value: isSelected,
                                  label: genre.label(context),
                                  spacing: 16,
                                  onChanged: (value) {
                                    final currentGenres = List<String>.from( // list genres chọn
                                      filterPageState.tempFilters.genres,
                                    );
                                    if (value) {
                                      currentGenres.add(genre.name);
                                    } else {
                                      currentGenres.remove(genre.name);
                                    }
                                    filterPageNotifier.updateGenres(currentGenres);
                                  },
                                  textStyle: AppTypography.bodyLBold.copyWith(
                                    color: AppColors.getText(context),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: AppColors.getLine(context),
                                    height: 1,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Language option section
                      AutoLayout(
                        key: _languageKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.i18n.search.filter.sections.language,
                              style: AppTypography.h5.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.getText(context),
                              ),
                            ),

                            Divider(color: AppColors.getLine(context)),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: LanguageOption.values.length,
                              itemBuilder: (context, index) {
                                final language = LanguageOption.values[index];
                                var isSelected = filterPageState.selectedLanguage == language;
                                return RadioBox(
                                  title: language.label(context),
                                  value: language.name,
                                  isSelected: isSelected,
                                  fontSize: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  iconSpacing: 16,
                                  onTap: () => filterPageNotifier.updateLanguage(language),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                color: AppColors.getLine(context),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Age section
                      AutoLayout(
                        key: _ageKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.i18n.search.filter.sections.age,
                              style: AppTypography.h5.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.getText(context),
                              ),
                            ),

                            Divider(color: AppColors.getLine(context)),

                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: AgeOption.values.length,
                              itemBuilder: (context, index) {
                                final age = AgeOption.values[index];
                                var isSelected = filterPageState.selectedAge == age;
                                return RadioBox(
                                  title: age.label(context),
                                  value: age.name,
                                  isSelected: isSelected,
                                  fontSize: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  iconSpacing: 16,
                                  onTap: () => filterPageNotifier.updateAge(age),
                                );
                              },
                              separatorBuilder: (context, index) => Divider(
                                color: AppColors.getLine(context),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [

                  Expanded(
                    child: SecondaryButton(
                      text: context.i18n.search.filter.reset,
                      onPressed: () {
                        filterPageNotifier.reset();
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: PrimaryButton(
                      text: context.i18n.search.filter.apply,
                      onPressed: () {
                        ref.read(searchStateProvider.notifier).updateFilters(filterPageState.tempFilters);
                        widget.onFiltersChanged(filterPageState.tempFilters);
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
