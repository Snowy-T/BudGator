import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgator/models/budget.dart';
import 'package:budgator/core/services/sample_data.dart';

class BudgetState {
  final List<Budget> budgets;
  final bool isLoading;
  final String? error;

  BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalBudget => budgets.fold(0, (sum, b) => sum + b.amount);
  double get totalSpent => budgets.fold(0, (sum, b) => sum + b.spent);
  double get totalRemaining => totalBudget - totalSpent;

  BudgetState copyWith({
    List<Budget>? budgets,
    bool? isLoading,
    String? error,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier() : super(BudgetState()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Load sample data
      final budgets = SampleData.getSampleBudgets();
      state = state.copyWith(budgets: budgets, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBudget(Budget budget) async {
    state = state.copyWith(
      budgets: [...state.budgets, budget],
    );
  }

  Future<void> updateBudget(Budget budget) async {
    final updatedBudgets = state.budgets.map((b) {
      return b.id == budget.id ? budget : b;
    }).toList();
    
    state = state.copyWith(budgets: updatedBudgets);
  }

  Future<void> deleteBudget(String budgetId) async {
    final updatedBudgets = state.budgets
        .where((b) => b.id != budgetId)
        .toList();
    
    state = state.copyWith(budgets: updatedBudgets);
  }

  void updateSpent(String budgetId, double amount) {
    final updatedBudgets = state.budgets.map((b) {
      if (b.id == budgetId) {
        return b.copyWith(spent: b.spent + amount);
      }
      return b;
    }).toList();
    
    state = state.copyWith(budgets: updatedBudgets);
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier();
});

final activeBudgetsProvider = Provider<List<Budget>>((ref) {
  final budgetState = ref.watch(budgetProvider);
  return budgetState.budgets.where((b) => b.isActive).toList();
});

final budgetByCategoryProvider = Provider.family<Budget?, String>((ref, category) {
  final budgetState = ref.watch(budgetProvider);
  try {
    return budgetState.budgets.firstWhere((b) => b.category == category);
  } catch (_) {
    return null;
  }
});
