import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:budgator/core/constants/app_colors.dart';
import 'package:budgator/models/transaction.dart';
import 'package:budgator/features/transactions/providers/transaction_provider.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTransactions = ref.watch(recentTransactionsProvider);

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
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/transactions'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...recentTransactions
                  .map((transaction) => _TransactionItem(transaction: transaction)),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  IconData _getCategoryIcon(String category) {
    final icons = {
      'Food & Dining': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Entertainment': Icons.movie,
      'Bills & Utilities': Icons.receipt,
      'Healthcare': Icons.local_hospital,
      'Education': Icons.school,
      'Salary': Icons.work,
      'Freelance': Icons.laptop,
      'Investment': Icons.trending_up,
      'Gift': Icons.card_giftcard,
    };
    return icons[category] ?? Icons.attach_money;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': const Color(0xFF4CAF50),
      'Transportation': const Color(0xFF2196F3),
      'Shopping': const Color(0xFFE91E63),
      'Entertainment': const Color(0xFF9C27B0),
      'Bills & Utilities': const Color(0xFFFF9800),
      'Healthcare': const Color(0xFFF44336),
      'Education': const Color(0xFF3F51B5),
      'Salary': const Color(0xFF4CAF50),
      'Freelance': const Color(0xFF2196F3),
      'Investment': const Color(0xFF9C27B0),
      'Gift': const Color(0xFFE91E63),
    };
    return colors[category] ?? const Color(0xFF607D8B);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = transaction.type == TransactionType.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(transaction.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(transaction.category),
              color: _getCategoryColor(transaction.category),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${transaction.category} • ${dateFormat.format(transaction.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isExpense ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
