import 'package:budgator/presentation/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/add_transaction_ring.dart';
import '../widgets/home_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _HomeScreenContent(),
      const TransactionsPage(),
      const Center(child: Text('Budget Tab')),
      const Center(child: Text('Stats Tab')),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text(
                'BudgetPro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            )
          : null,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transaktionen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Gesamtbilanz
          const BalanceCard(),
          const SizedBox(height: 24),

          // Schnelllinks + Add Ring
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const AddTransactionRing()],
            ),
          ),
          const SizedBox(height: 24),

          // Einnahmen & Ausgaben Boxen
          const IncomeExpenseBoxes(),
          const SizedBox(height: 24),

          // Ausgaben-Übersicht
          const ExpensesByWeekWidget(),
          const SizedBox(height: 24),

          // Top Kategorien
          const TopCategoriesWidget(),
          const SizedBox(height: 24),

          // Letzte Transaktionen
          const RecentTransactionsWidget(),
          const SizedBox(height: 24),

          // Sparziel
          const SavingsGoalWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
