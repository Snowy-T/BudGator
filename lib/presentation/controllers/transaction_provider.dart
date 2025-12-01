import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';

final transactionsProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
  (ref) => TransactionNotifier(),
);

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]);

  void add(TransactionModel t) {
    state = [t, ...state];
  }

  void remove(int id) {
    state = state.where((e) => e.id != id).toList();
  }
}
