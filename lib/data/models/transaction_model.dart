enum TransactionType { income, expense }

class TransactionModel {
  final int? id;
  final String title;
  final double amount; // Immer positiv
  final DateTime date;
  final String category;
  final TransactionType type;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'type': type.name,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
    id: m['id'] as int?,
    title: m['title'] as String,
    amount: (m['amount'] as num).toDouble(),
    date: DateTime.parse(m['date'] as String),
    category: m['category'] as String,
    type: TransactionType.values.byName(m['type'] as String? ?? 'expense'),
  );
}
