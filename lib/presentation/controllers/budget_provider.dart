import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier()
      : super(
          BudgetState(
            salary: 2840,
            categories: [
              BudgetCategory(
                id: 'cat-wohnen',
                name: 'Wohnen',
                limit: 1200,
                spent: 850,
                color: const Color(0xFF1E3A8A),
                icon: Icons.home_rounded,
              ),
              BudgetCategory(
                id: 'cat-food',
                name: 'Lebensmittel',
                limit: 400,
                spent: 320,
                color: const Color(0xFF10B981),
                icon: Icons.local_grocery_store_rounded,
              ),
              BudgetCategory(
                id: 'cat-transport',
                name: 'Transport',
                limit: 250,
                spent: 280,
                color: const Color(0xFFEF4444),
                icon: Icons.directions_car_rounded,
              ),
              BudgetCategory(
                id: 'cat-ent',
                name: 'Unterhaltung',
                limit: 200,
                spent: 120,
                color: const Color(0xFF7C3AED),
                icon: Icons.movie_rounded,
              ),
            ],
            savings: [
              SavingsPlan(
                id: 'sav-urlaub',
                name: 'Urlaub 2024',
                target: 3000,
                current: 1850,
                monthly: 150,
                color: const Color(0xFFF59E0B),
                icon: Icons.flight_takeoff_rounded,
              ),
              SavingsPlan(
                id: 'sav-notfall',
                name: 'Notfall-Rücklage',
                target: 5000,
                current: 4200,
                monthly: 200,
                color: const Color(0xFF10B981),
                icon: Icons.shield_rounded,
              ),
            ],
          ),
        );

  void setSalary(double value) {
    if (value <= 0) return;
    state = state.copyWith(salary: value);
  }

  void addCategory({
    required String name,
    required double limit,
    required double spent,
  }) {
    if (name.trim().isEmpty || limit <= 0 || spent < 0) return;
    final color = _colorPalette[state.categories.length % _colorPalette.length];
    final icon = _iconPalette[state.categories.length % _iconPalette.length];
    final newCategory = BudgetCategory(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      limit: limit,
      spent: spent,
      color: color,
      icon: icon,
    );
    state = state.copyWith(categories: [...state.categories, newCategory]);
  }

  void addSavingsPlan({
    required String name,
    required double target,
    required double current,
    required double monthly,
  }) {
    if (name.trim().isEmpty || target <= 0 || current < 0 || monthly < 0) {
      return;
    }
    final color = _colorPalette[state.savings.length % _colorPalette.length];
    final icon = _iconPalette[state.savings.length % _iconPalette.length];
    final newPlan = SavingsPlan(
      id: 'sav-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      target: target,
      current: current,
      monthly: monthly,
      color: color,
      icon: icon,
    );
    state = state.copyWith(savings: [...state.savings, newPlan]);
  }
}

class BudgetState {
  final double salary;
  final List<BudgetCategory> categories;
  final List<SavingsPlan> savings;

  const BudgetState({
    required this.salary,
    required this.categories,
    required this.savings,
  });

  BudgetState copyWith({
    double? salary,
    List<BudgetCategory>? categories,
    List<SavingsPlan>? savings,
  }) {
    return BudgetState(
      salary: salary ?? this.salary,
      categories: categories ?? this.categories,
      savings: savings ?? this.savings,
    );
  }
}

class BudgetCategory {
  final String id;
  final String name;
  final double limit;
  final double spent;
  final Color color;
  final IconData icon;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.limit,
    required this.spent,
    required this.color,
    required this.icon,
  });
}

class SavingsPlan {
  final String id;
  final String name;
  final double target;
  final double current;
  final double monthly;
  final Color color;
  final IconData icon;

  const SavingsPlan({
    required this.id,
    required this.name,
    required this.target,
    required this.current,
    required this.monthly,
    required this.color,
    required this.icon,
  });
}

const List<Color> _colorPalette = [
  Color(0xFF1E3A8A),
  Color(0xFF10B981),
  Color(0xFFEF4444),
  Color(0xFF7C3AED),
  Color(0xFFF59E0B),
  Color(0xFF0EA5E9),
];

const List<IconData> _iconPalette = [
  Icons.home_rounded,
  Icons.shopping_basket_rounded,
  Icons.directions_car_rounded,
  Icons.movie_rounded,
  Icons.receipt_long_rounded,
  Icons.pets_rounded,
];
