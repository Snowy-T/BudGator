import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../core/services/money_formatter.dart';
import '../theme/category_colors.dart';

import '../controllers/category_budget_provider.dart';
import '../controllers/savings_goal_provider.dart';
import '../controllers/transaction_provider.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final applied = ref
          .read(savingsGoalProvider.notifier)
          .applyMonthlyContributionIfDue();

      bool hasMonthlyTx(String goalName, List<TransactionModel> txs) {
        return txs.any(
          (tx) =>
              tx.type == TransactionType.expense &&
              tx.category == 'Sparziel' &&
              tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.title == '$goalName-Monatsbeitrag',
        );
      }

      for (final item in applied) {
        final txs = ref.read(transactionsProvider);
        if (hasMonthlyTx(item.goalName, txs)) continue;

        ref
            .read(transactionsProvider.notifier)
            .add(
              TransactionModel(
                title: '${item.goalName}-Monatsbeitrag',
                amount: item.amount,
                date: now,
                category: 'Sparziel',
                type: TransactionType.expense,
              ),
            );
      }

      final goals = ref.read(savingsGoalProvider);
      for (final goal in goals) {
        if (!goal.isActive ||
            goal.monthlyContribution <= 0 ||
            goal.lastAutoContributionMonth != _monthKey(now)) {
          continue;
        }

        final txs = ref.read(transactionsProvider);
        if (hasMonthlyTx(goal.name, txs)) continue;

        ref
            .read(transactionsProvider.notifier)
            .add(
              TransactionModel(
                title: '${goal.name}-Monatsbeitrag',
                amount: goal.monthlyContribution,
                date: now,
                category: 'Sparziel',
                type: TransactionType.expense,
              ),
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Sparziele'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Budgets'),
            Tab(text: 'Sparziele'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_BudgetTab(), _SavingsGoalsTab()],
      ),
    );
  }
}

class _BudgetTab extends ConsumerStatefulWidget {
  const _BudgetTab();

  @override
  ConsumerState<_BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends ConsumerState<_BudgetTab> {
  @override
  Widget build(BuildContext context) {
    final monthlyBudget = ref.watch(monthlyTotalBudgetProvider);
    final categories = ref.watch(categoryBudgetProvider);
    final transactions = ref.watch(transactionsProvider);

    // Wenn kein Monatsbudget, zeige Setup-Screen
    if (monthlyBudget <= 0) {
      return _SetupBudgetScreen(
        onBudgetSet: () {
          setState(() {});
        },
      );
    }

    // Berechne aktuelle Ausgaben pro Kategorie (nur für diesen Monat)
    final now = DateTime.now();
    final monthExpenses = <String, double>{};
    for (final tx in transactions) {
      if (tx.type == TransactionType.expense &&
          tx.date.year == now.year &&
          tx.date.month == now.month &&
          tx.category != 'Sparziel') {
        monthExpenses[tx.category] =
            (monthExpenses[tx.category] ?? 0) + tx.amount;
      }
    }

    // Berechne Gesamtbudget, das auf Kategorien verteilt ist
    final totalAllocated = categories.fold<double>(
      0,
      (sum, cat) => sum + cat.monthlyLimit,
    );
    final availableToAllocate = monthlyBudget - totalAllocated;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Monatsbudget Header
            _MonthlyBudgetOverviewCard(
              totalMonthlyBudget: monthlyBudget,
              totalAllocated: totalAllocated,
              totalSpent: monthExpenses.values.fold(0, (a, b) => a + b),
              availableToAllocate: availableToAllocate,
            ),
            const SizedBox(height: 20),

            // Kategorien Liste
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kategorien',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${categories.length} aktiv',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (categories.isEmpty)
                  Builder(
                    builder: (context) {
                      final colorScheme = Theme.of(context).colorScheme;
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          'Keine Kategorien mit Budget vorhanden',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    },
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final spent = monthExpenses[category.name] ?? 0;
                      final hasAssignedBudget = category.monthlyLimit > 0;
                      final isOver =
                          hasAssignedBudget && spent > category.monthlyLimit;

                      return _CategoryAllocationCard(
                        name: category.name,
                        allocated: category.monthlyLimit,
                        spent: spent,
                        isOver: isOver,
                        isUnassigned: !hasAssignedBudget,
                        color: category.colorValue != null
                            ? Color(category.colorValue!)
                            : (categoryColors[category.name] ??
                                  Theme.of(context).colorScheme.primary),
                        icon: iconForKey(
                          category.iconKey,
                          fallback:
                              categoryIcons[category.name] ??
                              Icons.category_rounded,
                        ),
                        onTap: () => _openEditCategoryDialog(
                          context,
                          ref,
                          category,
                          categories,
                          monthlyBudget,
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons
            FilledButton.icon(
              onPressed: () => _openAddCategoryDialog(
                context,
                ref,
                categories,
                monthlyBudget,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Kategorie hinzufüggen'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openSetTotalBudgetDialog(context, ref),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Gesamtbudget ändern'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSetTotalBudgetDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final current = ref.read(monthlyTotalBudgetProvider);
    final controller = TextEditingController(
      text: current > 0 ? formatInputAmount(current) : '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monatliches Gesamtbudget ändern'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Gesamtbudget',
              hintText: 'z.B. 1800',
              prefixIcon: const Icon(Icons.wallet_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
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
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final parsed = _parseMoney(controller.text);
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte einen gültigen Betrag (> 0) eingeben.'),
        ),
      );
      return;
    }

    // Warnung wenn neues Budget kleiner als bereits verteilt
    final categories = ref.read(categoryBudgetProvider);
    final totalAllocated = categories.fold<double>(
      0,
      (sum, cat) => sum + cat.monthlyLimit,
    );
    if (parsed < totalAllocated) {
      if (!context.mounted) return;
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Warnung'),
          content: Text(
            'Das neue Budget (${formatEuroSmart(parsed)}) ist kleiner als die bereits verteilten Kategorien (${formatEuroSmart(totalAllocated)}).\n\nBitte passen Sie die Kategorien an.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    ref
        .read(monthlyTotalBudgetProvider.notifier)
        .setBudgetForCurrentMonth(parsed);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gesamtbudget aktualisiert')));
  }

  Future<void> _openAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryBudget> categories,
    double monthlyBudget,
  ) async {
    final nameController = TextEditingController();
    final allocController = TextEditingController();
    var selectedColor = selectableCategoryColors.first;
    var selectedIconKey = selectableCategoryIcons.keys.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Kategorie'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Kategoriename',
                    hintText: 'z.B. Lebensmittel',
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: allocController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Budget-Zuweisung',
                    hintText: 'z.B. 300',
                    prefixIcon: const Icon(Icons.euro_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Farbe',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setLocalState) => _ColorPickerWrap(
                    selectedColor: selectedColor,
                    onColorSelected: (color) {
                      setLocalState(() => selectedColor = color);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Icon',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setLocalState) => _IconPickerGrid(
                    selectedIconKey: selectedIconKey,
                    onIconSelected: (iconKey) {
                      setLocalState(() => selectedIconKey = iconKey);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hinzufüggen'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final name = nameController.text.trim();
    final allocAmount = _parseMoney(allocController.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategoriename ist erforderlich')),
      );
      return;
    }

    if (allocAmount == null || allocAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget muss > 0 sein')));
      return;
    }

    final totalAllocated = categories.fold<double>(
      0,
      (sum, cat) => sum + cat.monthlyLimit,
    );
    if (totalAllocated + allocAmount > monthlyBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Budget würde überschritten. Verfügbar: ${formatEuroSmart(monthlyBudget - totalAllocated)}',
          ),
        ),
      );
      return;
    }

    final added = ref
        .read(categoryBudgetProvider.notifier)
        .addCategory(
          name,
          monthlyLimit: allocAmount,
          colorValue: selectedColor.toARGB32(),
          iconKey: selectedIconKey,
        );

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategorie existiert bereits')),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kategorie hinzugefügt')));
    setState(() {});
  }

  Future<void> _openEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryBudget category,
    List<CategoryBudget> categories,
    double monthlyBudget,
  ) async {
    final controller = TextEditingController(
      text: formatInputAmount(category.monthlyLimit),
    );
    var selectedColor = category.colorValue != null
        ? Color(category.colorValue!)
        : (categoryColors[category.name] ?? selectableCategoryColors.first);
    var selectedIconKey =
        category.iconKey ?? selectableCategoryIcons.keys.first;

    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${category.name} bearbeiten'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Budget-Zuweisung',
                  prefixIcon: const Icon(Icons.euro_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Farbe',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setLocalState) => _ColorPickerWrap(
                  selectedColor: selectedColor,
                  onColorSelected: (color) {
                    setLocalState(() => selectedColor = color);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Icon',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setLocalState) => _IconPickerGrid(
                  selectedIconKey: selectedIconKey,
                  onIconSelected: (iconKey) {
                    setLocalState(() => selectedIconKey = iconKey);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('delete'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == 'delete') {
      ref.read(categoryBudgetProvider.notifier).deleteCategory(category.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategorie gelöscht')));
      setState(() {});
      return;
    }

    if (action == 'save') {
      final newAmount = _parseMoney(controller.text);
      if (newAmount == null || newAmount < 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ungültiger Betrag')));
        return;
      }

      final otherAllocated = categories
          .where((c) => c.id != category.id)
          .fold<double>(0, (sum, cat) => sum + cat.monthlyLimit);

      if (otherAllocated + newAmount > monthlyBudget) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Budget würde überschritten. Max: ${formatEuroSmart(monthlyBudget - otherAllocated)}',
            ),
          ),
        );
        return;
      }

      ref
          .read(categoryBudgetProvider.notifier)
          .setLimit(category.id, newAmount);
      ref
          .read(categoryBudgetProvider.notifier)
          .updateStyle(
            id: category.id,
            colorValue: selectedColor.toARGB32(),
            iconKey: selectedIconKey,
          );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategorie aktualisiert')));
      setState(() {});
    }
  }
}

class _SetupBudgetScreen extends ConsumerWidget {
  final VoidCallback onBudgetSet;

  const _SetupBudgetScreen({required this.onBudgetSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wallet_rounded,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            const Text(
              'Budget einrichten',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Um Ausgaben zu verwalten, richten Sie zunächst ein monatliches Gesamtbudget ein. Sie können dann Kategorien erstellen und den Betrag zwischen ihnen verteilen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showSetupDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Monatsbudget erstellen'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetupDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monatsbudget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Gesamtbudget für diesen Monat',
            hintText: 'z.B. 1800',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final amount = _parseMoney(controller.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte einen gütigen Betrag (> 0) eingeben'),
        ),
      );
      return;
    }

    ref
        .read(monthlyTotalBudgetProvider.notifier)
        .setBudgetForCurrentMonth(amount);
    onBudgetSet();
  }
}

class _MonthlyBudgetOverviewCard extends StatelessWidget {
  final double totalMonthlyBudget;
  final double totalAllocated;
  final double totalSpent;
  final double availableToAllocate;

  const _MonthlyBudgetOverviewCard({
    required this.totalMonthlyBudget,
    required this.totalAllocated,
    required this.totalSpent,
    required this.availableToAllocate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalAllocated > 0
        ? (totalSpent / totalAllocated).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = totalSpent > totalAllocated;
    final color = isOverBudget ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? (isDark
                    ? [const Color(0xFF5F1F1A), const Color(0xFF7F2725)]
                    : [const Color(0xFFFFECEC), const Color(0xFFFFF8F2)])
              : (isDark
                    ? [const Color(0xFF064E3B), const Color(0xFF0D5E45)]
                    : [const Color(0xFFE9FDF5), const Color(0xFFF4FFF9)]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget
              ? (isDark
                    ? const Color(0xFFEF4444).withValues(alpha: 0.38)
                    : Colors.red.shade200)
              : (isDark
                    ? const Color(0xFF10B981).withValues(alpha: 0.38)
                    : Colors.green.shade200),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: color.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monatsbudget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatEuroSmart(totalMonthlyBudget),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Ausgegeben', style: TextStyle(fontSize: 12)),
                  Text(
                    formatEuroSmart(totalSpent),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color.shade400),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verteilt: ${formatEuroSmart(totalAllocated)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Verfügbar: ${formatEuroSmart(availableToAllocate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: availableToAllocate < 0 ? Colors.red : Colors.green,
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

class _CategoryAllocationCard extends StatelessWidget {
  final String name;
  final double allocated;
  final double spent;
  final bool isOver;
  final bool isUnassigned;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryAllocationCard({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.isOver,
    required this.isUnassigned,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
    final remaining = allocated - spent;
    final statusColor = isUnassigned
        ? Colors.blue.shade500
        : (isOver ? Colors.red.shade500 : color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnassigned
                ? Colors.blue.shade200
                : (isOver ? Colors.red.shade200 : colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${formatEuroSmart(spent)} / ${formatEuroSmart(allocated)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnassigned
                        ? Colors.blue.shade700
                        : (isOver ? Colors.red : colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: progress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            if (isUnassigned)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Kein Budget gesetzt',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (remaining < 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Überschritten um ${formatEuroSmart(-remaining)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SavingsGoalsTab extends ConsumerWidget {
  const _SavingsGoalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalProvider);
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> openGoalDialog({SavingsGoal? goal}) async {
      final nameController = TextEditingController(text: goal?.name ?? '');
      final targetController = TextEditingController(
        text: goal == null ? '' : formatInputAmount(goal.target),
      );
      final currentController = TextEditingController(
        text: goal == null ? '' : formatInputAmount(goal.current),
      );
      final monthlyController = TextEditingController(
        text: goal == null ? '' : formatInputAmount(goal.monthlyContribution),
      );
      var contributionDay =
          goal?.contributionDay ?? monthlyContributionDayOptions.first;
      var selectedColor = goal?.colorValue != null
          ? Color(goal!.colorValue!)
          : selectableCategoryColors.first;
      var isActive = goal?.isActive ?? true;

      final action = await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setLocalState) {
              return AlertDialog(
                title: Text(
                  goal == null ? 'Sparziel erstellen' : 'Sparziel bearbeiten',
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'z.B. Notgroschen',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: targetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Zielbetrag',
                            hintText: 'z.B. 5000',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: currentController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Bereits gespart',
                            hintText: 'z.B. 600',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: monthlyController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Monatlicher Abzug',
                            hintText: 'z.B. 150',
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: contributionDay,
                          decoration: const InputDecoration(
                            labelText: 'Abbuchungstag',
                          ),
                          items: monthlyContributionDayOptions
                              .map(
                                (day) => DropdownMenuItem<int>(
                                  value: day,
                                  child: Text('$day. des Monats'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setLocalState(() => contributionDay = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isActive,
                          onChanged: (value) =>
                              setLocalState(() => isActive = value),
                          title: const Text('Automatik aktiv'),
                          subtitle: const Text(
                            'Monatlichen Abzug automatisch verbuchen',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Farbe',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ColorPickerWrap(
                          selectedColor: selectedColor,
                          onColorSelected: (color) {
                            setLocalState(() => selectedColor = color);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  if (goal != null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop('delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                      child: const Text('Löschen'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop('cancel'),
                    child: const Text('Abbrechen'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop('save'),
                    child: const Text('Speichern'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (action == null || action == 'cancel' || !context.mounted) return;

      if (action == 'delete' && goal != null) {
        ref.read(savingsGoalProvider.notifier).deleteGoal(goal.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sparziel gelöscht')));
        return;
      }

      final name = nameController.text.trim();
      final target = _parseMoney(targetController.text);
      final current = _parseMoney(currentController.text) ?? 0;
      final monthly = _parseMoney(monthlyController.text) ?? 0;

      if (name.isEmpty ||
          target == null ||
          target <= 0 ||
          current < 0 ||
          monthly < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte valide Werte eingeben.')),
        );
        return;
      }

      if (current > target) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bereits gespart darf Ziel nicht überschreiten.'),
          ),
        );
        return;
      }

      if (goal == null) {
        ref
            .read(savingsGoalProvider.notifier)
            .addGoal(
              name: name,
              target: target,
              current: current,
              monthlyContribution: monthly,
              isActive: isActive,
              colorValue: selectedColor.toARGB32(),
              contributionDay: contributionDay,
            );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sparziel erstellt')));
      } else {
        ref
            .read(savingsGoalProvider.notifier)
            .updateGoal(
              id: goal.id,
              name: name,
              target: target,
              current: current,
              monthlyContribution: monthly,
              isActive: isActive,
              colorValue: selectedColor.toARGB32(),
              contributionDay: contributionDay,
            );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sparziel aktualisiert')));
      }
    }

    Future<void> addManualContribution(SavingsGoal goal) async {
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('In ${goal.name} einzahlen'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Betrag',
              hintText: 'z.B. 100',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Einzahlen'),
            ),
          ],
        ),
      );

      if (ok != true || !context.mounted) return;

      final amount = _parseMoney(controller.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte gültigen Betrag eingeben.')),
        );
        return;
      }

      final applied = ref
          .read(savingsGoalProvider.notifier)
          .addCurrentToGoal(goal.id, amount);
      if (applied <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ziel ist bereits voll erreicht.')),
        );
        return;
      }

      ref
          .read(transactionsProvider.notifier)
          .add(
            TransactionModel(
              title: '${goal.name}-Einzahlung',
              amount: applied,
              date: DateTime.now(),
              category: 'Sparziel',
              type: TransactionType.expense,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${formatEuroSmart(applied)} eingezahlt')),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () => openGoalDialog(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Neues Sparziel'),
            ),
            const SizedBox(height: 14),
            if (goals.isEmpty)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  'Noch keine Sparziele. Lege ein Ziel mit monatlichem Abzug an.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progress = goal.target <= 0
                      ? 0.0
                      : (goal.current / goal.target).clamp(0.0, 1.0);
                  final accent = goal.colorValue != null
                      ? Color(goal.colorValue!)
                      : const Color(0xFF16A34A);

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.savings_rounded,
                                color: accent,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                goal.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Switch(
                              value: goal.isActive,
                              onChanged: (_) {
                                ref
                                    .read(savingsGoalProvider.notifier)
                                    .toggleActive(goal.id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 9,
                            value: progress,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(accent),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${formatEuroSmart(goal.current)} von ${formatEuroSmart(goal.target)}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monatlicher Abzug: ${formatEuroSmart(goal.monthlyContribution)}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Abbuchung: ${goal.contributionDay}. des Monats',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => addManualContribution(goal),
                                icon: const Icon(Icons.add_card_rounded),
                                label: const Text('Einzahlen'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => openGoalDialog(goal: goal),
                                icon: const Icon(Icons.edit_rounded),
                                label: const Text('Bearbeiten'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerWrap extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerWrap({
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final color in selectableCategoryColors)
          GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedColor.toARGB32() == color.toARGB32()
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: selectedColor.toARGB32() == color.toARGB32()
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

class _IconPickerGrid extends StatelessWidget {
  final String selectedIconKey;
  final ValueChanged<String> onIconSelected;

  const _IconPickerGrid({
    required this.selectedIconKey,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final keys = selectableCategoryIcons.keys.toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final key in keys)
          GestureDetector(
            onTap: () => onIconSelected(key),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selectedIconKey == key
                    ? colorScheme.primary.withValues(alpha: 0.16)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedIconKey == key
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Icon(
                selectableCategoryIcons[key],
                size: 18,
                color: selectedIconKey == key
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

double? _parseMoney(String value) {
  try {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final cleaned = trimmed.replaceAll(' ', '').replaceAll(',', '.');
    return double.parse(cleaned);
  } catch (e) {
    return null;
  }
}
