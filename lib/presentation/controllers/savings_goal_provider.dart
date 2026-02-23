import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_local_storage.dart';
import '../../../presentation/controllers/home_calculation_provider.dart';

class SavingsGoal {
  final String name;
  final double target;
  final double current;

  SavingsGoal({
    required this.name,
    required this.target,
    required this.current,
  });

  Map<String, dynamic> toMap() => {'name': name, 'target': target};

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      name: (map['name'] as String?) ?? 'Urlaub',
      target: ((map['target'] as num?) ?? 3000).toDouble(),
      current: 0,
    );
  }
}

class SavingsGoalNotifier extends StateNotifier<SavingsGoal> {
  SavingsGoalNotifier(this.balanceRef, this._storage)
    : super(SavingsGoal(name: 'Urlaub', target: 3000, current: 0)) {
    _loadFromStorage();
  }

  final Ref balanceRef;
  final AppLocalStorage _storage;

  void _loadFromStorage() {
    final raw = _storage.loadSavingsGoal();
    if (raw == null) return;
    final loaded = SavingsGoal.fromMap(raw);
    state = SavingsGoal(
      name: loaded.name,
      target: loaded.target,
      current: state.current,
    );
  }

  void updateGoal(String name, double target) {
    state = SavingsGoal(name: name, target: target, current: state.current);
    unawaited(_storage.saveSavingsGoal(name: state.name, target: state.target));
  }
}

final savingsGoalProvider =
    StateNotifierProvider<SavingsGoalNotifier, SavingsGoal>((ref) {
      final notifier = SavingsGoalNotifier(ref, ref.read(localStorageProvider));
      return notifier;
    });

// Provider der beide kombiniert
final savingsGoalWithBalanceProvider = Provider<SavingsGoal>((ref) {
  final goal = ref.watch(savingsGoalProvider);
  final balance = ref.watch(balanceProvider);

  return SavingsGoal(name: goal.name, target: goal.target, current: balance);
});
