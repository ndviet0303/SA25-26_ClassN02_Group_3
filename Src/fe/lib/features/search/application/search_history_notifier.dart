import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


final searchHistoryProvider =
  StateNotifierProvider<SearchHistoryNotifier, List<String>>(
      (ref) => SearchHistoryNotifier()..load(),
);

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]);

  static const _prefKey = 'search_history.dart';
  static const _maxItem = 20;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    state = sp.getStringList(_prefKey) ?? const [];
  }

  Future<void> _save(List<String> next) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_prefKey, next);
  }

  Future<void> add(String query) async {
    if (query.trim().isEmpty) return;

    final next = [query, ...state.where((e) => e != query)].take(_maxItem).toList();

    state = next;
    await _save(next);
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= state.length) return;
    final next = [...state]..removeAt(index);
    state = next;
    await _save(next);
  }

  Future<void> clear() async {
    state = [];
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_prefKey);
  }

}
