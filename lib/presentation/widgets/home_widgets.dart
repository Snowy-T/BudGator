import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/services/money_formatter.dart';
import '../controllers/category_budget_provider.dart';
import '../controllers/home_calculation_provider.dart';
import '../controllers/savings_goal_provider.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import '../theme/category_colors.dart';

String formatAmount(double amount) {
  return formatEuroSmart(amount);
}

String formatWeekdayOrDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));
  final dateOnly = DateTime(date.year, date.month, date.day);
  final isThisWeek =
      !dateOnly.isBefore(startOfWeek) && dateOnly.isBefore(endOfWeek);

  if (isThisWeek) {
    const weekdayNames = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return weekdayNames[dateOnly.weekday - 1];
  }

  if (dateOnly.year == today.year) {
    return DateFormat('dd.MMM', 'en_US').format(dateOnly);
  }
  return DateFormat('dd.MMM.yyyy', 'en_US').format(dateOnly);
}

final amountVisibilityProvider = StateProvider<bool>((ref) => true);

class SensitiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isVisible;
  final int? maxLines;
  final TextOverflow? overflow;

  const SensitiveText({
    super.key,
    required this.text,
    this.style,
    required this.isVisible,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final child = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );

    final shouldBlur = !isVisible && text.contains('€');

    if (!shouldBlur) {
      return child;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: child,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.2),
                    colorScheme.surface.withValues(alpha: 0.45),
                    colorScheme.surface.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: Center(
              child: Text(
                '••••••',
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expenses = ref.watch(totalExpensesProvider);
    final monthlySummary = ref.watch(monthlyBudgetSummaryProvider);
    final isVisible = ref.watch(amountVisibilityProvider);
    final onTopColor = isDark ? const Color(0xFFE8FBF2) : Colors.white;
    final onTopMuted = onTopColor.withValues(alpha: 0.86);
    final balanceColor = balance >= 0 ? onTopColor : const Color(0xFFFFE2E2);
    final gradient = isDark
        ? const [Color(0xFF0A7A56), Color(0xFF0E5D45)]
        : const [Color(0xFF16A36A), Color(0xFF0D7A4F)];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verfügbarer Saldo',
                style: TextStyle(color: onTopMuted, fontSize: 14),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(amountVisibilityProvider.notifier).state =
                      !isVisible;
                },
                child: Icon(
                  isVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: onTopMuted,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SensitiveText(
            text: formatEuroSmart(balance),
            isVisible: isVisible,
            style: TextStyle(
              color: balanceColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InlineAmount(
                  label: 'Einnahmen',
                  amount: income,
                  icon: Icons.arrow_downward_rounded,
                  isVisible: isVisible,
                  textColor: onTopColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InlineAmount(
                  label: 'Ausgaben',
                  amount: expenses,
                  icon: Icons.arrow_upward_rounded,
                  isVisible: isVisible,
                  textColor: onTopColor,
                ),
              ),
            ],
          ),
          if (monthlySummary.hasTotalBudget) ...[
            const SizedBox(height: 12),
            _InlineAmount(
              label: 'Monatsbudget Rest',
              amount: monthlySummary.remainingTotalBudget,
              icon: Icons.wallet_rounded,
              isVisible: isVisible,
              isMonthlyBudget: true,
              textColor: onTopColor,
              totalBudget: monthlySummary.totalBudget,
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineAmount extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final bool isVisible;
  final bool isMonthlyBudget;
  final Color textColor;
  final double? totalBudget;

  const _InlineAmount({
    required this.label,
    required this.amount,
    required this.icon,
    required this.isVisible,
    this.isMonthlyBudget = false,
    required this.textColor,
    this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = isMonthlyBudget && amount < 0;
    final bgColor = isOverBudget
        ? Colors.red.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.18);
    final borderCol = isOverBudget
        ? Colors.red.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                SensitiveText(
                  text: formatEuroSmart(amount),
                  isVisible: isVisible,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isMonthlyBudget &&
                    totalBudget != null &&
                    totalBudget! > 0) ...[
                  const SizedBox(height: 6),
                  _BudgetMiniBar(
                    totalBudget: totalBudget!,
                    remaining: amount,
                    color: textColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetMiniBar extends StatelessWidget {
  final double totalBudget;
  final double remaining;
  final Color color;

  const _BudgetMiniBar({
    required this.totalBudget,
    required this.remaining,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final spent = (totalBudget - remaining).clamp(0.0, totalBudget);
    final usedFactor = totalBudget <= 0
        ? 0.0
        : (spent / totalBudget).clamp(0.0, 1.0);
    final isOver = remaining < 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 6,
        value: usedFactor,
        backgroundColor: color.withValues(alpha: 0.22),
        valueColor: AlwaysStoppedAnimation<Color>(
          isOver ? const Color(0xFFFFA1A1) : color,
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final transactions = ref.watch(transactionsProvider);
    final isVisible = ref.watch(amountVisibilityProvider);
    final now = DateTime.now();
    final data = _buildSeries(transactions, _range, now);
    final hasLastMonthExpenses = _hasExpensesInLast30Days(transactions, now);

    if (!hasLastMonthExpenses) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            'Keine Ausgaben in den letzten 30 Tagen',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
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
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: _LineChart(
                    values: data.values,
                    labels: data.labels,
                    enableHorizontalScroll: _range == _TrendRange.month,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatBox(
                      label: 'Gesamt',
                      value: formatEuroSmart(totalExpenses),
                      isVisible: isVisible,
                    ),
                    _StatBox(
                      label: 'Durchschnitt',
                      value: formatEuroSmart(avgExpenses),
                      isVisible: isVisible,
                    ),
                    _StatBox(
                      label: 'Max',
                      value: formatEuroSmart(maxAmount),
                      isVisible: isVisible,
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

bool _hasExpensesInLast30Days(
  List<TransactionModel> transactions,
  DateTime now,
) {
  final cutoff = now.subtract(const Duration(days: 30));
  return transactions.any(
    (t) =>
        t.type == TransactionType.expense &&
        t.amount > 0 &&
        (t.date.isAfter(cutoff) || t.date.isAtSameMomentAs(cutoff)),
  );
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
  DateTime asDateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  final expenses = transactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  switch (range) {
    case _TrendRange.today:
      final labels = ['0', '4', '8', '12', '16', '20'];
      final values = List<double>.filled(labels.length, 0);
      final today = asDateOnly(now);
      for (final t in expenses) {
        final txDate = asDateOnly(t.date);
        if (txDate == today) {
          final bucket = (t.date.hour / 4).floor().clamp(0, 5);
          values[bucket] += t.amount;
        }
      }
      return _TrendSeries(labels: labels, values: values);
    case _TrendRange.week:
      final today = asDateOnly(now);
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
      final values = List<double>.filled(labels.length, 0);
      for (final t in expenses) {
        final txDate = asDateOnly(t.date);
        final dayDiff = txDate.difference(startOfWeek).inDays;
        if (dayDiff >= 0 && dayDiff < 7) {
          values[dayDiff] += t.amount;
        }
      }
      return _TrendSeries(labels: labels, values: values);
    case _TrendRange.month:
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final values = List<double>.filled(daysInMonth, 0);
      final labels = List<String>.generate(daysInMonth, (index) {
        final day = index + 1;
        final showLabel = day == 1 || day % 3 == 0 || day == daysInMonth;
        return showLabel ? day.toString() : '';
      });
      for (final t in expenses) {
        if (t.date.year == now.year && t.date.month == now.month) {
          values[t.date.day - 1] += t.amount;
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
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
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final bool enableHorizontalScroll;

  const _LineChart({
    required this.values,
    required this.labels,
    this.enableHorizontalScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desiredWidth = values.length * 20.0;
        final chartWidth =
            enableHorizontalScroll && desiredWidth > constraints.maxWidth
            ? desiredWidth
            : constraints.maxWidth;

        final chart = SizedBox(
          width: chartWidth,
          child: CustomPaint(
            size: Size(chartWidth, constraints.maxHeight),
            painter: _LineChartPainter(
              values: values,
              showDots: values.length <= 14,
              gridColor: Theme.of(context).colorScheme.outlineVariant,
              dotInnerColor: Theme.of(context).colorScheme.surface,
            ),
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
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );

        if (!enableHorizontalScroll) {
          return chart;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: chart,
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final bool showDots;
  final Color gridColor;
  final Color dotInnerColor;

  _LineChartPainter({
    required this.values,
    required this.showDots,
    required this.gridColor,
    required this.dotInnerColor,
  });

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
      ..color = gridColor
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

    if (showDots) {
      for (final point in points) {
        canvas.drawCircle(point, 3.5, paintDot);
        canvas.drawCircle(
          point,
          5,
          Paint()
            ..color = dotInnerColor
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(point, 3.5, paintDot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.showDots != showDots ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.dotInnerColor != dotInnerColor;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isVisible;

  const _StatBox({
    required this.label,
    required this.value,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SensitiveText(
            text: value,
            isVisible: isVisible,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
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
    final isVisible = ref.watch(amountVisibilityProvider);
    final limitedCategories = topCategories.take(5).toList();

    if (limitedCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Keine Kategorien',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Kategorien',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: limitedCategories.map((category) {
                final color = categoryColors[category.name] ?? Colors.grey;
                final icon =
                    categoryIcons[category.name] ?? Icons.category_rounded;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                            color: color.withValues(alpha: 0.1),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SensitiveText(
                          text: formatEuroSmart(category.amount),
                          isVisible: isVisible,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
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
    final isVisible = ref.watch(amountVisibilityProvider);

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
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
                            SensitiveText(
                              text: formatWeekdayOrDate(transaction.date),
                              isVisible: isVisible,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SensitiveText(
                        text:
                            '${isIncome ? '+' : '-'}${formatEuroSmart(transaction.amount)}',
                        isVisible: isVisible,
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
  const SavingsGoalWidget({super.key, this.onCreateGoalTap});

  final VoidCallback? onCreateGoalTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref
        .watch(savingsGoalProvider)
        .where((goal) => goal.isActive)
        .toList();
    if (goals.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            const Expanded(child: Text('Noch kein Sparziel aktiv.')),
            TextButton.icon(
              onPressed: onCreateGoalTap,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Sparziel erstellen'),
            ),
          ],
        ),
      );
    }

    if (goals.length > 1) {
      return _CompactSavingsGoalsRow(goals: goals);
    }

    final savingsGoal = goals.first;

    final progress = (savingsGoal.current / savingsGoal.target).clamp(0.0, 1.0);
    final isVisible = ref.watch(amountVisibilityProvider);

    Future<void> openEditDialog() async {
      final nameController = TextEditingController(text: savingsGoal.name);
      final targetController = TextEditingController(
        text: formatInputAmount(savingsGoal.target),
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

      if (!context.mounted) {
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

      ref.read(savingsGoalProvider.notifier).updateSingleGoal(name, target);
    }

    final accent = savingsGoal.colorValue != null
        ? Color(savingsGoal.colorValue!)
        : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, Colors.white, 0.2) ?? accent],
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
                child: SensitiveText(
                  text:
                      '${formatEuroSmart(savingsGoal.current)} von ${formatEuroSmart(savingsGoal.target)}',
                  isVisible: isVisible,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SensitiveText(
                text: '${(progress * 100).toStringAsFixed(0)}%',
                isVisible: isVisible,
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

class _CompactSavingsGoalsRow extends StatelessWidget {
  final List<SavingsGoal> goals;

  const _CompactSavingsGoalsRow({required this.goals});

  @override
  Widget build(BuildContext context) {
    final topGoals = goals.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sparziele',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '${goals.length} aktiv',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topGoals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final goal = topGoals[index];
                final progress = goal.target <= 0
                    ? 0.0
                    : (goal.current / goal.target).clamp(0.0, 1.0);
                final accent = goal.colorValue != null
                    ? Color(goal.colorValue!)
                    : const Color(0xFF10B981);

                return Container(
                  width: 170,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% · ${formatEuroSmart(goal.current)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
