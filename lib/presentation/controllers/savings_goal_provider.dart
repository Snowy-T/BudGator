import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

class SavingsGoalNotifier extends StateNotifier<SavingsGoal> {
  SavingsGoalNotifier(this.balanceRef)
    : super(SavingsGoal(name: 'Urlaub', target: 3000, current: 0));

  final Ref balanceRef;

  void updateGoal(String name, double target) {
    state = SavingsGoal(name: name, target: target, current: state.current);
  }
}

final savingsGoalProvider =
    StateNotifierProvider<SavingsGoalNotifier, SavingsGoal>((ref) {
      final notifier = SavingsGoalNotifier(ref);
      return notifier;
    });

// Provider der beide kombiniert
final savingsGoalWithBalanceProvider = Provider<SavingsGoal>((ref) {
  final goal = ref.watch(savingsGoalProvider);
  final balance = ref.watch(balanceProvider);

  return SavingsGoal(name: goal.name, target: goal.target, current: balance);
});
