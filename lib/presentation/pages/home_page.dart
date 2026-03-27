import 'package:budgator/presentation/pages/transactions_page.dart';
import 'package:budgator/presentation/pages/budget_page.dart';
import 'package:budgator/presentation/pages/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/transaction_model.dart';
import '../controllers/savings_goal_provider.dart';
import '../controllers/transaction_provider.dart';
import '../widgets/home_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final currentMonthKey = _monthKey(now);
      final applied = ref
          .read(savingsGoalProvider.notifier)
          .applyMonthlyContributionIfDue();

      bool hasMonthlyTx(String goalName, List<TransactionModel> txs) {
        return txs.any(
          (tx) =>
              tx.type == TransactionType.expense &&
              tx.category == 'Sparziel' &&
              tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.title == '$goalName-Monatsbeitrag',
        );
      }

      for (final item in applied) {
        final txs = ref.read(transactionsProvider);
        if (hasMonthlyTx(item.goalName, txs)) continue;

        ref
            .read(transactionsProvider.notifier)
            .add(
              TransactionModel(
                title: '${item.goalName}-Monatsbeitrag',
                amount: item.amount,
                date: now,
                category: 'Sparziel',
                type: TransactionType.expense,
              ),
            );
      }

      final goals = ref.read(savingsGoalProvider);
      for (final goal in goals) {
        if (!goal.isActive ||
            goal.monthlyContribution <= 0 ||
            goal.lastAutoContributionMonth != currentMonthKey) {
          continue;
        }

        final txs = ref.read(transactionsProvider);
        if (hasMonthlyTx(goal.name, txs)) continue;

        ref
            .read(transactionsProvider.notifier)
            .add(
              TransactionModel(
                title: '${goal.name}-Monatsbeitrag',
                amount: goal.monthlyContribution,
                date: now,
                category: 'Sparziel',
                type: TransactionType.expense,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeScreenContent(
        onShowAllTransactions: () => setState(() => _currentIndex = 1),
        onCreateSavingsGoal: () => setState(() => _currentIndex = 2),
      ),
      const TransactionsPage(),
      const BudgetPage(),
      const StatsPage(),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomAppBar(
          height: 68,
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
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.green : Colors.grey, size: 20),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 9,
                  color: isActive ? Colors.green : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
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
  final VoidCallback onCreateSavingsGoal;

  const _HomeScreenContent({
    required this.onShowAllTransactions,
    required this.onCreateSavingsGoal,
  });

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
          SavingsGoalWidget(onCreateGoalTap: onCreateSavingsGoal),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
