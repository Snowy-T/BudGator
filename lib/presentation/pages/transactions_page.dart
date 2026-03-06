import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

String _formatWeekdayOrDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));
  final dateOnly = DateTime(date.year, date.month, date.day);
  final isThisWeek =
      !dateOnly.isBefore(startOfWeek) && dateOnly.isBefore(endOfWeek);

  if (isThisWeek) {
    const weekdayNames = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    return weekdayNames[dateOnly.weekday - 1];
  }

  if (dateOnly.year == today.year) {
    return DateFormat('dd.MMM', 'en_US').format(dateOnly);
  }
  return DateFormat('dd.MMM.yyyy', 'en_US').format(dateOnly);
}

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage>
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transaktionen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: _BrowserTabIndicator(color: Colors.white),
                  labelColor: Color(0xFF10B981),
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Alle'),
                    Tab(text: 'Einnahmen'),
                    Tab(text: 'Ausgaben'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(transactions),
          _TransactionList(
            transactions
                .where((t) => t.type == TransactionType.income)
                .toList(),
          ),
          _TransactionList(
            transactions
                .where((t) => t.type == TransactionType.expense)
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BrowserTabIndicator extends Decoration {
  final Color color;

  const _BrowserTabIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BrowserTabIndicatorPainter(this);
  }
}

class _BrowserTabIndicatorPainter extends BoxPainter {
  final _BrowserTabIndicator decoration;

  _BrowserTabIndicatorPainter(this.decoration);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;

    final rect = offset & size;
    final tabRect = Rect.fromLTWH(
      rect.left + 1,
      rect.top + 1,
      rect.width - 4,
      rect.height - 2,
    );

    final rRect = RRect.fromRectAndCorners(
      tabRect,
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
    );

    final fillPaint = Paint()..color = decoration.color;
    canvas.drawRRect(rRect, fillPaint);

    final eraseBottomPaint = Paint()
      ..color = decoration.color
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(tabRect.left + 1, tabRect.bottom),
      Offset(tabRect.right - 1, tabRect.bottom),
      eraseBottomPaint,
    );
  }
}

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _TransactionList(this.transactions);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text(
            'Keine Transaktionen',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final sortedTransactions = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final grouped = <String, List<TransactionModel>>{};

    for (final t in sortedTransactions) {
      final key = _formatWeekdayOrDate(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: grouped.entries.map((entry) {
        return _TransactionGroup(date: entry.key, items: entry.value);
      }).toList(),
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  final String date;
  final List<TransactionModel> items;

  const _TransactionGroup({required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((t) => _TransactionTile(t)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile(this.transaction);

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final time =
        '${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${transaction.category} • $time',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}€${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
