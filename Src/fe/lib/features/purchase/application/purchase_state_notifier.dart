import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_item.dart';
import '../data/repositories/purchase_repository.dart';

final purchaseStateProvider =
    StateNotifierProvider<PurchaseStateNotifier, PurchaseState>(
  (ref) => PurchaseStateNotifier(ref),
);

class PurchaseState {
  final Map<String, bool> downloadStatus;
  final Set<String> finishedIds;

  const PurchaseState({
    this.downloadStatus = const {},
    this.finishedIds = const {},
  });

  PurchaseState copyWith({
    Map<String, bool>? downloadStatus,
    Set<String>? finishedIds,
  }) {
    return PurchaseState(
      downloadStatus: downloadStatus ?? this.downloadStatus,
      finishedIds: finishedIds ?? this.finishedIds,
    );
  }
}

class PurchaseStateNotifier extends StateNotifier<PurchaseState> {
  PurchaseStateNotifier(this._ref) : super(const PurchaseState()) {
    _ref.listen(purchaseProvider, (previous, next) {
      next.whenData((items) {
        final downloadStatus = Map<String, bool>.from(state.downloadStatus);
        for (var item in items) {
          if (!downloadStatus.containsKey(item.id)) {
            downloadStatus[item.id] = true;
          }
        }
        state = state.copyWith(downloadStatus: downloadStatus);
      });
    });
  }

  final Ref _ref;

  void removeDownload(String id) {
    state = state.copyWith(
      downloadStatus: {...state.downloadStatus, id: false},
    );
  }

  void markAsFinished(String id) {
    state = state.copyWith(
      finishedIds: {...state.finishedIds, id},
    );
  }
}

