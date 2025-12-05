import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('BudGator')),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    title: Text(t.title),
                    subtitle: Text('${t.amount} \$ • ${t.category}'),
                    trailing: Text(
                      '${t.date.day}/${t.date.month}/${t.date.year}',
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push('/addTransaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
