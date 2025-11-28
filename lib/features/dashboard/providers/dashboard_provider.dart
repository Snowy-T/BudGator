import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgator/features/transactions/providers/transaction_provider.dart';
import 'package:budgator/features/budget/providers/budget_provider.dart';

class DashboardState {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double savingsRate;
  final bool isLoading;

  DashboardState({
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpenses = 0,
    this.savingsRate = 0,
    this.isLoading = false,
  });

  DashboardState copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpenses,
    double? savingsRate,
    bool? isLoading,
  }) {
    return DashboardState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      savingsRate: savingsRate ?? this.savingsRate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final dashboardProvider = Provider<DashboardState>((ref) {
  final transactionState = ref.watch(transactionProvider);
  final budgetState = ref.watch(budgetProvider);

  final income = transactionState.totalIncome;
  final expenses = transactionState.totalExpenses;
  final balance = income - expenses;
  final savingsRate = income > 0 ? ((income - expenses) / income) * 100 : 0.0;

  return DashboardState(
    totalBalance: balance,
    monthlyIncome: income,
    monthlyExpenses: expenses,
    savingsRate: savingsRate,
    isLoading: transactionState.isLoading || budgetState.isLoading,
  );
});
