import 'dart:math' as math;

import 'package:budgator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/money_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../controllers/transaction_provider.dart';
import '../theme/category_colors.dart';

enum StatsRange { last7Days, last30Days, last90Days, all }

extension _StatsRangeLabel on StatsRange {
  String label(AppLocalizations l10n) {
    switch (this) {
      case StatsRange.last7Days:
        return l10n.range7Days;
      case StatsRange.last30Days:
        return l10n.range30Days;
      case StatsRange.last90Days:
        return l10n.range90Days;
      case StatsRange.all:
        return l10n.rangeAll;
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final transactions = ref.watch(transactionsProvider);
    final filtered = _applyRangeFilter(transactions, _selectedRange);
    final stats = _buildStats(filtered, l10n);

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
                  Text(
                    l10n.statsTitle,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.statsBookingsInRange(stats.transactionCount),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final range in StatsRange.values)
                        ChoiceChip(
                          label: Text(range.label(l10n)),
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
                _SectionTitle(l10n.coreMetrics),
                const SizedBox(height: 10),
                _KpiGrid(stats: stats),
                const SizedBox(height: 20),
                _SectionTitle(l10n.weeklyTrend),
                const SizedBox(height: 10),
                _WeeklyTrendCard(stats: stats),
                const SizedBox(height: 20),
                _SectionTitle(l10n.categoryBreakdown),
                const SizedBox(height: 10),
                _CategoryBreakdownCard(stats: stats),
                const SizedBox(height: 20),
                _SectionTitle(l10n.weekdayPattern),
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              ? (isDark
                    ? [const Color(0xFF064E3B), const Color(0xFF0D9488)]
                    : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)])
              : (isDark
                    ? [const Color(0xFF5F1F1A), const Color(0xFF7F1D1B)]
                    : [const Color(0xFFFEE2E2), const Color(0xFFFECACA)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isPositive
              ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.42 : 0.24)
              : const Color(0xFFEF4444).withValues(alpha: isDark ? 0.42 : 0.24),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPositive ? l10n.statsPositiveTrend : l10n.statsNegativeTrend,
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
            l10n.netInRangeLabel(selectedRange.label(l10n)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
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
    final l10n = AppLocalizations.of(context)!;
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
                label: l10n.incomeLabel,
                value: _formatAmount(stats.totalIncome),
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFF16A34A),
              ),
              _StatTile(
                label: l10n.expensesLabel,
                value: _formatAmount(stats.totalExpenses),
                icon: Icons.arrow_upward_rounded,
                color: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 10),
            pair(
              _StatTile(
                label: l10n.savingsRateLabel,
                value: '${stats.savingsRate.toStringAsFixed(1)}%',
                icon: Icons.savings_rounded,
                color: const Color(0xFF0EA5E9),
              ),
              _StatTile(
                label: l10n.expensesPerDayLabel,
                value: _formatAmount(stats.avgExpensePerDay),
                icon: Icons.calendar_view_day_rounded,
                color: const Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(height: 10),
            pair(
              _StatTile(
                label: l10n.largestExpenseLabel,
                value: _formatAmount(stats.maxExpenseAmount),
                subtitle: stats.maxExpenseTitle,
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFF59E0B),
              ),
              _StatTile(
                label: l10n.activeDaysLabel,
                value: '${stats.activeDays}',
                subtitle: l10n.noExpenseStreakLabel(stats.currentNoSpendStreak),
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
    final l10n = AppLocalizations.of(context)!;
    if (stats.weeklyExpenses.isEmpty) {
      return _SimpleInfoCard(text: l10n.noExpensesInRange);
    }

    final values = stats.weeklyExpenses.values.toList();
    final labels = stats.weeklyExpenses.keys.toList();
    final maxValue = values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final avgValue =
        values.fold<double>(0, (sum, v) => sum + v) / values.length;
    final trend = values.length < 2
        ? 0.0
        : values.last - values[values.length - 2];
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final chartHeight = (148 + ((textScale - 1) * 20).clamp(0.0, 20.0))
        .toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                label: l10n.statsTitle,
                value: _formatCompact(maxValue),
                color: const Color(0xFF10B981),
              ),
              _MiniPill(
                label: l10n.weeklyAverageLabel,
                value: _formatCompact(avgValue),
                color: const Color(0xFF0EA5E9),
              ),
              _MiniPill(
                label: l10n.trendLabel,
                value: '${trend >= 0 ? '+' : ''}${_formatCompact(trend)}',
                color: trend <= 0
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: chartHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = 64.0;
                final chartWidth = math.max(
                  constraints.maxWidth,
                  values.length * itemWidth,
                );

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Divider(height: 1),
                              Divider(height: 1),
                              Divider(height: 1),
                              Divider(height: 1),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List<Widget>.generate(values.length, (i) {
                            return SizedBox(
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
                                          _formatCompact(values[i]),
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
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
                                              : (values[i] / maxValue).clamp(
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
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF34D399),
                                                Color(0xFF059669),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
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
                                          labels[i],
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
                            );
                          }),
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
            l10n.weeklyBarsHint,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
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
    final l10n = AppLocalizations.of(context)!;
    if (stats.categoryExpenses.isEmpty) {
      return _SimpleInfoCard(text: l10n.noCategoryExpenses);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          for (final entry in stats.categoryExpenses.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BarRow(
                label: _localizedCategoryLabel(entry.key, l10n),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (stats.weekdayExpenses.isEmpty) {
      return _SimpleInfoCard(text: l10n.noWeekdayExpenses);
    }

    final maxValue = stats.weekdayExpenses.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final sorted = stats.weekdayExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dayOrder = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];
    final rankByDay = <int, int>{};
    for (var i = 0; i < sorted.length; i++) {
      rankByDay[sorted[i].key] = i + 1;
    }
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in dayOrder)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WeekdayRankRow(
                label: _weekdayLabel(day, locale),
                amount: stats.weekdayExpenses[day] ?? 0,
                rank: rankByDay[day] ?? 7,
                maxValue: maxValue,
              ),
            ),
          Text(
            l10n.highestExpenseDayHint,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdayLabel(int weekday, String localeTag) {
  final date = DateTime(2024, 1, weekday);
  return DateFormat.E(localeTag).format(date);
}

class _WeekdayRankRow extends StatelessWidget {
  final String label;
  final double amount;
  final int rank;
  final double maxValue;

  const _WeekdayRankRow({
    required this.label,
    required this.amount,
    required this.rank,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final intensity = maxValue <= 0 ? 0.0 : (amount / maxValue).clamp(0.0, 1.0);
    final heatColor = Color.lerp(
      colorScheme.surfaceContainerHighest,
      colorScheme.primary,
      intensity,
    )!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: heatColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$rank',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            formatEuroSmart(amount),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
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
  });

  final String label;
  final double amount;
  final double percent;
  final Color color;
  final IconData icon;

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
                      '${clampedPercent.toStringAsFixed(1)}%',
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
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
      decoration: _cardDecoration(context),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
      decoration: _cardDecoration(context),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
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
    final l10n = AppLocalizations.of(context)!;
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.statsEmptyTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.statsEmptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: colorScheme.outlineVariant),
    boxShadow: [
      BoxShadow(
        color: colorScheme.shadow.withValues(alpha: 0.12),
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

_StatsSnapshot _buildStats(
  List<TransactionModel> transactions,
  AppLocalizations l10n,
) {
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
  var weekCounter = 1;
  for (final entry in trimmedWeeks) {
    final label = l10n.weekLabelPrefix(weekCounter);
    weeklyLabelMap[label] = entry.value;
    weekCounter++;
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

String _localizedCategoryLabel(String key, AppLocalizations l10n) {
  switch (key) {
    case 'General':
      return l10n.categoryGeneral;
    case 'Entertainment':
    case 'Unterhaltung':
      return l10n.categoryEntertainment;
    case 'Cafe':
      return l10n.categoryCafe;
    default:
      return key;
  }
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
  return formatEuroSmart(value);
}

String _formatCompact(double value) {
  if (value.abs() >= 1000) {
    return '${formatEuroSmart(value / 1000)}k';
  }
  return formatEuroSmart(value);
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
