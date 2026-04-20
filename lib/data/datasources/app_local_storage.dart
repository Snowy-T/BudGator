import 'dart:convert';

import 'package:flutter/material.dart';
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
  static const _savingsGoalsKey = 'savings_goals_v1';
  static const _categoryBudgetsKey = 'category_budgets_v1';
  static const _monthlyTotalBudgetsKey = 'monthly_total_budgets_v1';
  static const _themeModeKey = 'theme_mode_v1';
  static const _appLanguageKey = 'app_language_v1';

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

  List<Map<String, dynamic>> loadSavingsGoals() {
    final raw = _prefs.getString(_savingsGoalsKey);
    if (raw == null || raw.isEmpty) {
      final legacy = loadSavingsGoal();
      if (legacy == null) return [];
      return [
        {
          'id': 'legacy-${DateTime.now().millisecondsSinceEpoch}',
          'name': (legacy['name'] as String?) ?? 'Sparziel',
          'target': ((legacy['target'] as num?) ?? 3000).toDouble(),
          'current': 0.0,
          'monthlyContribution': 0.0,
          'isActive': true,
        },
      ];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSavingsGoals(List<Map<String, dynamic>> goals) {
    return _prefs.setString(_savingsGoalsKey, jsonEncode(goals));
  }

  List<Map<String, dynamic>> loadCategoryBudgets() {
    final raw = _prefs.getString(_categoryBudgetsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCategoryBudgets(List<Map<String, dynamic>> budgets) {
    return _prefs.setString(_categoryBudgetsKey, jsonEncode(budgets));
  }

  Map<String, double> loadMonthlyTotalBudgets() {
    final raw = _prefs.getString(_monthlyTotalBudgetsKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, ((value as num?) ?? 0).toDouble()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveMonthlyTotalBudgets(Map<String, double> values) {
    return _prefs.setString(_monthlyTotalBudgetsKey, jsonEncode(values));
  }

  ThemeMode loadThemeMode() {
    final raw = _prefs.getString(_themeModeKey);
    if (raw == null || raw.isEmpty) return ThemeMode.system;

    for (final mode in ThemeMode.values) {
      if (mode.name == raw) return mode;
    }

    return ThemeMode.system;
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> resetThemeMode() {
    return _prefs.remove(_themeModeKey);
  }

  String loadAppLanguage() {
    final raw = _prefs.getString(_appLanguageKey);
    if (raw == null || raw.isEmpty) return 'system';
    return raw;
  }

  Future<void> saveAppLanguage(String language) {
    return _prefs.setString(_appLanguageKey, language);
  }

  Future<void> resetAppLanguage() {
    return _prefs.remove(_appLanguageKey);
  }
}
