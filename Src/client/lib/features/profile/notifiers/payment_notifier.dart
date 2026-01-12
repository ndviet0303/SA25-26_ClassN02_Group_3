import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_method.dart';
import '../repository/settings_repository.dart';

class PaymentNotifier extends StateNotifier<AsyncValue<List<PaymentMethod>>> {
  PaymentNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      final methods = await _repository.fetchPaymentMethods();
      state = AsyncValue.data(methods);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> setDefault(String id) async {
    try {
      final updated = await _repository.setDefaultPayment(id);
      state = AsyncValue.data(updated);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, AsyncValue<List<PaymentMethod>>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return PaymentNotifier(repository);
});


