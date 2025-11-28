import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgator/models/transaction.dart';
import 'package:budgator/core/services/sample_data.dart';
import 'package:budgator/features/budget/providers/budget_provider.dart';

class TransactionState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref ref;

  TransactionNotifier(this.ref) : super(TransactionState()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final transactions = SampleData.getSampleTransactions();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    final updatedTransactions = [transaction, ...state.transactions];
    state = state.copyWith(transactions: updatedTransactions);

    // Update budget spent amount if it's an expense
    if (transaction.type == TransactionType.expense) {
      final budgetState = ref.read(budgetProvider);
      final matchingBudget = budgetState.budgets.firstWhere(
        (b) => b.category == transaction.category,
        orElse: () => budgetState.budgets.first,
      );
      ref.read(budgetProvider.notifier).updateSpent(
            matchingBudget.id,
            transaction.amount,
          );
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final updatedTransactions = state.transactions.map((t) {
      return t.id == transaction.id ? transaction : t;
    }).toList();

    state = state.copyWith(transactions: updatedTransactions);
  }

  Future<void> deleteTransaction(String transactionId) async {
    final updatedTransactions =
        state.transactions.where((t) => t.id != transactionId).toList();

    state = state.copyWith(transactions: updatedTransactions);
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref);
});

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactionState = ref.watch(transactionProvider);
  final transactions = transactionState.transactions.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return transactions.take(5).toList();
});

final transactionsByCategoryProvider =
    Provider.family<List<Transaction>, String>((ref, category) {
  final transactionState = ref.watch(transactionProvider);
  return transactionState.transactions
      .where((t) => t.category == category)
      .toList();
});

final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final transactionState = ref.watch(transactionProvider);
  final Map<String, double> categoryTotals = {};

  for (final transaction in transactionState.transactions) {
    if (transaction.type == TransactionType.expense) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
  }

  return categoryTotals;
});

final monthlySummaryProvider = Provider<Map<String, double>>((ref) {
  final transactionState = ref.watch(transactionProvider);

  return {
    'income': transactionState.totalIncome,
    'expenses': transactionState.totalExpenses,
    'balance': transactionState.balance,
  };
});
