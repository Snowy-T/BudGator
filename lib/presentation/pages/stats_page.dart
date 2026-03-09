import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import '../controllers/transaction_provider.dart';
import '../theme/category_colors.dart';

enum StatsRange { last7Days, last30Days, last90Days, all }

extension _StatsRangeLabel on StatsRange {
  String get label {
    switch (this) {
      case StatsRange.last7Days:
        return '7 Tage';
      case StatsRange.last30Days:
        return '30 Tage';
      case StatsRange.last90Days:
        return '90 Tage';
      case StatsRange.all:
        return 'Gesamt';
    }
  }
}

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  StatsRange _selectedRange = StatsRange.last30Days;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final filtered = _applyRangeFilter(transactions, _selectedRange);
    final stats = _buildStats(filtered);

    if (transactions.isEmpty) {
      return const _EmptyStatsState();
    }

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistik',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stats.transactionCount} Buchungen im Zeitraum',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final range in StatsRange.values)
                        ChoiceChip(
                          label: Text(range.label),
                          selected: _selectedRange == range,
                          onSelected: (_) {
                            setState(() => _selectedRange = range);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InsightCard(stats: stats, selectedRange: _selectedRange),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                const _SectionTitle('Kernmetriken'),
                const SizedBox(height: 10),
                _KpiGrid(stats: stats),
                const SizedBox(height: 20),
                const _SectionTitle('Wochenverlauf'),
                const SizedBox(height: 10),
                _WeeklyTrendCard(stats: stats),
                const SizedBox(height: 20),
                const _SectionTitle('Kategorie-Anteile'),
                const SizedBox(height: 10),
                _CategoryBreakdownCard(stats: stats),
                const SizedBox(height: 20),
                const _SectionTitle('Wochentags-Muster'),
                const SizedBox(height: 10),
                _WeekdayPatternCard(stats: stats),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.stats, required this.selectedRange});

  final _StatsSnapshot stats;
  final StatsRange selectedRange;

  @override
  Widget build(BuildContext context) {
    final isPositive = stats.netFlow >= 0;
    final accent = isPositive
        ? const Color(0xFF0E9F6E)
        : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)]
              : [const Color(0xFFFEE2E2), const Color(0xFFFECACA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPositive ? 'Du sparst im Trend' : 'Ausgaben aktuell zu hoch',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatAmount(stats.netFlow),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Netto in ${selectedRange.label} (Einnahmen - Ausgaben)',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.stats});

  final _StatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 430;

        Widget pair(Widget left, Widget right) {
          if (isNarrow) {
            return Column(children: [left, const SizedBox(height: 10), right]);
          }

          return Row(
            children: [
              Expanded(child: left),
              const SizedBox(width: 10),
              Expanded(child: right),
            ],
          );
        }

        return Column(
          children: [
            pair(
              _StatTile(
                label: 'Einnahmen',
                value: _formatAmount(stats.totalIncome),
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFF16A34A),
              ),
              _StatTile(
                label: 'Ausgaben',
                value: _formatAmount(stats.totalExpenses),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 10),
            pair(
              _StatTile(
                label: 'Sparquote',
                value: '${stats.savingsRate.toStringAsFixed(1)}%',
                icon: Icons.savings_rounded,
                color: const Color(0xFF0EA5E9),
              ),
              _StatTile(
                label: 'Ausgaben / Tag',
                value: _formatAmount(stats.avgExpensePerDay),
                icon: Icons.calendar_view_day_rounded,
                color: const Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 10),
            pair(
              _StatTile(
                label: 'Groesste Ausgabe',
                value: _formatAmount(stats.maxExpenseAmount),
                subtitle: stats.maxExpenseTitle,
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFF59E0B),
              ),
              _StatTile(
                label: 'Aktive Tage',
                value: '${stats.activeDays}',
                subtitle: 'ausgabefrei: ${stats.currentNoSpendStreak} Tage',
                icon: Icons.today_rounded,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.stats});

  final _StatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    if (stats.weeklyExpenses.isEmpty) {
      return const _SimpleInfoCard(text: 'Noch keine Ausgaben im Zeitraum.');
    }

    final maxValue = stats.weeklyExpenses.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final chartHeight = (148 + ((textScale - 1) * 20).clamp(0.0, 20.0))
        .toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = 64.0;
                final chartWidth = math.max(
                  constraints.maxWidth,
                  stats.weeklyExpenses.length * itemWidth,
                );

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final entry in stats.weeklyExpenses.entries)
                          SizedBox(
                            width: itemWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  SizedBox(
                                    height: 16,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _formatCompact(entry.value),
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0,
                                        end: maxValue == 0
                                            ? 0.03
                                            : (entry.value / maxValue).clamp(
                                                0.03,
                                                1.0,
                                              ),
                                      ),
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, factor, child) {
                                        return Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            heightFactor: factor,
                                            widthFactor: 1,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    height: 16,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        entry.key,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Woechentliche Ausgaben in Balkenform, damit Trends schnell sichtbar sind.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.stats});

  final _StatsSnapshot stats;

  @override
  Widget build(BuildContext context) {
    if (stats.categoryExpenses.isEmpty) {
      return const _SimpleInfoCard(text: 'Noch keine Kategorien mit Ausgaben.');
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (final entry in stats.categoryExpenses.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BarRow(
                label: entry.key,
                amount: entry.value,
                percent: stats.totalExpenses == 0
                    ? 0
                    : (entry.value / stats.totalExpenses) * 100,
                color: categoryColors[entry.key] ?? const Color(0xFF64748B),
                icon: categoryIcons[entry.key] ?? Icons.category_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekdayPatternCard extends StatelessWidget {
  const _WeekdayPatternCard({required this.stats});

  final _StatsSnapshot stats;

  static const _weekdayNames = <int, String>{
    DateTime.monday: 'Mo',
    DateTime.tuesday: 'Di',
    DateTime.wednesday: 'Mi',
    DateTime.thursday: 'Do',
    DateTime.friday: 'Fr',
    DateTime.saturday: 'Sa',
    DateTime.sunday: 'So',
  };

  @override
  Widget build(BuildContext context) {
    if (stats.weekdayExpenses.isEmpty) {
      return const _SimpleInfoCard(
        text: 'Noch keine Ausgaben nach Wochentagen.',
      );
    }

    final maxValue = stats.weekdayExpenses.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (final weekday in [
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
            DateTime.saturday,
            DateTime.sunday,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BarRow(
                label: _weekdayNames[weekday]!,
                amount: stats.weekdayExpenses[weekday] ?? 0,
                percent: maxValue == 0
                    ? 0
                    : ((stats.weekdayExpenses[weekday] ?? 0) / maxValue) * 100,
                color: const Color(0xFF0EA5E9),
                icon: Icons.calendar_today_rounded,
                trailingAsRelative: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
    required this.icon,
    this.trailingAsRelative = false,
  });

  final String label;
  final double amount;
  final double percent;
  final Color color;
  final IconData icon;
  final bool trailingAsRelative;

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 100.0);

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      trailingAsRelative
                          ? '${clampedPercent.toStringAsFixed(0)}% vom Top-Tag'
                          : '${clampedPercent.toStringAsFixed(1)}%',
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: clampedPercent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 72),
          child: Text(
            _formatCompact(amount),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

class _SimpleInfoCard extends StatelessWidget {
  const _SimpleInfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

class _EmptyStatsState extends StatelessWidget {
  const _EmptyStatsState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_chart_outlined_rounded,
                size: 64,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 14),
              const Text(
                'Noch keine Daten fuer Statistik',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sobald du Transaktionen hinzufuegst, siehst du hier Trends, Kategorien und Sparquote.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

List<TransactionModel> _applyRangeFilter(
  List<TransactionModel> transactions,
  StatsRange range,
) {
  if (range == StatsRange.all) return transactions;

  final today = _dateOnly(DateTime.now());
  final minDate = switch (range) {
    StatsRange.last7Days => today.subtract(const Duration(days: 6)),
    StatsRange.last30Days => today.subtract(const Duration(days: 29)),
    StatsRange.last90Days => today.subtract(const Duration(days: 89)),
    StatsRange.all => today,
  };

  return transactions.where((t) {
    final date = _dateOnly(t.date);
    return !date.isBefore(minDate) && !date.isAfter(today);
  }).toList();
}

_StatsSnapshot _buildStats(List<TransactionModel> transactions) {
  final sorted = [...transactions]..sort((a, b) => a.date.compareTo(b.date));
  final expenses = sorted
      .where((t) => t.type == TransactionType.expense)
      .toList();
  final income = sorted.where((t) => t.type == TransactionType.income).toList();

  final totalIncome = income.fold<double>(0, (sum, t) => sum + t.amount);
  final totalExpenses = expenses.fold<double>(0, (sum, t) => sum + t.amount);
  final netFlow = totalIncome - totalExpenses;

  final firstDate = sorted.isEmpty ? null : _dateOnly(sorted.first.date);
  final lastDate = sorted.isEmpty ? null : _dateOnly(sorted.last.date);
  final daySpan = firstDate == null || lastDate == null
      ? 1
      : lastDate.difference(firstDate).inDays + 1;

  final avgExpensePerDay = totalExpenses / math.max(daySpan, 1);
  final savingsRate = totalIncome == 0 ? 0.0 : (netFlow / totalIncome) * 100;

  final categoryTotals = <String, double>{};
  final weekdayTotals = <int, double>{};
  final weeklyTotals = <DateTime, double>{};
  final activeDays = <DateTime>{};
  final expenseDays = <DateTime>{};

  for (final tx in sorted) {
    final date = _dateOnly(tx.date);
    activeDays.add(date);

    if (tx.type == TransactionType.expense) {
      expenseDays.add(date);
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
      weekdayTotals[date.weekday] =
          (weekdayTotals[date.weekday] ?? 0) + tx.amount;

      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      weeklyTotals[weekStart] = (weeklyTotals[weekStart] ?? 0) + tx.amount;
    }
  }

  final categoryEntries = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topCategory = categoryEntries.isEmpty
      ? null
      : categoryEntries.first.key;

  final topCategoriesLimited = Map<String, double>.fromEntries(
    categoryEntries.take(6),
  );

  final weeklyEntries = weeklyTotals.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final trimmedWeeks = weeklyEntries.length > 8
      ? weeklyEntries.sublist(weeklyEntries.length - 8)
      : weeklyEntries;

  final weeklyLabelMap = <String, double>{};
  for (final entry in trimmedWeeks) {
    final start = entry.key;
    final end = start.add(const Duration(days: 6));
    final label = '${start.day}.${start.month}-${end.day}.${end.month}';
    weeklyLabelMap[label] = entry.value;
  }

  final maxExpense = expenses.isEmpty
      ? null
      : expenses.reduce((a, b) => a.amount >= b.amount ? a : b);

  final currentNoSpendStreak = _calcCurrentNoSpendStreak(expenseDays);

  return _StatsSnapshot(
    transactionCount: sorted.length,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netFlow: netFlow,
    avgExpensePerDay: avgExpensePerDay,
    savingsRate: savingsRate,
    maxExpenseAmount: maxExpense?.amount ?? 0,
    maxExpenseTitle: maxExpense?.title ?? '-',
    activeDays: activeDays.length,
    currentNoSpendStreak: currentNoSpendStreak,
    topCategory: topCategory,
    categoryExpenses: topCategoriesLimited,
    weekdayExpenses: weekdayTotals,
    weeklyExpenses: weeklyLabelMap,
  );
}

int _calcCurrentNoSpendStreak(Set<DateTime> expenseDays) {
  var streak = 0;
  var cursor = _dateOnly(DateTime.now());

  while (!expenseDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
    if (streak > 4000) break;
  }

  return streak;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _formatAmount(double value) {
  final formatted = value.toStringAsFixed(2);
  final parts = formatted.split('.');
  var intPart = parts[0];
  final isNegative = intPart.startsWith('-');
  if (isNegative) intPart = intPart.substring(1);

  intPart = intPart.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]},',
  );

  return '${isNegative ? '-' : ''}€$intPart.${parts[1]}';
}

String _formatCompact(double value) {
  if (value.abs() >= 1000) {
    return '€${(value / 1000).toStringAsFixed(1)}k';
  }
  return '€${value.toStringAsFixed(0)}';
}

class _StatsSnapshot {
  const _StatsSnapshot({
    required this.transactionCount,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netFlow,
    required this.avgExpensePerDay,
    required this.savingsRate,
    required this.maxExpenseAmount,
    required this.maxExpenseTitle,
    required this.activeDays,
    required this.currentNoSpendStreak,
    required this.topCategory,
    required this.categoryExpenses,
    required this.weekdayExpenses,
    required this.weeklyExpenses,
  });

  final int transactionCount;
  final double totalIncome;
  final double totalExpenses;
  final double netFlow;
  final double avgExpensePerDay;
  final double savingsRate;
  final double maxExpenseAmount;
  final String maxExpenseTitle;
  final int activeDays;
  final int currentNoSpendStreak;
  final String? topCategory;
  final Map<String, double> categoryExpenses;
  final Map<int, double> weekdayExpenses;
  final Map<String, double> weeklyExpenses;
}
