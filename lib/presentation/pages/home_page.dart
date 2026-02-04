import 'package:budgator/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';
import 'add_transaction_page.dart';
import '../widgets/add_transaction_ring.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    final List<Widget> pages = [
      const SizedBox.shrink(),
      const Center(child: Text('Transaction Tab')),
      const Center(child: Text('Budget Tab')),
      const Center(child: Text('Stats Tab')),
    ];

    return Scaffold(
      body: Stack(
        children: [
          pages[_currentIndex],

          if (_currentIndex == 0)
            const SafeArea(child: Center(child: AddTransactionRing())),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

// LISTEN ANSICHT

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _TransactionList(this.transactions);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No Transactions'));
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

// KARTEN IN DER LISTE

class _TransactionGroup extends StatelessWidget {
  final String date;
  final List<TransactionModel> items;


  const _TransactionGroup({
    required this.date,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: context EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            ...items.map((t) => _TransactionTile(t)),
          ],
        ),
      ),
    );
  }
}


Tran
