import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransaactionsPageState extends ConsumerState<_TransactionsPage>
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
          _TransactionList(transactions.where((t) => t.amount > 0).toList()),
          _TransactionList(transactions.where((t) => t.amount < 0).toList()),
        ],
      ),
    );
  }
}
