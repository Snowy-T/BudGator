import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';

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
                    TextButton.icon(
                      onPressed: () => _openEditBudgetDialog(context, ref),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Bearbeiten'),
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
                      final isOver = spent > category.monthlyLimit;

                      return _CategoryAllocationCard(
                        name: category.name,
                        allocated: category.monthlyLimit,
                        spent: spent,
                        isOver: isOver,
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
      text: current > 0 ? current.toStringAsFixed(0) : '',
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
            'Das neue Budget (€${parsed.toStringAsFixed(0)}) ist kleiner als die bereits verteilten Kategorien (€${totalAllocated.toStringAsFixed(0)}).\n\nBitte passen Sie die Kategorien an.',
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Kategorie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Kategoriename',
                hintText: 'z.B. Lebensmittel',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: allocController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Budget-Zuweisung',
                hintText: 'z.B. 300',
              ),
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
            'Budget würde überschritten. Verfügbar: €${(monthlyBudget - totalAllocated).toStringAsFixed(0)}',
          ),
        ),
      );
      return;
    }

    final added = ref
        .read(categoryBudgetProvider.notifier)
        .addCategory(name, monthlyLimit: allocAmount);

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
      text: category.monthlyLimit.toStringAsFixed(0),
    );

    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${category.name} bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Budget-Zuweisung'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
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
              'Budget würde überschritten. Max: €${(monthlyBudget - otherAllocated).toStringAsFixed(0)}',
            ),
          ),
        );
        return;
      }

      ref
          .read(categoryBudgetProvider.notifier)
          .setLimit(category.id, newAmount);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategorie aktualisiert')));
      setState(() {});
    }
  }

  Future<void> _openEditBudgetDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final monthlyBudget = ref.read(monthlyTotalBudgetProvider);
    final categories = ref.read(categoryBudgetProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budget übersicht'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gesamtbudget: €${monthlyBudget.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            Text('Kategorien (${categories.length}):'),
            const SizedBox(height: 8),
            ...categories
                .take(5)
                .map(
                  (cat) => Text(
                    '  • ${cat.name}: €${cat.monthlyLimit.toStringAsFixed(0)}',
                  ),
                ),
            if (categories.length > 5)
              Text('  ... und ${categories.length - 5} weitere'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                      '€${totalMonthlyBudget.toStringAsFixed(0)}',
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
                    '€${totalSpent.toStringAsFixed(0)}',
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
                'Verteilt: €${totalAllocated.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Verfügbar: €${availableToAllocate.toStringAsFixed(0)}',
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
  final VoidCallback onTap;

  const _CategoryAllocationCard({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.isOver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
    final remaining = allocated - spent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOver ? Colors.red.shade200 : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '€${spent.toStringAsFixed(0)} / €${allocated.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOver ? Colors.red : colorScheme.onSurfaceVariant,
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
                valueColor: AlwaysStoppedAnimation(
                  isOver ? Colors.red.shade500 : Colors.orange.shade400,
                ),
              ),
            ),
            if (remaining < 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Überschritten um €${(-remaining).toStringAsFixed(0)}',
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
    return const Center(child: Text('Sparziele werden hier angezeigt'));
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
