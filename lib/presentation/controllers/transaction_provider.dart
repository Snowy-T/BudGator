import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_local_storage.dart';
import '../../data/models/transaction_model.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      (ref) => TransactionNotifier(ref.read(localStorageProvider)),
    );

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier(this._storage) : super([]) {
    _loadFromStorage();
  }

  final AppLocalStorage _storage;
  int _nextId = 1;

  void _loadFromStorage() {
    final loaded = _storage.loadTransactions();
    if (loaded.isEmpty) return;

    state = loaded;
    _nextId =
        loaded
            .map((e) => e.id ?? 0)
            .fold<int>(0, (maxId, id) => id > maxId ? id : maxId) +
        1;
  }

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
    unawaited(_storage.saveTransactions(state));
  }

  void remove(int id) {
    state = state.where((e) => e.id != id).toList();
    unawaited(_storage.saveTransactions(state));
  }

  void update(TransactionModel updated) {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
    unawaited(_storage.saveTransactions(state));
  }
}
