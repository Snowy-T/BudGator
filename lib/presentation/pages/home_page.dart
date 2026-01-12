import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
