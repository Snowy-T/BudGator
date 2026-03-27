import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/app_local_storage.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double target;
  final double current;
  final double monthlyContribution;
  final bool isActive;
  final String? lastAutoContributionMonth;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    required this.current,
    required this.monthlyContribution,
    required this.isActive,
    this.lastAutoContributionMonth,
  });

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? target,
    double? current,
    double? monthlyContribution,
    bool? isActive,
    String? lastAutoContributionMonth,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      target: target ?? this.target,
      current: current ?? this.current,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      isActive: isActive ?? this.isActive,
      lastAutoContributionMonth:
          lastAutoContributionMonth ?? this.lastAutoContributionMonth,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'target': target,
    'current': current,
    'monthlyContribution': monthlyContribution,
    'isActive': isActive,
    'lastAutoContributionMonth': lastAutoContributionMonth,
  };

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id:
          (map['id'] as String?) ??
          'goal-${DateTime.now().millisecondsSinceEpoch}',
      name: (map['name'] as String?) ?? 'Sparziel',
      target: ((map['target'] as num?) ?? 3000).toDouble(),
      current: ((map['current'] as num?) ?? 0).toDouble(),
      monthlyContribution: ((map['monthlyContribution'] as num?) ?? 0)
          .toDouble(),
      isActive: (map['isActive'] as bool?) ?? true,
      lastAutoContributionMonth: map['lastAutoContributionMonth'] as String?,
    );
  }
}

String _monthKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}

class AppliedSavingsContribution {
  final String goalId;
  final String goalName;
  final double amount;

  const AppliedSavingsContribution({
    required this.goalId,
    required this.goalName,
    required this.amount,
  });
}

class SavingsGoalNotifier extends StateNotifier<List<SavingsGoal>> {
  SavingsGoalNotifier(this._storage) : super(const []) {
    _loadFromStorage();
  }

  final AppLocalStorage _storage;

  void _loadFromStorage() {
    final raw = _storage.loadSavingsGoals();
    if (raw.isEmpty) return;
    state = raw.map(SavingsGoal.fromMap).toList();
  }

  Future<void> _save() {
    return _storage.saveSavingsGoals(state.map((e) => e.toMap()).toList());
  }

  void addGoal({
    required String name,
    required double target,
    double monthlyContribution = 0,
    double current = 0,
    bool isActive = true,
  }) {
    if (name.trim().isEmpty ||
        target <= 0 ||
        monthlyContribution < 0 ||
        current < 0) {
      return;
    }

    final goal = SavingsGoal(
      id: 'goal-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      target: target,
      current: current,
      monthlyContribution: monthlyContribution,
      isActive: isActive,
    );

    state = [...state, goal];
    unawaited(_save());
  }

  void updateGoal({
    required String id,
    required String name,
    required double target,
    required double monthlyContribution,
    required double current,
    required bool isActive,
  }) {
    if (name.trim().isEmpty ||
        target <= 0 ||
        monthlyContribution < 0 ||
        current < 0) {
      return;
    }

    state = [
      for (final goal in state)
        if (goal.id == id)
          goal.copyWith(
            name: name.trim(),
            target: target,
            monthlyContribution: monthlyContribution,
            current: current,
            isActive: isActive,
          )
        else
          goal,
    ];
    unawaited(_save());
  }

  void deleteGoal(String id) {
    state = state.where((goal) => goal.id != id).toList();
    unawaited(_save());
  }

  void toggleActive(String id) {
    state = [
      for (final goal in state)
        if (goal.id == id) goal.copyWith(isActive: !goal.isActive) else goal,
    ];
    unawaited(_save());
  }

  void setMonthlyContribution(String id, double amount) {
    if (amount < 0) return;
    state = [
      for (final goal in state)
        if (goal.id == id) goal.copyWith(monthlyContribution: amount) else goal,
    ];
    unawaited(_save());
  }

  double addCurrentToGoal(String id, double amount) {
    if (amount <= 0) return 0;

    var changed = false;
    var appliedAmount = 0.0;
    final updated = <SavingsGoal>[];
    for (final goal in state) {
      if (goal.id == id) {
        final available = (goal.target - goal.current)
            .clamp(0, amount)
            .toDouble();
        if (available <= 0) {
          updated.add(goal);
          continue;
        }

        changed = true;
        appliedAmount = available;
        updated.add(
          goal.copyWith(
            current: (goal.current + available).clamp(0, goal.target),
          ),
        );
      } else {
        updated.add(goal);
      }
    }

    if (!changed) return 0;
    state = updated;
    unawaited(_save());
    return appliedAmount;
  }

  List<AppliedSavingsContribution> applyMonthlyContributionIfDue({
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final monthKey = _monthKey(currentDate);

    final applied = <AppliedSavingsContribution>[];
    final updated = <SavingsGoal>[];
    for (final goal in state) {
      if (!goal.isActive ||
          goal.monthlyContribution <= 0 ||
          goal.current >= goal.target ||
          goal.lastAutoContributionMonth == monthKey) {
        updated.add(goal);
        continue;
      }

      final available = (goal.target - goal.current)
          .clamp(0, goal.monthlyContribution)
          .toDouble();
      if (available <= 0) {
        updated.add(goal);
        continue;
      }

      updated.add(
        goal.copyWith(
          current: (goal.current + available).clamp(0, goal.target),
          lastAutoContributionMonth: monthKey,
        ),
      );
      applied.add(
        AppliedSavingsContribution(
          goalId: goal.id,
          goalName: goal.name,
          amount: available,
        ),
      );
    }

    if (applied.isEmpty) return const [];
    state = updated;
    unawaited(_save());
    return applied;
  }

  // Compatibility method for older call-sites.
  void updateSingleGoal(String name, double target) {
    if (state.isEmpty) {
      addGoal(name: name, target: target);
      return;
    }

    final first = state.first;
    updateGoal(
      id: first.id,
      name: name,
      target: target,
      monthlyContribution: first.monthlyContribution,
      current: first.current,
      isActive: first.isActive,
    );
  }
}

final savingsGoalProvider =
    StateNotifierProvider<SavingsGoalNotifier, List<SavingsGoal>>((ref) {
      final notifier = SavingsGoalNotifier(ref.read(localStorageProvider));
      return notifier;
    });

final firstSavingsGoalProvider = Provider<SavingsGoal?>((ref) {
  final goals = ref.watch(savingsGoalProvider);
  for (final goal in goals) {
    if (goal.isActive) return goal;
  }
  return null;
});
