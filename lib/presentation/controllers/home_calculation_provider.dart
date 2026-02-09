import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import './transaction_provider.dart';

// Gesamtbilanz: Einnahmen - Ausgaben
final balanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final income = transactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (sum, t) => sum + t.amount);
  final expenses = transactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.amount);
  return income - expenses;
});

// Gesamte Einnahmen
final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (sum, t) => sum + t.amount);
});

// Gesamte Ausgaben
final totalExpensesProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (sum, t) => sum + t.amount);
});

// Ausgaben nach Woche gruppiert
final expensesByWeekProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final expenses = transactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  final grouped = <String, double>{};

  for (final t in expenses) {
    final weekStart = t.date.subtract(Duration(days: t.date.weekday - 1));
    final key = '${weekStart.day}.${weekStart.month}';
    grouped[key] = (grouped[key] ?? 0) + t.amount;
  }

  return grouped;
});

// Top 5 Ausgabenkategorien (nach Betrag sortiert)
class TopCategory {
  final String name;
  final double amount;

  TopCategory({required this.name, required this.amount});
}

final topCategoriesProvider = Provider<List<TopCategory>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final expenses = transactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  final grouped = <String, double>{};

  for (final t in expenses) {
    grouped[t.category] = (grouped[t.category] ?? 0) + t.amount;
  }

  final sorted =
      grouped.entries
          .map((e) => TopCategory(name: e.key, amount: e.value))
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

  return sorted.take(5).toList();
});

// Letzte 6 Transaktionen
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
  return sorted.take(6).toList();
});

// Sparziel Festwert (könnte später auch State sein)
final savingsGoalProvider = Provider<({double target, double current})>((ref) {
  final balance = ref.watch(balanceProvider);
  return (target: 3000, current: balance);
});
