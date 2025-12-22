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

    body: Stack(children: [
      pages[_currentIndex],

      Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionPage(),
              ),
              );
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                  color: Color.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ),
      )
    ],
    );
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            ),
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
    );
  }
}
