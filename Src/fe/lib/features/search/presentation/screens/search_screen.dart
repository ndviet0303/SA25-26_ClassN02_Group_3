import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_fe/core/app_export.dart';
import 'package:movie_fe/core/widgets/loading.dart';
import 'package:movie_fe/features/search/application/search_history_notifier.dart';
import 'package:movie_fe/features/search/application/search_state_notifier.dart';
import 'package:movie_fe/features/search/presentation/widgets/search_header.dart';
import 'package:movie_fe/features/search/presentation/widgets/search_history.dart';

import '../widgets/search_body.dart';

enum SearchSource {
  all,
  wishlist,
  purchase,
}

class SearchScreen extends ConsumerStatefulWidget {
  final SearchSource searchSource;
  
  const SearchScreen({
    super.key,
    this.searchSource = SearchSource.all,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set search source from widget
      ref.read(searchStateProvider.notifier).setSearchSource(widget.searchSource);
      
      final searchState = ref.read(searchStateProvider);
      if (searchState.query.isNotEmpty && _searchController.text != searchState.query) {
        _searchController.text = searchState.query;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchStateProvider.notifier).updateQuery(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);
    final searchState = ref.watch(searchStateProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.getBackground(context),
      body: ContentWrapper.standard(
        child: Column(
          children: [
            _buildSearchHeader(context, searchState),

            SizedBox(height: context.responsiveHeight(3.0)), // Responsive spacing

            Expanded(child: _buildSearchContent(context, searchState, history),),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, SearchState searchState,) {
    return SearchHeader(
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
    );
  }

  Widget _buildSearchContent(BuildContext context, SearchState searchState, List<String> history,) {
    switch (searchState.status) {
      case SearchStatus.idle:
        return SearchHistory(searchController: _searchController, searchFocusNode: _searchFocusNode,);
      case SearchStatus.loading:
        return _buildLoadingState(context);
      case SearchStatus.success:
        return SearchBody();
      case SearchStatus.error:
        return _buildErrorState(context, searchState.error);
    }
  }


  Widget _buildLoadingState(BuildContext context) {
    return LoadingCustom(
      // loading custom widget
      assetName: ImageConstant.loadingIcon,
      size: 60,
      color: AppColors.primary500,
    );
  }

  Widget _buildErrorState(BuildContext context, String? error) {
    return Center(
      child: Text(
        error ?? 'An unexpected error occurred. Please try again.',
        style: AppTypography.h5.copyWith(
          color: AppColors.getTextThird(context),
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
