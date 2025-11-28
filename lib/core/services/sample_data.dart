import 'package:budgator/models/user.dart';
import 'package:budgator/models/budget.dart';
import 'package:budgator/models/transaction.dart';
import 'package:uuid/uuid.dart';

class SampleData {
  static const _uuid = Uuid();
  
  static final String sampleUserId = _uuid.v4();
  
  static User getSampleUser() {
    final now = DateTime.now();
    return User(
      id: sampleUserId,
      name: 'Demo User',
      email: 'demo@budgator.app',
      createdAt: now,
      updatedAt: now,
      hasCompletedOnboarding: true,
    );
  }

  static List<Budget> getSampleBudgets() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return [
      Budget(
        id: _uuid.v4(),
        userId: sampleUserId,
        name: 'Food & Dining',
        category: 'Food & Dining',
        amount: 500.0,
        spent: 320.50,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
      Budget(
        id: _uuid.v4(),
        userId: sampleUserId,
        name: 'Transportation',
        category: 'Transportation',
        amount: 200.0,
        spent: 150.00,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
      Budget(
        id: _uuid.v4(),
        userId: sampleUserId,
        name: 'Entertainment',
        category: 'Entertainment',
        amount: 150.0,
        spent: 85.00,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
      Budget(
        id: _uuid.v4(),
        userId: sampleUserId,
        name: 'Shopping',
        category: 'Shopping',
        amount: 300.0,
        spent: 275.00,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
      Budget(
        id: _uuid.v4(),
        userId: sampleUserId,
        name: 'Bills & Utilities',
        category: 'Bills & Utilities',
        amount: 400.0,
        spent: 380.00,
        startDate: startOfMonth,
        endDate: endOfMonth,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<Transaction> getSampleTransactions() {
    final now = DateTime.now();
    
    return [
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Grocery Shopping',
        category: 'Food & Dining',
        amount: 85.50,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 1)),
        notes: 'Weekly groceries',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Monthly Salary',
        category: 'Salary',
        amount: 4500.00,
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 5)),
        notes: 'November salary',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Gas Station',
        category: 'Transportation',
        amount: 45.00,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Netflix Subscription',
        category: 'Entertainment',
        amount: 15.99,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 3)),
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Restaurant Dinner',
        category: 'Food & Dining',
        amount: 65.00,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 4)),
        notes: 'Birthday dinner',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Freelance Project',
        category: 'Freelance',
        amount: 800.00,
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 7)),
        notes: 'Web development project',
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Electric Bill',
        category: 'Bills & Utilities',
        amount: 120.00,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 8)),
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'New Shoes',
        category: 'Shopping',
        amount: 89.99,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Coffee Shop',
        category: 'Food & Dining',
        amount: 12.50,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      ),
      Transaction(
        id: _uuid.v4(),
        userId: sampleUserId,
        title: 'Uber Ride',
        category: 'Transportation',
        amount: 25.00,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 6)),
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Summary data for dashboard
  static Map<String, double> getMonthlySummary() {
    final transactions = getSampleTransactions();
    double totalIncome = 0;
    double totalExpenses = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
    };
  }

  // Category breakdown for charts
  static Map<String, double> getExpensesByCategory() {
    final transactions = getSampleTransactions()
        .where((t) => t.type == TransactionType.expense)
        .toList();
    
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in transactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    
    return categoryTotals;
  }
}
