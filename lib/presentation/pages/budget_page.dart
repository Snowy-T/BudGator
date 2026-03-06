import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/category_budget_provider.dart';
import '../controllers/savings_goal_provider.dart';

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

class _BudgetTab extends ConsumerWidget {
  const _BudgetTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressList = ref.watch(categoryBudgetProgressProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Setze Monatslimits pro Kategorie, z.B. Essen 200 EUR.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _openAddCategoryDialog(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Kategorie'),
              ),
            ],
          ),
        ),
        Expanded(
          child: progressList.isEmpty
              ? const Center(child: Text('Noch keine Kategorien vorhanden.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: progressList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = progressList[index];
                    return _BudgetCategoryCard(item: item);
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final limitController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategorie hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: limitController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monatslimit (optional)',
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
            child: const Text('Hinzufugen'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final limit = _parseMoney(limitController.text) ?? 0;
    ref
        .read(categoryBudgetProvider.notifier)
        .addCategory(nameController.text, monthlyLimit: limit);
  }
}

class _BudgetCategoryCard extends ConsumerWidget {
  const _BudgetCategoryCard({required this.item});

  final CategoryBudgetProgress item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = item.budget;
    final progress = budget.monthlyLimit <= 0
        ? 0.0
        : (item.spent / budget.monthlyLimit).clamp(0.0, 1.0);

    Color statusColor;
    if (item.isOverLimit) {
      statusColor = Colors.red;
    } else if (item.isNearLimit) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Kategorie loschen',
                onPressed: () => ref
                    .read(categoryBudgetProvider.notifier)
                    .deleteCategory(budget.id),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ausgegeben: ${_formatEuro(item.spent)}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              Text(
                budget.monthlyLimit <= 0
                    ? 'Kein Limit'
                    : 'Rest: ${_formatEuro(item.remaining)}',
                style: TextStyle(
                  color: budget.monthlyLimit <= 0
                      ? Colors.grey.shade700
                      : statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: statusColor,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openSetLimitDialog(context, ref, budget),
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(
                    budget.monthlyLimit > 0
                        ? 'Limit: ${_formatEuro(budget.monthlyLimit)}'
                        : 'Limit setzen',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openSetLimitDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryBudget budget,
  ) async {
    final controller = TextEditingController(
      text: budget.monthlyLimit > 0
          ? budget.monthlyLimit.toStringAsFixed(0)
          : '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limit fur ${budget.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monatslimit',
            hintText: 'z.B. 200',
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
    if (parsed == null || parsed < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte einen gultigen Betrag eingeben.')),
      );
      return;
    }

    ref.read(categoryBudgetProvider.notifier).setLimit(budget.id, parsed);
  }
}

class _SavingsGoalsTab extends ConsumerWidget {
  const _SavingsGoalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(savingsGoalProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Lege mehrere Sparziele an oder auch gar keins.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openAddGoalDialog(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Sparziel'),
              ),
            ],
          ),
        ),
        Expanded(
          child: goals.isEmpty
              ? const Center(child: Text('Keine Sparziele angelegt.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: goals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _SavingsGoalCard(goal: goals[index]);
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _openAddGoalDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final monthlyController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues Sparziel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Zielbetrag'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: monthlyController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monatlich sparen',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Anlegen'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final target = _parseMoney(targetController.text);
    final monthly = _parseMoney(monthlyController.text) ?? 0;
    if (nameController.text.trim().isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Name und gultigen Zielbetrag eingeben.'),
        ),
      );
      return;
    }

    ref
        .read(savingsGoalProvider.notifier)
        .addGoal(
          name: nameController.text.trim(),
          target: target,
          monthlyContribution: monthly,
        );
  }
}

class _SavingsGoalCard extends ConsumerWidget {
  const _SavingsGoalCard({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = goal.target <= 0
        ? 0.0
        : (goal.current / goal.target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        color: goal.isActive ? Colors.white : Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: goal.isActive,
                onChanged: (_) => ref
                    .read(savingsGoalProvider.notifier)
                    .toggleActive(goal.id),
              ),
              IconButton(
                tooltip: 'Bearbeiten',
                onPressed: () => _openEditGoalDialog(context, ref, goal),
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: 'Loschen',
                onPressed: () =>
                    ref.read(savingsGoalProvider.notifier).deleteGoal(goal.id),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatEuro(goal.current)} von ${_formatEuro(goal.target)}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monatlich: ${_formatEuro(goal.monthlyContribution)}'),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
          if (goal.monthlyContribution > 0 && goal.current < goal.target) ...[
            const SizedBox(height: 6),
            Text(
              'Ziel erreicht in ca. ${_monthsToGoal(goal)} Monaten',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openEditGoalDialog(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final nameController = TextEditingController(text: goal.name);
    final targetController = TextEditingController(
      text: goal.target.toStringAsFixed(0),
    );
    final currentController = TextEditingController(
      text: goal.current.toStringAsFixed(0),
    );
    final monthlyController = TextEditingController(
      text: goal.monthlyContribution.toStringAsFixed(0),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sparziel bearbeiten'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Zielbetrag'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: currentController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Aktueller Stand'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: monthlyController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monatlich sparen',
                ),
              ),
            ],
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

    final target = _parseMoney(targetController.text);
    final current = _parseMoney(currentController.text);
    final monthly = _parseMoney(monthlyController.text);

    if (nameController.text.trim().isEmpty ||
        target == null ||
        target <= 0 ||
        current == null ||
        current < 0 ||
        monthly == null ||
        monthly < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gultige Werte eingeben.')),
      );
      return;
    }

    ref
        .read(savingsGoalProvider.notifier)
        .updateGoal(
          id: goal.id,
          name: nameController.text.trim(),
          target: target,
          monthlyContribution: monthly,
          current: current,
          isActive: goal.isActive,
        );
  }
}

String _formatEuro(double value) {
  final rounded = value.toStringAsFixed(2);
  final parts = rounded.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return 'EUR $intPart.${parts[1]}';
}

double? _parseMoney(String raw) {
  final normalized = raw
      .replaceAll('EUR', '')
      .replaceAll(' ', '')
      .replaceAll(',', '.')
      .trim();
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

int _monthsToGoal(SavingsGoal goal) {
  final remaining = goal.target - goal.current;
  if (remaining <= 0) return 0;
  if (goal.monthlyContribution <= 0) return -1;
  return (remaining / goal.monthlyContribution).ceil();
}
