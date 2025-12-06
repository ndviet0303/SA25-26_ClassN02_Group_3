import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/layout/lined_text_divider.dart';
import '../../application/search_history_notifier.dart';
import '../../application/search_state_notifier.dart';

class SearchHistory extends ConsumerStatefulWidget {
  const SearchHistory({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;


  @override
  ConsumerState<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends ConsumerState<SearchHistory> {


  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);
    final searchState = ref.watch(searchStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchState.suggestions.isNotEmpty) ...[
          Text(
            'Suggestions',
            style: AppTypography.h5.copyWith(
              color: AppColors.getText(context),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          _buildSuggestions(context, searchState.suggestions),

          const SizedBox(height: 24),
        ],

        // history
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.i18n.search.previousSearches,
              style: AppTypography.h5.copyWith(
                color: AppColors.getText(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(searchHistoryProvider.notifier).clear();
              },
              child: SvgPicture.asset(
                ImageConstant.closeIcon,
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(
                  AppColors.getTextSecondary(context),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        LinedTextDivider(),

        const SizedBox(height: 24),

        Flexible(
          child: _buildListPreviousSearches(context, history, searchState),
        ),
      ],
    );
  }


  Widget _buildSuggestions(BuildContext context, List<String> suggestions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions
          .map(
            (suggestion) => GestureDetector(
          onTap: () {
            widget.searchController.text = suggestion;
            _handleSubmit(suggestion);
          },
          child: Tag(
            text: suggestion,
            backgroundColor: AppColors.getSurface(context),
            textColor: AppColors.getText(context),
            borderColor: AppColors.getTextSecondary(
              context,
            ).withOpacity(0.2),
            borderWidth: 1,
            fontSize: 14,
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildListPreviousSearches(BuildContext context, List<String> history, SearchState searchState,) {
    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final oldSearch = history[index];
        return Row(
          children: [

            /**/
            Expanded( // chiếm hết chiều ngang
              child: GestureDetector(
                onTap: () {
                  widget.searchController.text = oldSearch;
                  _handleSubmit(oldSearch);
                },
                child: Text(
                  oldSearch,
                  style: AppTypography.h5.copyWith(
                    color: AppColors.getTextThird(context),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                ref.read(searchHistoryProvider.notifier).removeAt(index);
              },
              child: SvgPicture.asset(
                ImageConstant.closeIcon,
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(
                  AppColors.getTextSecondary(context),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).add(query);
      ref.read(searchStateProvider.notifier).performSearch(query);
      widget.searchFocusNode.unfocus();
    }
  }
}
