import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/category_budget_provider.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _category = 'General';
  TransactionType _type = TransactionType.expense;

  Future<void> _submitTransaction(String selectedCategory) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '.').trim(),
    );
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte einen gultigen Betrag eingeben.')),
      );
      return;
    }

    final canContinue = await _handleBudgetChecksBeforeSave(
      category: selectedCategory,
      amount: amount,
    );
    if (!canContinue || !mounted) return;

    final transaction = TransactionModel(
      title: _titleController.text,
      amount: amount,
      date: _selectedDate,
      category: selectedCategory,
      type: _type,
    );

    ref.read(transactionsProvider.notifier).add(transaction);
    Navigator.pop(context);
  }

  Future<bool> _handleBudgetChecksBeforeSave({
    required String category,
    required double amount,
  }) async {
    if (_type != TransactionType.expense) return true;

    final progressList = ref.read(categoryBudgetProgressProvider);
    final summary = ref.read(monthlyBudgetSummaryProvider);

    CategoryBudgetProgress? target;
    for (final item in progressList) {
      if (item.budget.name == category) {
        target = item;
        break;
      }
    }
    if (target != null && target.budget.monthlyLimit > 0) {
      final activeTarget = target;
      final projectedSpent = activeTarget.spent + amount;
      final overBy = projectedSpent - activeTarget.budget.monthlyLimit;

      if (overBy > 0) {
        final sources = progressList
            .where(
              (item) =>
                  item.budget.id != activeTarget.budget.id &&
                  item.remaining > 0,
            )
            .toList();

        if (sources.isEmpty) {
          final continueWithoutDeduction = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Kategorie-Limit uberschritten'),
              content: Text(
                '${activeTarget.budget.name} wurde um ${overBy.toStringAsFixed(2)} EUR uberschritten.\n\n'
                'Keine andere Kategorie hat aktuell Restbudget zum Abziehen. Trotzdem speichern?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Trotzdem speichern'),
                ),
              ],
            ),
          );

          if (continueWithoutDeduction != true) return false;
        } else {
          final result = await _openOverspendTransferDialog(
            target: activeTarget,
            overBy: overBy,
            sources: sources,
          );

          if (result == null) return false;

          if (result.applyDeduction) {
            final deducted = ref
                .read(categoryBudgetProvider.notifier)
                .removeFromCategoryLimit(
                  sourceId: result.source!.budget.id,
                  amount: result.deductionAmount,
                );
            if (!deducted) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Abzug aus der Kategorie konnte nicht gespeichert werden.',
                    ),
                  ),
                );
              }
              return false;
            }
          }
        }
      }
    }

    if (summary.hasTotalBudget) {
      final projectedTotalSpent = summary.totalSpent + amount;
      if (projectedTotalSpent > summary.totalBudget) {
        if (!mounted) return false;

        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gesamtbudget uberschritten'),
            content: Text(
              'Diese Ausgabe liegt uber dem monatlichen Gesamtbudget um '
              '${(projectedTotalSpent - summary.totalBudget).toStringAsFixed(2)} EUR. Trotzdem speichern?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Trotzdem speichern'),
              ),
            ],
          ),
        );

        if (proceed != true) return false;
      }
    }

    return true;
  }

  Future<_OverspendDecision?> _openOverspendTransferDialog({
    required CategoryBudgetProgress target,
    required double overBy,
    required List<CategoryBudgetProgress> sources,
  }) async {
    var selectedSource = sources.first;
    final deductionController = TextEditingController(
      text: overBy.clamp(0, selectedSource.remaining).toStringAsFixed(2),
    );

    return showDialog<_OverspendDecision>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Kategorie-Limit uberschritten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${target.budget.name} wurde um ${overBy.toStringAsFixed(2)} EUR uberschritten.',
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mochtest du diesen Betrag von einer anderen Kategorie abziehen?',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedSource.budget.id,
                  items: sources
                      .map(
                        (source) => DropdownMenuItem(
                          value: source.budget.id,
                          child: Text(
                            '${source.budget.name} (frei: ${source.remaining.toStringAsFixed(2)} EUR)',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    final next = sources.firstWhere(
                      (source) => source.budget.id == value,
                    );
                    setModalState(() {
                      selectedSource = next;
                      deductionController.text = overBy
                          .clamp(0, selectedSource.remaining)
                          .toStringAsFixed(2);
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Wert abziehen von',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deductionController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Abzugsbetrag'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(const _OverspendDecision.skipDeduction()),
              child: const Text('Ohne Abzug fortfahren'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(
                  deductionController.text.replaceAll(',', '.').trim(),
                );
                if (amount == null ||
                    amount <= 0 ||
                    amount > selectedSource.remaining) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte einen gultigen Betrag eingeben.'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(
                  _OverspendDecision.deduct(
                    source: selectedSource,
                    deductionAmount: amount,
                  ),
                );
              },
              child: const Text('Betrag abziehen'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(knownCategoriesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCategory = categories.contains(_category)
        ? _category
        : (categories.isNotEmpty ? categories.first : 'General');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Transaktion hinzufügen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Neue Transaktion',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Erfasse Einnahmen oder Ausgaben',
                          style: TextStyle(
                            color: colorScheme.onPrimary.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titel',
                        prefixIcon: Icon(Icons.title_rounded, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Titel eingeben' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Betrag',
                        prefixIcon: Icon(Icons.euro_rounded, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Betrag eingeben' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TransactionType>(
                      initialValue: _type,
                      items: TransactionType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t == TransactionType.income
                                    ? 'Einnahme'
                                    : 'Ausgabe',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _type = val);
                      },
                      decoration: InputDecoration(
                        labelText: 'Typ',
                        prefixIcon: Icon(Icons.swap_vert_rounded, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: (categories.isNotEmpty ? categories : ['General'])
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                      decoration: InputDecoration(
                        labelText: 'Kategorie',
                        prefixIcon: Icon(Icons.category_rounded, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Datum',
                        prefixIcon: Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _selectedDate = picked);
                              }
                            },
                            child: const Text('Wählen'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _submitTransaction(selectedCategory),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Transaktion hinzufügen'),
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
  }

}

class _OverspendDecision {
  final bool applyDeduction;
  final CategoryBudgetProgress? source;
  final double deductionAmount;

  const _OverspendDecision._({
    required this.applyDeduction,
    required this.source,
    required this.deductionAmount,
  });

  const _OverspendDecision.skipDeduction()
    : this._(applyDeduction: false, source: null, deductionAmount: 0);

  const _OverspendDecision.deduct({
    required CategoryBudgetProgress source,
    required double deductionAmount,
  }) : this._(
         applyDeduction: true,
         source: source,
         deductionAmount: deductionAmount,
       );
}
