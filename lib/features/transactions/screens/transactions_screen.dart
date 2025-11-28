import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:budgator/core/constants/app_colors.dart';
import 'package:budgator/models/transaction.dart';
import 'package:budgator/features/transactions/providers/transaction_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: transactionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(transactionProvider.notifier).loadTransactions(),
              child: Column(
                children: [
                  // Summary Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryColumn(
                          label: 'Income',
                          value: currencyFormat.format(transactionState.totalIncome),
                          color: AppColors.success,
                          icon: Icons.arrow_downward,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade200,
                        ),
                        _SummaryColumn(
                          label: 'Expenses',
                          value: currencyFormat.format(transactionState.totalExpenses),
                          color: AppColors.error,
                          icon: Icons.arrow_upward,
                        ),
                      ],
                    ),
                  ),

                  // Transactions List
                  Expanded(
                    child: transactionState.transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => context.push('/add-transaction'),
                                  child: const Text('Add Transaction'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: transactionState.transactions.length,
                            itemBuilder: (context, index) {
                              return _TransactionCard(
                                transaction: transactionState.transactions[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-transaction'),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const _TransactionCard({required this.transaction});

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
    final dateFormat = DateFormat('MMM d, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final isExpense = transaction.type == TransactionType.expense;
    final color = _getCategoryColor(transaction.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: color,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${transaction.category} • ${dateFormat.format(transaction.date)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isExpense ? AppColors.error : AppColors.success,
          ),
        ),
      ),
    );
  }
}
