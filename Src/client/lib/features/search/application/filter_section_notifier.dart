import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/filter_section.dart';

final filterSectionNotifierProvider = StateNotifierProvider<FilterSectionNotifier, FilterSection?>((ref) {
  return FilterSectionNotifier();
});

class FilterSectionNotifier extends StateNotifier<FilterSection?> {
  FilterSectionNotifier() : super(null);

  void selectSection(FilterSection section) {
    if (state == section) {
      state = null;
    } else {
      state = section;
    }
  }

  void clearSelection() {
    state = null;
  }

  bool isSelected(FilterSection section) {
    return state == section;
  }
}

