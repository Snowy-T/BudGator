import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/transaction_provider.dart';
import '../painters/category_ring_painter.dart';
import '../theme/category_colors.dart';

class AddTransactionRing extends ConsumerWidget {
  const AddTransactionRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          CustomPaint(
            size: const Size(160, 160),
            painter: CategoryRingPainter(transactions),
          ),
          // Button
          GestureDetector(
            onTap: () {
              context.push('/addTransaction');
            },
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: const Icon(Icons.add, size: 36, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
