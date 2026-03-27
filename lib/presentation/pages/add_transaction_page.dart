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
        if (!context.mounted) return false;

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
    final selectedCategory = categories.contains(_category)
        ? _category
        : (categories.isNotEmpty ? categories.first : 'General');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transaktion hinzufügen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF098825)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Neue Transaktion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Erfasse Einnahmen oder Ausgaben',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
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
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _fieldDecoration('Titel'),
                      validator: (value) =>
                          value!.isEmpty ? 'Titel eingeben' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      decoration: _fieldDecoration('Betrag'),
                      keyboardType: TextInputType.number,
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
                      decoration: _fieldDecoration('Typ'),
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
                      decoration: _fieldDecoration('Kategorie'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Datum: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        OutlinedButton(
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
                          child: const Text('Datum wählen'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitTransaction(selectedCategory),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF098825),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Transaktion hinzufügen',
                          style: TextStyle(color: Colors.white),
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
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
