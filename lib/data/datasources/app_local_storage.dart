import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

final localStorageProvider = Provider<AppLocalStorage>((ref) {
  throw UnimplementedError(
    'localStorageProvider muss in main.dart per override gesetzt werden.',
  );
});

class AppLocalStorage {
  static const _transactionsKey = 'transactions_v1';
  static const _savingsGoalKey = 'savings_goal_v1';

  AppLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppLocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLocalStorage(prefs);
  }

  List<TransactionModel> loadTransactions() {
    final raw = _prefs.getString(_transactionsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<TransactionModel> items) {
    final payload = items.map((t) => t.toMap()).toList();
    return _prefs.setString(_transactionsKey, jsonEncode(payload));
  }

  Map<String, dynamic>? loadSavingsGoal() {
    final raw = _prefs.getString(_savingsGoalKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSavingsGoal({required String name, required double target}) {
    final payload = {'name': name, 'target': target};
    return _prefs.setString(_savingsGoalKey, jsonEncode(payload));
  }
}
