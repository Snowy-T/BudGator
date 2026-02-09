import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/home_calculation_provider.dart' hide savingsGoalProvider;
import '../controllers/savings_goal_provider.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import '../theme/category_colors.dart';

String formatAmount(double amount) {
  final formatted = amount.toStringAsFixed(2);
  final parts = formatted.split('.');
  var intPart = parts[0];
  intPart = intPart.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '€$intPart.${parts[1]}';
}

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expenses = ref.watch(totalExpensesProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verfügbarer Saldo',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isVisible = !_isVisible),
                child: Icon(
                  _isVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isVisible
                ? '€${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}'
                : '••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InlineAmount(
                  label: 'Einnahmen',
                  amount: income,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InlineAmount(
                  label: 'Ausgaben',
                  amount: expenses,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineAmount extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;

  const _InlineAmount({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '€${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _TrendRange { today, week, month }

class ExpensesByWeekWidget extends ConsumerStatefulWidget {
  const ExpensesByWeekWidget({super.key});

  @override
  ConsumerState<ExpensesByWeekWidget> createState() =>
      _ExpensesByWeekWidgetState();
}

class _ExpensesByWeekWidgetState extends ConsumerState<ExpensesByWeekWidget> {
  _TrendRange _range = _TrendRange.week;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final now = DateTime.now();
    final data = _buildSeries(transactions, _range, now);

    if (data.values.every((v) => v == 0)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            _range == _TrendRange.today
                ? 'Keine Ausgaben heute'
                : _range == _TrendRange.week
                ? 'Keine Ausgaben diese Woche'
                : 'Keine Ausgaben diesen Monat',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxAmount = data.values.reduce((a, b) => a > b ? a : b);
    final totalExpenses = data.values.fold<double>(0, (a, b) => a + b);
    final avgExpenses = totalExpenses / data.values.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ausgaben Trend',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              _RangeSelector(
                range: _range,
                onChanged: (value) => setState(() => _range = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: _LineChart(values: data.values, labels: data.labels),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatBox(
                      label: 'Gesamt',
                      value: '€${totalExpenses.toStringAsFixed(0)}',
                    ),
                    _StatBox(
                      label: 'Durchschnitt',
                      value: '€${avgExpenses.toStringAsFixed(0)}',
                    ),
                    _StatBox(
                      label: 'Max',
                      value: '€${maxAmount.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendSeries {
  final List<String> labels;
  final List<double> values;

  _TrendSeries({required this.labels, required this.values});
}

_TrendSeries _buildSeries(
  List<TransactionModel> transactions,
  _TrendRange range,
  DateTime now,
) {
  final expenses = transactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  switch (range) {
    case _TrendRange.today:
      final labels = ['0', '4', '8', '12', '16', '20'];
      final values = List<double>.filled(labels.length, 0);
      for (final t in expenses) {
        if (t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day) {
          final bucket = (t.date.hour / 4).floor().clamp(0, 5);
          values[bucket] += t.amount;
        }
      }
      return _TrendSeries(labels: labels, values: values);
    case _TrendRange.week:
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
      final values = List<double>.filled(labels.length, 0);
      for (final t in expenses) {
        final dayDiff = t.date.difference(startOfWeek).inDays;
        if (dayDiff >= 0 && dayDiff < 7) {
          values[dayDiff] += t.amount;
        }
      }
      return _TrendSeries(labels: labels, values: values);
    case _TrendRange.month:
      final labels = ['W1', 'W2', 'W3', 'W4'];
      final values = List<double>.filled(labels.length, 0);
      for (final t in expenses) {
        if (t.date.year == now.year && t.date.month == now.month) {
          final day = t.date.day;
          final bucket = day <= 7
              ? 0
              : day <= 14
              ? 1
              : day <= 21
              ? 2
              : 3;
          values[bucket] += t.amount;
        }
      }
      return _TrendSeries(labels: labels, values: values);
  }
}

class _RangeSelector extends StatelessWidget {
  final _TrendRange range;
  final ValueChanged<_TrendRange> onChanged;

  const _RangeSelector({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          _RangeChip(
            label: 'Heute',
            isActive: range == _TrendRange.today,
            onTap: () => onChanged(_TrendRange.today),
          ),
          _RangeChip(
            label: 'Woche',
            isActive: range == _TrendRange.week,
            onTap: () => onChanged(_TrendRange.week),
          ),
          _RangeChip(
            label: 'Monat',
            isActive: range == _TrendRange.month,
            onTap: () => onChanged(_TrendRange.month),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.black87 : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const _LineChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _LineChartPainter(values: values),
          child: Column(
            children: [
              Expanded(child: Container()),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels
                    .map(
                      (label) => Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;

  _LineChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final paintLine = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final paintDot = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.fill;
    final paintGrid = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const paddingTop = 8.0;
    const paddingBottom = 26.0;
    final usableHeight = size.height - paddingTop - paddingBottom;
    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0;

    for (var i = 0; i < 3; i++) {
      final y = paddingTop + usableHeight * (i / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      final normalized = maxValue == 0 ? 0 : value / maxValue;
      final x = (stepX * i).toDouble();
      final y = (paddingTop + usableHeight * (1 - normalized)).toDouble();
      points.add(Offset(x, y));
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(path, paintLine);

    for (final point in points) {
      canvas.drawCircle(point, 3.5, paintDot);
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(point, 3.5, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class TopCategoriesWidget extends ConsumerWidget {
  const TopCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topCategories = ref.watch(topCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Kategorien',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Alle',
                  style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...topCategories.map((category) {
            final color = categoryColors[category.name] ?? Colors.grey;
            final icon = categoryIcons[category.name] ?? Icons.category_rounded;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '€${category.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '€${category.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class RecentTransactionsWidget extends ConsumerWidget {
  final VoidCallback? onShowAll;

  const RecentTransactionsWidget({super.key, this.onShowAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTransactions = ref.watch(recentTransactionsProvider);

    if (recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Keine Transaktionen'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Letzte Transaktionen',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (onShowAll != null)
                GestureDetector(
                  onTap: onShowAll,
                  child: Text(
                    'Alle',
                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final transaction in recentTransactions) ...[
            Builder(
              builder: (context) {
                final isIncome = transaction.type.name == 'income';
                final color = isIncome ? Colors.green : Colors.red;
                final icon = isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${transaction.date.day}.${transaction.date.month}.${transaction.date.year}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'}€${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class SavingsGoalWidget extends ConsumerWidget {
  const SavingsGoalWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsGoal = ref.watch(savingsGoalWithBalanceProvider);
    final progress = (savingsGoal.current / savingsGoal.target).clamp(0.0, 1.0);

    Future<void> openEditDialog() async {
      final nameController = TextEditingController(text: savingsGoal.name);
      final targetController = TextEditingController(
        text: savingsGoal.target.toStringAsFixed(0),
      );

      final result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sparziel bearbeiten'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Zielname'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Zielbetrag'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      );

      if (result != true) {
        return;
      }

      final name = nameController.text.trim();
      final target = double.tryParse(
        targetController.text.replaceAll(',', '.').trim(),
      );
      if (name.isEmpty || target == null || target <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte gültige Werte eingeben.')),
        );
        return;
      }

      ref.read(savingsGoalProvider.notifier).updateGoal(name, target);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sparziel: ${savingsGoal.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: openEditDialog,
                icon: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '€${savingsGoal.current.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} von €${savingsGoal.target.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
