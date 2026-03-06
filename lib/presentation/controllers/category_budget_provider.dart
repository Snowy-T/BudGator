import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/app_local_storage.dart';
import '../../data/models/transaction_model.dart';
import 'transaction_provider.dart';

class CategoryBudget {
  final String id;
  final String name;
  final double monthlyLimit;
  final double alertThreshold;

  const CategoryBudget({
    required this.id,
    required this.name,
    required this.monthlyLimit,
    this.alertThreshold = 0.8,
  });

  CategoryBudget copyWith({
    String? id,
    String? name,
    double? monthlyLimit,
    double? alertThreshold,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      alertThreshold: alertThreshold ?? this.alertThreshold,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'monthlyLimit': monthlyLimit,
    'alertThreshold': alertThreshold,
  };

  factory CategoryBudget.fromMap(Map<String, dynamic> map) {
    return CategoryBudget(
      id:
          (map['id'] as String?) ??
          'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: (map['name'] as String?) ?? 'Kategorie',
      monthlyLimit: ((map['monthlyLimit'] as num?) ?? 0).toDouble(),
      alertThreshold: ((map['alertThreshold'] as num?) ?? 0.8).toDouble(),
    );
  }
}

class CategoryBudgetProgress {
  final CategoryBudget budget;
  final double spent;

  const CategoryBudgetProgress({required this.budget, required this.spent});

  double get remaining => budget.monthlyLimit - spent;

  double get progress {
    if (budget.monthlyLimit <= 0) return 0;
    return (spent / budget.monthlyLimit).clamp(0.0, 10.0);
  }

  bool get isOverLimit => spent > budget.monthlyLimit;

  bool get isNearLimit => progress >= budget.alertThreshold && !isOverLimit;
}

class CategoryBudgetNotifier extends StateNotifier<List<CategoryBudget>> {
  CategoryBudgetNotifier(this._storage) : super(const []) {
    _load();
  }

  final AppLocalStorage _storage;

  void _load() {
    final saved = _storage.loadCategoryBudgets();
    if (saved.isNotEmpty) {
      state = saved.map(CategoryBudget.fromMap).toList();
      return;
    }

    // Seed from common categories so user can directly set limits.
    state = const [
      CategoryBudget(id: 'cat-wohnen', name: 'Wohnen', monthlyLimit: 0),
      CategoryBudget(id: 'cat-food', name: 'Lebensmittel', monthlyLimit: 0),
      CategoryBudget(id: 'cat-transport', name: 'Transport', monthlyLimit: 0),
      CategoryBudget(
        id: 'cat-entertainment',
        name: 'Unterhaltung',
        monthlyLimit: 0,
      ),
      CategoryBudget(id: 'cat-shopping', name: 'Shopping', monthlyLimit: 0),
      CategoryBudget(id: 'cat-cafe', name: 'Cafe', monthlyLimit: 0),
      CategoryBudget(id: 'cat-general', name: 'General', monthlyLimit: 0),
    ];
    unawaited(_save());
  }

  Future<void> _save() {
    return _storage.saveCategoryBudgets(state.map((e) => e.toMap()).toList());
  }

  void addCategory(String name, {double monthlyLimit = 0}) {
    if (name.trim().isEmpty || monthlyLimit < 0) return;

    final normalized = name.trim().toLowerCase();
    final exists = state.any((e) => e.name.toLowerCase() == normalized);
    if (exists) return;

    state = [
      ...state,
      CategoryBudget(
        id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        monthlyLimit: monthlyLimit,
      ),
    ];
    unawaited(_save());
  }

  void setLimit(String id, double monthlyLimit) {
    if (monthlyLimit < 0) return;
    state = [
      for (final budget in state)
        if (budget.id == id)
          budget.copyWith(monthlyLimit: monthlyLimit)
        else
          budget,
    ];
    unawaited(_save());
  }

  void renameCategory(String id, String name) {
    if (name.trim().isEmpty) return;
    state = [
      for (final budget in state)
        if (budget.id == id) budget.copyWith(name: name.trim()) else budget,
    ];
    unawaited(_save());
  }

  void deleteCategory(String id) {
    state = state.where((budget) => budget.id != id).toList();
    unawaited(_save());
  }
}

final categoryBudgetProvider =
    StateNotifierProvider<CategoryBudgetNotifier, List<CategoryBudget>>((ref) {
      return CategoryBudgetNotifier(ref.read(localStorageProvider));
    });

DateTime _monthStart(DateTime date) => DateTime(date.year, date.month, 1);
DateTime _monthEndExclusive(DateTime date) =>
    DateTime(date.year, date.month + 1, 1);

final categoryBudgetProgressProvider = Provider<List<CategoryBudgetProgress>>((
  ref,
) {
  final budgets = ref.watch(categoryBudgetProvider);
  final transactions = ref.watch(transactionsProvider);

  final now = DateTime.now();
  final monthStart = _monthStart(now);
  final monthEnd = _monthEndExclusive(now);

  final spentByCategory = <String, double>{};
  for (final tx in transactions) {
    if (tx.type != TransactionType.expense) continue;
    if (tx.date.isBefore(monthStart) || !tx.date.isBefore(monthEnd)) continue;
    spentByCategory[tx.category] =
        (spentByCategory[tx.category] ?? 0) + tx.amount;
  }

  return budgets
      .map(
        (budget) => CategoryBudgetProgress(
          budget: budget,
          spent: spentByCategory[budget.name] ?? 0,
        ),
      )
      .toList();
});

final knownCategoriesProvider = Provider<List<String>>((ref) {
  final budgets = ref.watch(categoryBudgetProvider).map((e) => e.name);
  final txCategories = ref
      .watch(transactionsProvider)
      .map((tx) => tx.category)
      .where((c) => c.trim().isNotEmpty);

  final combined = {...budgets, ...txCategories}.toList()..sort();
  return combined;
});
