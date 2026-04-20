import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import 'savings_goal_provider.dart';
import 'transaction_provider.dart';

String _monthKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}

String _monthlyContributionReferenceId({
  required String goalId,
  required DateTime date,
}) {
  return 'savings-monthly:$goalId:${_monthKey(date)}';
}

bool _hasMonthlyContributionForGoal({
  required List<TransactionModel> transactions,
  required String referenceId,
}) {
  return transactions.any(
    (tx) =>
        tx.type == TransactionType.expense &&
        tx.category == 'Sparziel' &&
        tx.referenceId == referenceId,
  );
}

void applyDueSavingsContributions(WidgetRef ref, {DateTime? now}) {
  final date = now ?? DateTime.now();
  final applied = ref
      .read(savingsGoalProvider.notifier)
      .applyMonthlyContributionIfDue(now: date);
  if (applied.isEmpty) return;

  final txNotifier = ref.read(transactionsProvider.notifier);
  final existing = ref.read(transactionsProvider);

  for (final item in applied) {
    final referenceId = _monthlyContributionReferenceId(
      goalId: item.goalId,
      date: date,
    );

    if (_hasMonthlyContributionForGoal(
      transactions: existing,
      referenceId: referenceId,
    )) {
      continue;
    }

    txNotifier.add(
      TransactionModel(
        title: '${item.goalName}-Monatsbeitrag',
        amount: item.amount,
        date: date,
        category: 'Sparziel',
        type: TransactionType.expense,
        referenceId: referenceId,
      ),
    );
  }
}
