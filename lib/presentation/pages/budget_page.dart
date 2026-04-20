import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgator/l10n/app_localizations.dart';
import '../../data/models/transaction_model.dart';
import '../../core/services/money_formatter.dart';
import '../theme/category_colors.dart';

import '../controllers/category_budget_provider.dart';
import '../controllers/savings_contribution_sync.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      applyDueSavingsContributions(ref);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetAndGoals),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.budgetsTab),
            Tab(text: l10n.savingsGoalsTab),
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
    final l10n = AppLocalizations.of(context)!;
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
                    Text(
                      l10n.categoriesTitle,
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
                        l10n.activeCount(categories.length),
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
                          l10n.noBudgetCategories,
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
              label: Text(l10n.createCategoryAction),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openSetTotalBudgetDialog(context, ref),
              icon: const Icon(Icons.edit_rounded),
              label: Text(l10n.editTotalBudgetAction),
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
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(monthlyTotalBudgetProvider);
    final controller = TextEditingController(
      text: current > 0 ? formatInputAmount(current) : '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.monthlyTotalBudgetChangeTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.totalBudgetLabel,
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
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final parsed = _parseMoney(controller.text);
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidPositiveAmountMessage)),
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
          title: Text(l10n.warningTitle),
          content: Text(
            l10n.budgetTooLowWarningMessage(
              formatEuroSmart(parsed),
              formatEuroSmart(totalAllocated),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.okAction),
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
    ).showSnackBar(SnackBar(content: Text(l10n.totalBudgetUpdated)));
  }

  Future<void> _openAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryBudget> categories,
    double monthlyBudget,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final allocController = TextEditingController();
    var selectedColor = selectableCategoryColors.first;
    var selectedIconKey = selectableCategoryIcons.keys.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newCategoryTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.categoryNameLabel,
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
                    labelText: l10n.budgetAllocationLabel,
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
                    l10n.colorLabel,
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
                    l10n.iconLabel,
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
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.addAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final name = nameController.text.trim();
    final allocAmount = _parseMoney(allocController.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.categoryNameRequired)));
      return;
    }

    if (allocAmount == null || allocAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.budgetMustBePositive)));
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
            l10n.budgetWouldBeExceededAvailable(
              formatEuroSmart(monthlyBudget - totalAllocated),
            ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.categoryAlreadyExists)));
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.categoryAdded)));
    setState(() {});
  }

  Future<void> _openEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryBudget category,
    List<CategoryBudget> categories,
    double monthlyBudget,
  ) async {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.editCategoryTitle(category.name)),
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
                  labelText: l10n.budgetAllocationLabel,
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
                  l10n.colorLabel,
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
                  l10n.iconLabel,
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
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('delete'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == 'delete') {
      ref.read(categoryBudgetProvider.notifier).deleteCategory(category.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.categoryDeleted)));
      setState(() {});
      return;
    }

    if (action == 'save') {
      final newAmount = _parseMoney(controller.text);
      if (newAmount == null || newAmount < 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidAmountGeneric)));
        return;
      }

      final otherAllocated = categories
          .where((c) => c.id != category.id)
          .fold<double>(0, (sum, cat) => sum + cat.monthlyLimit);

      if (otherAllocated + newAmount > monthlyBudget) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.budgetWouldBeExceededMax(
                formatEuroSmart(monthlyBudget - otherAllocated),
              ),
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
      ).showSnackBar(SnackBar(content: Text(l10n.categoryUpdated)));
      setState(() {});
    }
  }
}

class _SetupBudgetScreen extends ConsumerWidget {
  final VoidCallback onBudgetSet;

  const _SetupBudgetScreen({required this.onBudgetSet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.setupBudgetTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.setupBudgetDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showSetupDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.createMonthlyBudgetAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSetupDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.monthlyBudgetTitle),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.totalBudgetCurrentMonthLabel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.createAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final amount = _parseMoney(controller.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidPositiveAmountMessage)),
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
    final l10n = AppLocalizations.of(context)!;
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
                    Text(
                      l10n.monthlyBudgetLabel,
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
                  Text(l10n.spentLabel, style: const TextStyle(fontSize: 12)),
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
                l10n.allocatedLabel(formatEuroSmart(totalAllocated)),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                l10n.availableLabel(formatEuroSmart(availableToAllocate)),
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
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.noBudgetSet,
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
                  l10n.overrunByLabel(formatEuroSmart(-remaining)),
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
    final l10n = AppLocalizations.of(context)!;
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
                  goal == null
                      ? l10n.createSavingsGoalTitle
                      : l10n.editSavingsGoalTitle,
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: l10n.goalNameLabel,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: targetController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.goalAmountLabel,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: currentController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.alreadySavedLabel,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: monthlyController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.monthlyDeductionFormLabel,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: contributionDay,
                          decoration: InputDecoration(
                            labelText: l10n.debitDayLabel,
                          ),
                          items: monthlyContributionDayOptions
                              .map(
                                (day) => DropdownMenuItem<int>(
                                  value: day,
                                  child: Text(l10n.dayOfMonthLabel(day)),
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
                          title: Text(l10n.automationActive),
                          subtitle: Text(
                            l10n.automaticMonthlyDeductionSubtitle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.colorLabel,
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
                      child: Text(l10n.delete),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop('cancel'),
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop('save'),
                    child: Text(l10n.save),
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
        ).showSnackBar(SnackBar(content: Text(l10n.savingsGoalDeleted)));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.enterValidValuesMessage)));
        return;
      }

      if (current > target) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.savedCannotExceedTarget)));
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
        ).showSnackBar(SnackBar(content: Text(l10n.savingsGoalCreated)));
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
        ).showSnackBar(SnackBar(content: Text(l10n.savingsGoalUpdated)));
      }
    }

    Future<void> addManualContribution(SavingsGoal goal) async {
      final controller = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.depositIntoGoalTitle(goal.name)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.paidAmountLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.depositAction),
            ),
          ],
        ),
      );

      if (ok != true || !context.mounted) return;

      final amount = _parseMoney(controller.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidAmountMessage)));
        return;
      }

      final applied = ref
          .read(savingsGoalProvider.notifier)
          .addCurrentToGoal(goal.id, amount);
      if (applied <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.goalAlreadyReached)));
        return;
      }

      ref
          .read(transactionsProvider.notifier)
          .add(
            TransactionModel(
              title: l10n.goalDepositTransactionTitle(goal.name),
              amount: applied,
              date: DateTime.now(),
              category: 'Sparziel',
              type: TransactionType.expense,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.depositedAmountMessage(formatEuroSmart(applied))),
        ),
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
              label: Text(l10n.newSavingsGoalAction),
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
                  l10n.noSavingsGoalsHint,
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
                          l10n.currentOfTarget(
                            formatEuroSmart(goal.current),
                            formatEuroSmart(goal.target),
                          ),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.monthlyDeductionValue(
                            formatEuroSmart(goal.monthlyContribution),
                          ),
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.debitDayValue(goal.contributionDay),
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => addManualContribution(goal),
                                icon: const Icon(Icons.add_card_rounded),
                                label: Text(l10n.depositShortAction),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => openGoalDialog(goal: goal),
                                icon: const Icon(Icons.edit_rounded),
                                label: Text(l10n.editShortAction),
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
