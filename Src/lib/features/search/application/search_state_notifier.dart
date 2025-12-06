import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/search_result.dart';
import '../entities/search_filter.dart';
import '../repositories/search_repository.dart';
import '../presentation/screens/search_screen.dart';

final searchStateProvider = StateNotifierProvider<SearchStateNotifier, SearchState>(
      (ref) => SearchStateNotifier(ref),
);

enum SearchStatus { idle, loading, success, error }

enum ShowInMode { category, document }

class SearchState {
  final String query;
  final bool isSearching;
  final bool hasSubmitted;
  final bool hasResults;
  final List<SearchResult> results;
  final String? error;
  final SearchStatus status;
  final SearchFilters filters;
  final int currentPage;
  final bool hasMoreResults;
  final bool isLoadingMore;
  final List<String> suggestions;
  final ShowInMode showInMode;
  final SearchSource searchSource;

  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.hasSubmitted = false,
    this.hasResults = false,
    this.results = const [],
    this.error,
    this.status = SearchStatus.idle,
    this.filters = const SearchFilters(),
    this.currentPage = 1,
    this.hasMoreResults = false,
    this.isLoadingMore = false,
    this.suggestions = const [],
    this.showInMode = ShowInMode.category,
    this.searchSource = SearchSource.all,
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    bool? hasSubmitted,
    bool? hasResults,
    List<SearchResult>? results,
    String? error,
    SearchStatus? status,
    SearchFilters? filters,
    int? currentPage,
    bool? hasMoreResults,
    bool? isLoadingMore,
    List<String>? suggestions,
    ShowInMode? showInMode,
    SearchSource? searchSource,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      hasResults: hasResults ?? this.hasResults,
      results: results ?? this.results,
      error: error ?? this.error,
      status: status ?? this.status,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      suggestions: suggestions ?? this.suggestions,
      showInMode: showInMode ?? this.showInMode,
      searchSource: searchSource ?? this.searchSource,
    );
  }
}

class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier(this._ref) : super(const SearchState());
  
  final Ref _ref;
  Timer? _debounceTimer;
  
  SearchRepository get _repository => _ref.read(searchRepositoryProvider);

  void updateQuery(String query) {
    _debounceTimer?.cancel();
    
    state = state.copyWith(
      query: query,
      isSearching: query.isNotEmpty,
      hasResults: false,
      error: null,
    );

    if (query.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _fetchSuggestions(query);
      });
    } else {
      state = state.copyWith(suggestions: []);
    }
  }

  Future<void> performSearch(String query) async {
    state = state.copyWith(
      query: query,
      isSearching: true,
      hasSubmitted: true,
      status: SearchStatus.loading,
      error: null,
      currentPage: 1,
      results: [],
    );
    
    try {
      // Lấy wishlist hoặc purchase IDs tùy theo searchSource
      List<String>? wishlistMovieIds;
      if (state.searchSource == SearchSource.wishlist) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          state = state.copyWith(
            isSearching: false,
            status: SearchStatus.success,
            results: [],
            hasResults: false,
            hasMoreResults: false,
          );
          return;
        }
        
        final wishlistSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .get();
        
        wishlistMovieIds = wishlistSnapshot.docs.map((doc) => doc.id).toList();
        
        if (wishlistMovieIds.isEmpty) {
          state = state.copyWith(
            isSearching: false,
            status: SearchStatus.success,
            results: [],
            hasResults: false,
            hasMoreResults: false,
          );
          return;
        }
      } else if (state.searchSource == SearchSource.purchase) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          state = state.copyWith(
            isSearching: false,
            status: SearchStatus.success,
            results: [],
            hasResults: false,
            hasMoreResults: false,
          );
          return;
        }
        
        final purchaseSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('purchases')
            .get();
        
        wishlistMovieIds = purchaseSnapshot.docs.map((doc) => doc.id).toList();
        
        if (wishlistMovieIds.isEmpty) {
          state = state.copyWith(
            isSearching: false,
            status: SearchStatus.success,
            results: [],
            hasResults: false,
            hasMoreResults: false,
          );
          return;
        }
      }
      
      final results = await _repository.search(
        query, 
        filters: state.filters, 
        page: 1,
        wishlistMovieIds: wishlistMovieIds,
      );
      state = state.copyWith(
        results: results.items,
        hasResults: results.items.isNotEmpty,
        isSearching: false,
        status: SearchStatus.success,
        hasMoreResults: results.hasNext,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        status: SearchStatus.error,
        error: e.toString(),
      );
    }
  }

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    performSearch(state.query);
  }

  Future<void> searchWithFilters(String query, SearchFilters filters) async {
    state = state.copyWith(
      query: query,
      filters: filters,
      isSearching: false,
      hasSubmitted: true,
    );
    await performSearch(query);
  }


  Future<void> loadMoreResults() async {
    if (!state.hasMoreResults || state.isLoadingMore) return;
    
    state = state.copyWith(isLoadingMore: true);
    
    try {
      // Lấy wishlist hoặc purchase IDs tùy theo searchSource
      List<String>? wishlistMovieIds;
      if (state.searchSource == SearchSource.wishlist) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final wishlistSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('wishlist')
              .get();
          
          wishlistMovieIds = wishlistSnapshot.docs.map((doc) => doc.id).toList();
        }
      } else if (state.searchSource == SearchSource.purchase) {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final purchaseSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('purchases')
              .get();
          
          wishlistMovieIds = purchaseSnapshot.docs.map((doc) => doc.id).toList();
        }
      }
      
      final results = await _repository.search(
        state.query, 
        filters: state.filters, 
        page: state.currentPage + 1,
        wishlistMovieIds: wishlistMovieIds,
      );
      
      state = state.copyWith(
        results: [...state.results, ...results.items],
        currentPage: state.currentPage + 1,
        hasMoreResults: results.hasNext,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void setSearchSource(SearchSource source) {
    state = state.copyWith(searchSource: source);
  }


  void toggleShowInMode() {
    final newMode = state.showInMode == ShowInMode.category 
        ? ShowInMode.document 
        : ShowInMode.category;
    state = state.copyWith(showInMode: newMode);
  }

  void setShowInMode(ShowInMode mode) {
    state = state.copyWith(showInMode: mode);
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final suggestions = await _repository.getSuggestions(query);
      state = state.copyWith(suggestions: suggestions);
    } catch (e) {
      state = state.copyWith(suggestions: []);
    }
  }


  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  void setResults() {
    state = state.copyWith(
      hasResults: true,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
