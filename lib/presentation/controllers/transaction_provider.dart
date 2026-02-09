import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>(
      (ref) => TransactionNotifier(),
    );

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier()
    : super([
        // Sample Daten für Demo
        TransactionModel(
          id: 1,
          title: 'Gehalt',
          amount: 2840,
          date: DateTime.now().subtract(const Duration(days: 15)),
          category: 'Salary',
          type: TransactionType.income,
        ),
        TransactionModel(
          id: 2,
          title: 'Miete',
          amount: 850,
          date: DateTime.now().subtract(const Duration(days: 10)),
          category: 'Wohnen',
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 3,
          title: 'Lebensmittel',
          amount: 120,
          date: DateTime.now().subtract(const Duration(days: 8)),
          category: 'Lebensmittel',
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 4,
          title: 'Freelance Projekt',
          amount: 500,
          date: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Salary',
          type: TransactionType.income,
        ),
        TransactionModel(
          id: 5,
          title: 'Supermarkt',
          amount: 85,
          date: DateTime.now().subtract(const Duration(days: 4)),
          category: 'Lebensmittel',
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 6,
          title: 'Benzin',
          amount: 60,
          date: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Transport',
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 7,
          title: 'Kinokarte',
          amount: 15,
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Unterhaltung',
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 8,
          title: 'Gehalt',
          amount: 2360,
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Salary',
          type: TransactionType.income,
        ),
        TransactionModel(
          id: 9,
          title: 'Café',
          amount: 12.50,
          date: DateTime.now(),
          category: 'Lebensmittel',
          type: TransactionType.expense,
        ),
        TransactionModel(
          id: 10,
          title: 'Streaming',
          amount: 15,
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Unterhaltung',
          type: TransactionType.expense,
        ),
      ]);

  void add(TransactionModel t) {
    state = [t, ...state];
  }

  void remove(int id) {
    state = state.where((e) => e.id != id).toList();
  }
}
