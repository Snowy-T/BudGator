import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/category_colors.dart';
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
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final Map<String, double> sums = {};

    for (final t in transactions) {
      sums[t.category] = (sums[t.category] ?? 0) + t.amount;
    }

    final total = sums.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    double startAngle = -pi / 2;

    sums.forEach((category, amount) {
      final sweepAngle = (amount / total) * 2 * pi;

      paint.color = categoryColors[category] ?? Colors.grey;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
