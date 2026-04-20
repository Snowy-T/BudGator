import 'package:budgator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/money_formatter.dart';
import '../controllers/category_budget_provider.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  static const String _salaryIncomeKey = 'salary';
  static const String _otherIncomeKey = 'other_income';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _category = 'General';
  String _incomeCategory = _salaryIncomeKey;
  TransactionType _type = TransactionType.expense;

  Future<void> _submitTransaction(String selectedCategory) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '.').trim(),
    );
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invalidAmountMessage)));
      return;
    }

    final canContinue = await _handleBudgetChecksBeforeSave(
      category: selectedCategory,
      amount: amount,
    );
    if (!canContinue || !mounted) return;

    final categoryToSave = _type == TransactionType.income
        ? (_incomeCategory == _salaryIncomeKey
              ? l10n.salaryLabel
              : l10n.otherIncomeLabel)
        : selectedCategory;

    final transaction = TransactionModel(
      title: _titleController.text,
      amount: amount,
      date: _selectedDate,
      category: categoryToSave,
      type: _type,
    );

    ref.read(transactionsProvider.notifier).add(transaction);
    Navigator.pop(context);
  }

  Future<bool> _handleBudgetChecksBeforeSave({
    required String category,
    required double amount,
  }) async {
    final l10n = AppLocalizations.of(context)!;
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
              title: Text(l10n.overspendCategoryLimitTitle),
              content: Text(
                l10n.overspendNoSourceMessage(
                  activeTarget.budget.name,
                  formatEuroSmart(overBy),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.saveAnywayAction),
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
                  SnackBar(content: Text(l10n.deductionSaveFailed)),
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
            title: Text(l10n.overspendTotalBudgetTitle),
            content: Text(
              l10n.overspendTotalBudgetMessage(
                formatEuroSmart(projectedTotalSpent - summary.totalBudget),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.saveAnywayAction),
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
    final l10n = AppLocalizations.of(context)!;
    var selectedSource = sources.first;
    final deductionController = TextEditingController(
      text: formatInputAmount(overBy.clamp(0, selectedSource.remaining)),
    );

    return showDialog<_OverspendDecision>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(l10n.overspendCategoryLimitTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.categoryExceededByMessage(
                      target.budget.name,
                      formatEuroSmart(overBy),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.overspendTransferQuestion),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedSource.budget.id,
                  items: sources
                      .map(
                        (source) => DropdownMenuItem(
                          value: source.budget.id,
                          child: Text(
                            '${source.budget.name} (frei: ${formatEuroSmart(source.remaining)})',
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
                      deductionController.text = formatInputAmount(
                        overBy.clamp(0, selectedSource.remaining),
                      );
                    });
                  },
                  decoration: InputDecoration(
                    labelText: l10n.deductValueFromLabel,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deductionController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.deductionAmountLabel,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).pop(const _OverspendDecision.skipDeduction()),
              child: Text(l10n.continueWithoutDeduction),
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
                    SnackBar(content: Text(l10n.invalidAmountMessage)),
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
              child: Text(l10n.deductAmountAction),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(knownCategoriesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCategory = categories.contains(_category)
        ? _category
        : (categories.isNotEmpty ? categories.first : 'General');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.addTransaction,
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
                          l10n.newTransactionTitle,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.captureIncomeExpenseSubtitle,
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
                        labelText: l10n.titleLabel,
                        prefixIcon: Icon(
                          Icons.title_rounded,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? l10n.enterTitleValidation : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.paidAmountLabel,
                        prefixIcon: Icon(
                          Icons.euro_rounded,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? l10n.enterAmountValidation : null,
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
                                    ? l10n.tabIncome
                                    : l10n.tabExpenses,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _type = val;
                            if (_type == TransactionType.income) {
                              _incomeCategory = _salaryIncomeKey;
                            }
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: l10n.typeLabel,
                        prefixIcon: Icon(
                          Icons.swap_vert_rounded,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_type == TransactionType.expense)
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        items:
                            (categories.isNotEmpty ? categories : ['General'])
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.categoryLabel,
                          prefixIcon: Icon(
                            Icons.category_rounded,
                            color: colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _incomeCategory,
                        items: [
                          DropdownMenuItem(
                            value: _salaryIncomeKey,
                            child: Text(l10n.salaryLabel),
                          ),
                          DropdownMenuItem(
                            value: _otherIncomeKey,
                            child: Text(l10n.otherIncomeLabel),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _incomeCategory = val);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: l10n.incomeTypeLabel,
                          prefixIcon: Icon(
                            Icons.payments_rounded,
                            color: colorScheme.primary,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.dateLabel,
                        prefixIcon: Icon(
                          Icons.calendar_today_rounded,
                          color: colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
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
                            child: Text(l10n.chooseAction),
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
                        label: Text(l10n.addTransaction),
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
