import 'dart:async';

import 'package:budgator/presentation/pages/transactions_page.dart';
import 'package:budgator/presentation/pages/budget_page.dart';
import 'package:budgator/presentation/pages/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/google_pay_notification_service.dart';
import '../../data/models/transaction_model.dart';
import '../controllers/category_budget_provider.dart';
import '../controllers/savings_goal_provider.dart';
import '../controllers/transaction_provider.dart';
import '../controllers/theme_mode_provider.dart';
import '../widgets/home_widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  StreamSubscription<GooglePayNotificationEvent>? _googlePaySubscription;
  final Set<String> _handledNotificationKeys = <String>{};
  bool _hasAskedForNotificationAccess = false;
  bool _isConsumingPendingEvents = false;

  String _monthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

      unawaited(_setupGooglePayNotifications());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_setupGooglePayNotifications(showPrompt: false));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_googlePaySubscription?.cancel());
    super.dispose();
  }

  Future<void> _setupGooglePayNotifications({bool showPrompt = true}) async {
    final service = GooglePayNotificationService.instance;
    final granted = await service.isNotificationAccessGranted();
    if (!mounted) return;

    if (!granted) {
      if (showPrompt && !_hasAskedForNotificationAccess) {
        _hasAskedForNotificationAccess = true;
        await _showNotificationAccessDialog();
      }
      return;
    }

    _googlePaySubscription ??= service.events.listen(_onGooglePayNotification);
    await _consumePendingEvents();
  }

  Future<void> _consumePendingEvents() async {
    if (_isConsumingPendingEvents) return;
    _isConsumingPendingEvents = true;

    try {
      final pending = await GooglePayNotificationService.instance
          .fetchAndClearPendingEvents();
      if (!mounted || pending.isEmpty) return;

      for (final event in pending) {
        if (!mounted) break;
        await _onGooglePayNotification(event);
      }
    } finally {
      _isConsumingPendingEvents = false;
    }
  }

  Future<void> _showNotificationAccessDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Pay Erkennung aktivieren'),
        content: const Text(
          'Damit Zahlungen automatisch vorgeschlagen werden, braucht Budgator Zugriff auf Benachrichtigungen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Spater'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await GooglePayNotificationService.instance
                  .openNotificationAccessSettings();
            },
            child: const Text('Einstellungen offnen'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettingsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final themeMode = ref.watch(themeModeProvider);
          final isDarkMode = themeMode == ThemeMode.dark;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Einstellungen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: isDarkMode,
                    onChanged: (value) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                    title: const Text('Darkmode'),
                    subtitle: Text(
                      themeMode == ThemeMode.system
                          ? 'Folgt der Geräteeinstellung'
                          : isDarkMode
                          ? 'Aktiviert'
                          : 'Deaktiviert',
                    ),
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.refresh_rounded),
                    title: const Text('Darkmode zurücksetzen'),
                    subtitle: const Text('Zurück zum Systemmodus'),
                    onTap: () async {
                      await ref
                          .read(themeModeProvider.notifier)
                          .resetThemeMode();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onGooglePayNotification(
    GooglePayNotificationEvent event,
  ) async {
    final key =
        '${event.packageName}:${event.timestamp.millisecondsSinceEpoch}:${event.message}';
    if (_handledNotificationKeys.contains(key)) return;
    _handledNotificationKeys.add(key);
    if (!mounted) return;

    final draft = await _showPaymentOverlay(event);
    if (!mounted || draft == null) return;

    ref
        .read(transactionsProvider.notifier)
        .add(
          TransactionModel(
            title: draft.title,
            amount: draft.amount,
            date: draft.date,
            category: draft.category,
            type: TransactionType.expense,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zahlung als Transaktion gespeichert.')),
    );
  }

  Future<_PaymentOverlayDraft?> _showPaymentOverlay(
    GooglePayNotificationEvent event,
  ) {
    final categories = ref.read(knownCategoriesProvider);
    final initialCategory = categories.contains('General')
        ? 'General'
        : (categories.isNotEmpty ? categories.first : 'General');
    final amountController = TextEditingController(
      text: (event.amount ?? 0).toStringAsFixed(2),
    );
    final titleController = TextEditingController(
      text: event.title.isNotEmpty ? event.title : 'Google Pay Zahlung',
    );
    var selectedCategory = initialCategory;

    return showModalBottomSheet<_PaymentOverlayDraft>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Google Pay Zahlung erkannt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                event.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Bezahlter Betrag',
                  hintText: 'z. B. 7,50',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: (categories.isNotEmpty ? categories : ['General'])
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() => selectedCategory = value);
                },
                decoration: const InputDecoration(labelText: 'Kategorie'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Ignorieren'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(
                          amountController.text.replaceAll(',', '.').trim(),
                        );
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bitte gultigen Betrag eingeben.'),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop(
                          _PaymentOverlayDraft(
                            amount: amount,
                            title: titleController.text.trim().isEmpty
                                ? 'Google Pay Zahlung'
                                : titleController.text.trim(),
                            category: selectedCategory,
                            date: event.timestamp,
                          ),
                        );
                      },
                      child: const Text('Speichern'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              centerTitle: false,
              titleSpacing: 0,
              leadingWidth: 56,
              leading: IconButton(
                tooltip: 'Einstellungen',
                onPressed: _openSettingsSheet,
                icon: const Icon(Icons.settings_rounded),
              ),
              title: Text(
                'Budgator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              elevation: 0,
              backgroundColor: theme.appBarTheme.backgroundColor,
              foregroundColor: colorScheme.onSurface,
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

class _PaymentOverlayDraft {
  final double amount;
  final String title;
  final String category;
  final DateTime date;

  const _PaymentOverlayDraft({
    required this.amount,
    required this.title,
    required this.category,
    required this.date,
  });
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
