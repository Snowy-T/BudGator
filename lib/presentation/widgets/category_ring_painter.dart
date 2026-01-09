import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';

class CategoryRingPainter extends CustomPainter {
  final List<TransactionModel> transactions;

  CategoryRingPainter(this.transactions);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final Map<String, double> sums = {};

    for (final t in transactions) {
      sums[t.category] = (sums[t.category] ?? 0) + t.amount;
    }

    final total = sums.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
  }
}
