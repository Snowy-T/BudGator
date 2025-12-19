import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';
import 'add_transaction_page.dart';

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
      // Hier kommen deine Tabs rein
      Center(child: Text('Home Tab')),
      Center(child: Text('Transaction Tab')),
      Center(child: Text('Budget Tab')),
      Center(child: Text('Stats Tab')),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('BudGator')),
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/addTransaction'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.double_arrow_sharp),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
