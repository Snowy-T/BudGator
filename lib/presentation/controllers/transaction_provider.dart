import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      (ref) => TransactionNotifier(),
    );

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  int _nextId = 1;

  TransactionNotifier()
    : super([]); // Startet mit leerer Liste, keine Sample-Daten

  void add(TransactionModel t) {
    final newTransaction = TransactionModel(
      id: _nextId,
      title: t.title,
      amount: t.amount,
      date: t.date,
      category: t.category,
      type: t.type,
    );
    _nextId++;
    state = [newTransaction, ...state];
  }

  void remove(int id) {
    state = state.where((e) => e.id != id).toList();
  }

  void update(TransactionModel updated) {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
  }
}
