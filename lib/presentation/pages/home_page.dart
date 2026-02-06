import 'package:budgator/presentation/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';
import '../widgets/add_transaction_ring.dart';
import '../widgets/summary_bar.dart';


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
      const TransactionsPage(),
      const Center(child: Text('Budget Tab')),
      const Center(child: Text('Stats Tab')),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(title: const Text('Budgator'), centerTitle: true)
          : null,
      body: Stack(
        children: [
          pages[_currentIndex],

          if (_currentIndex == 0)
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  children: [
                    const AddTransactionRing(),
                    const SizedBox(height: 24),
                    const SummaryBar(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
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
