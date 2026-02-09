import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

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
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaktionen'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alle'),
            Tab(text: 'Einnahmen'),
            Tab(text: 'Ausgaben'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(transactions),
          _TransactionList(
            transactions
                .where((t) => t.type == TransactionType.income)
                .toList(),
          ),
          _TransactionList(
            transactions
                .where((t) => t.type == TransactionType.expense)
                .toList(),
          ),
        ],
      ),
    );
  }
}

// LISTENANSICHT

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _TransactionList(this.transactions);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('Keine Transaktionen'));
    }

    final grouped = <String, List<TransactionModel>>{};

    for (final t in transactions) {
      final key = '${t.date.day}.${t.date.month}.${t.date.year}';
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: grouped.entries.map((entry) {
        return _TransactionGroup(date: entry.key, items: entry.value);
      }).toList(),
    );
  }
}

// KARTEN

class _TransactionGroup extends StatelessWidget {
  final String date;
  final List<TransactionModel> items;

  const _TransactionGroup({required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ...items.map((t) => _TransactionTile(t)),
          ],
        ),
      ),
    );
  }
}

// TRANSAKTIONEN

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile(this.transaction);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      title: Text(transaction.title),
      subtitle: Text(
        '${transaction.category} • '
        '${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}',
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} €',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
