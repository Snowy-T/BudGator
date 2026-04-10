import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import '../controllers/transaction_provider.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Transaktionen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: _BrowserTabIndicator(color: Colors.white),
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Alle'),
                    Tab(text: 'Einnahmen'),
                    Tab(text: 'Ausgaben'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(transactions: transactions),
          _TransactionList(
            transactions: transactions
                .where((t) => t.type == TransactionType.income)
                .toList(),
          ),
          _TransactionList(
            transactions: transactions
                .where((t) => t.type == TransactionType.expense)
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BrowserTabIndicator extends Decoration {
  final Color color;

  const _BrowserTabIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BrowserTabIndicatorPainter(this);
  }
}

class _BrowserTabIndicatorPainter extends BoxPainter {
  final _BrowserTabIndicator decoration;

  _BrowserTabIndicatorPainter(this.decoration);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final rect = offset & size;
    final tabRect = Rect.fromLTWH(
      rect.left + 2,
      rect.top + 2,
      rect.width - 4,
      rect.height - 2,
    );

    final rRect = RRect.fromRectAndCorners(
      tabRect,
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
    );

    final fillPaint = Paint()..color = decoration.color;
    canvas.drawRRect(rRect, fillPaint);

    final eraseBottomPaint = Paint()
      ..color = decoration.color
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(tabRect.left + 1, tabRect.bottom),
      Offset(tabRect.right - 1, tabRect.bottom),
      eraseBottomPaint,
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: const Text(
            'Keine Transaktionen',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final grouped = <String, List<TransactionModel>>{};
    for (final tx in transactions) {
      final key = '${tx.date.day}.${tx.date.month}.${tx.date.year}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final keys = grouped.keys.toList()
      ..sort((a, b) {
        DateTime parse(String key) {
          final parts = key.split('.');
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }

        return parse(b).compareTo(parse(a));
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        for (final key in keys)
          _TransactionGroup(date: key, items: grouped[key]!),
      ],
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  final String date;
  final List<TransactionModel> items;

  const _TransactionGroup({required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((tx) => _TransactionTile(transaction: tx)),
        ],
      ),
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final time =
        '${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}';

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
                Text(
                  '${transaction.category} - $time',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}EUR ${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert_rounded, size: 18),
                onSelected: (value) async {
                  if (value == 'edit') {
                    await _openEditDialog(context, ref);
                    return;
                  }

                  if (value == 'delete') {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Transaktion loschen'),
                        content: const Text(
                          'Mochtest du diese Transaktion wirklich loschen?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Abbrechen'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Loschen'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true && transaction.id != null) {
                      ref
                          .read(transactionsProvider.notifier)
                          .remove(transaction.id!);
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                  PopupMenuItem(value: 'delete', child: Text('Loschen')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController(text: transaction.title);
    final amountController = TextEditingController(
      text: transaction.amount.toStringAsFixed(2),
    );
    final categoryController = TextEditingController(
      text: transaction.category,
    );
    var selectedType = transaction.type;
    var selectedDate = transaction.date;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Transaktion bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titel'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Betrag'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Kategorie'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TransactionType>(
                  initialValue: selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: TransactionType.income,
                      child: Text('Einnahme'),
                    ),
                    DropdownMenuItem(
                      value: TransactionType.expense,
                      child: Text('Ausgabe'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() {
                      selectedType = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Typ'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Datum: ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked == null) return;
                        setModalState(() {
                          selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            selectedDate.hour,
                            selectedDate.minute,
                          );
                        });
                      },
                      child: const Text('Wahlen'),
                    ),
                  ],
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
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final title = titleController.text.trim();
    final category = categoryController.text.trim();
    final amount = double.tryParse(
      amountController.text.replaceAll(',', '.').trim(),
    );

    if (title.isEmpty || category.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gultige Werte eingeben.')),
      );
      return;
    }

    ref
        .read(transactionsProvider.notifier)
        .update(
          TransactionModel(
            id: transaction.id,
            title: title,
            amount: amount,
            date: selectedDate,
            category: category,
            type: selectedType,
          ),
        );
  }
}
