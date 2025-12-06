import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/features/search/application/search_state_notifier.dart';
import 'package:movie_fe/features/search/presentation/widgets/search_filter_page.dart';

import '../../application/search_history_notifier.dart';

class SearchHeader extends ConsumerStatefulWidget {
  const SearchHeader({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SearchHeaderState();
  }
}

class _SearchHeaderState extends ConsumerState<SearchHeader>{

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);

    return Row(
      children: [
        // back
        GestureDetector(
          onTap: () {
            context.pop();

            // reset state nếu có result
            final currentState = ref.read(searchStateProvider);
            if (currentState.hasResults || currentState.hasSubmitted) {
              Future.delayed(const Duration(milliseconds: 300), () {
                ref.read(searchStateProvider.notifier).clear();
              });
            }
          },
          child: SvgPicture.asset(
            ImageConstant.arrowIcon,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              AppColors.getText(context),
              BlendMode.srcIn,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: InfoField(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            controller: widget.searchController,
            focusNode: widget.searchFocusNode,
            showDivider: false,
            showBorder: true,
            borderRadius: 16,

            fontSize: 16,
            cursorHeight: 13,
            // cursor text ngắn hơn
            cursorColor: AppColors.getText(context),
            prefixIcon: Transform.scale(
              scale: 0.35,
              child: SvgPicture.asset(
                ImageConstant.searchIcon,
                colorFilter: ColorFilter.mode(
                  AppColors.getText(context),
                  BlendMode.srcIn, // vẽ svg
                ),
              ),
            ),
            suffixIcon: (searchState.query.isNotEmpty || searchState.hasSubmitted)
                ? GestureDetector(
              onTap: searchState.hasResults
                  ? _showFilterOptions
                  : _clearSearch,
              child: Transform.scale(
                scale: searchState.hasResults ? 0.35 : 0.25,
                child: SvgPicture.asset(
                  searchState.hasResults
                      ? ImageConstant.filterIcon
                      : ImageConstant.closeIcon,
                  colorFilter: ColorFilter.mode(
                    searchState.hasResults
                        ? AppColors.primary500
                        : AppColors.getText(context),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            )
                : null,

            onSubmitted: (value) {
              _handleSubmit(value);
            },

            backgroundColor: searchState.hasSubmitted
                ? AppColors.getSurface(context)
                : AppColors.trOrange,
            focusedBackgroundColor: AppColors.trOrange,
            borderColor: searchState.hasSubmitted ? null : AppColors.primary500,
          ),
        ),

        // GestureDetector(
        //   onTap: () => context.pop(),
        //   child: SvgPicture.asset(
        //     ImageConstant
        //   )
        // )
      ],
    );
  }

  void _handleSubmit(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).add(query);
    }
    ref.read(searchStateProvider.notifier).performSearch(query);
    widget.searchFocusNode.unfocus();
  }

  void _clearSearch() {
    widget.searchController.clear();
    ref.read(searchStateProvider.notifier).clear();
    widget.searchFocusNode.unfocus();
  }

  void _showFilterOptions() {
    final currentFilters = ref.read(searchStateProvider).filters;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SearchFilterPage(
          currentFilters: currentFilters,
          onFiltersChanged: (newFilters) {
            ref.read(searchStateProvider.notifier).updateFilters(newFilters);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    );
  }


}