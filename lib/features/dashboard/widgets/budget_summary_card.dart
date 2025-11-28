import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:budgator/core/constants/app_colors.dart';
import 'package:budgator/features/budget/providers/budget_provider.dart';

class BudgetSummaryCard extends ConsumerWidget {
  const BudgetSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);
    final activeBudgets = budgetState.budgets.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/budgets'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeBudgets.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No budgets set',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...activeBudgets.map((budget) => _BudgetProgressItem(
                    name: budget.name,
                    spent: budget.spent,
                    total: budget.amount,
                    category: budget.category,
                  )),
          ],
        ),
      ),
    );
  }
}

class _BudgetProgressItem extends StatelessWidget {
  final String name;
  final double spent;
  final double total;
  final String category;

  const _BudgetProgressItem({
    required this.name,
    required this.spent,
    required this.total,
    required this.category,
  });

  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': const Color(0xFF4CAF50),
      'Transportation': const Color(0xFF2196F3),
      'Shopping': const Color(0xFFE91E63),
      'Entertainment': const Color(0xFF9C27B0),
      'Bills & Utilities': const Color(0xFFFF9800),
      'Healthcare': const Color(0xFFF44336),
      'Education': const Color(0xFF3F51B5),
    };
    return colors[category] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final progress = (spent / total).clamp(0.0, 1.0);
    final isOverBudget = spent > total;
    final color = _getCategoryColor(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${currencyFormat.format(spent)} / ${currencyFormat.format(total)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverBudget ? AppColors.error : AppColors.textSecondary,
                  fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? AppColors.error : color,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
