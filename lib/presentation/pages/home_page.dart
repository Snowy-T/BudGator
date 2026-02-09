import 'package:budgator/presentation/pages/transactions_page.dart';
import 'package:budgator/presentation/pages/budget_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      _HomeScreenContent(
        onShowAllTransactions: () => setState(() => _currentIndex = 1),
      ),
      const TransactionsPage(),
      const BudgetPage(),
      const Center(child: Text('Statistik Tab')),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text(
                'Budgator',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            )
          : null,
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/addTransaction');
        },
        backgroundColor: Colors.green,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 60,
        child: BottomAppBar(
          height: 60,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              ),
              Flexible(
                child: _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaktionen',
                  index: 1,
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              ),
              const SizedBox(width: 56), // Space für FAB
              Flexible(
                child: _NavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Budget',
                  index: 2,
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              ),
              Flexible(
                child: _NavItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Statistik',
                  index: 3,
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.green : Colors.grey, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                color: isActive ? Colors.green : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  final VoidCallback onShowAllTransactions;

  const _HomeScreenContent({required this.onShowAllTransactions});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Gesamtbilanz
          const BalanceCard(),
          const SizedBox(height: 24),

          // Ausgaben-Übersicht
          const ExpensesByWeekWidget(),
          const SizedBox(height: 24),

          // Top Kategorien
          const TopCategoriesWidget(),
          const SizedBox(height: 24),

          // Letzte Transaktionen
          RecentTransactionsWidget(onShowAll: onShowAllTransactions),
          const SizedBox(height: 24),

          // Sparziel
          const SavingsGoalWidget(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
