import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:budgator/core/constants/app_constants.dart';
import 'package:budgator/models/user.dart';
import 'package:budgator/models/budget.dart';
import 'package:budgator/models/transaction.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._internal();
  
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        has_completed_onboarding INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.budgetsTable} (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL DEFAULT 0,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.usersTable}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.transactionsTable} (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        budget_id TEXT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.usersTable}(id),
        FOREIGN KEY (budget_id) REFERENCES ${AppConstants.budgetsTable}(id)
      )
    ''');
  }

  // User Methods
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(AppConstants.usersTable, user.toMap());
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      AppConstants.usersTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Budget Methods
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert(AppConstants.budgetsTable, budget.toMap());
  }

  Future<List<Budget>> getBudgets(String userId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.budgetsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  Future<Budget?> getBudget(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.budgetsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      AppConstants.budgetsTable,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.budgetsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction Methods
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert(AppConstants.transactionsTable, transaction.toMap());
  }

  Future<List<Transaction>> getTransactions(String userId, {int? limit}) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByBudget(String budgetId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      where: 'budget_id = ?',
      whereArgs: [budgetId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      AppConstants.transactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
