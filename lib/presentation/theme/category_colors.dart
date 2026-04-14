import 'package:flutter/material.dart';

const Map<String, Color> categoryColors = {
  'Wohnen': Color(0xFF1E3A8A),
  'Lebensmittel': Color(0xFF10B981),
  'Transport': Color(0xFFEF4444),
  'Unterhaltung': Color(0xFF7C3AED),
  'Shopping': Color(0xFFF59E0B),
  'Café': Color(0xFF8B4513),
  'Salary': Color(0xFF059669),
  'Food': Color(0xFFFF9800),
  'Entertainment': Color(0xFF9C27B0),
  'General': Color(0xFF4CAF50),
};

const Map<String, IconData> categoryIcons = {
  'Wohnen': Icons.home_rounded,
  'Lebensmittel': Icons.local_grocery_store_rounded,
  'Transport': Icons.directions_car_rounded,
  'Unterhaltung': Icons.movie_rounded,
  'Shopping': Icons.shopping_bag_rounded,
  'Café': Icons.local_cafe_rounded,
  'Salary': Icons.attach_money_rounded,
  'Food': Icons.restaurant_rounded,
  'Entertainment': Icons.theaters_rounded,
  'General': Icons.category_rounded,
};

const List<Color> selectableCategoryColors = [
  Color(0xFF1E7A4E),
  Color(0xFF0EA5E9),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF334155),
  Color(0xFF14B8A6),
  Color(0xFF22C55E),
  Color(0xFF64748B),
];

const Map<String, IconData> selectableCategoryIcons = {
  'wallet': Icons.account_balance_wallet_rounded,
  'cart': Icons.shopping_cart_rounded,
  'home': Icons.home_rounded,
  'food': Icons.restaurant_rounded,
  'car': Icons.directions_car_rounded,
  'train': Icons.train_rounded,
  'movie': Icons.movie_rounded,
  'gift': Icons.redeem_rounded,
  'fitness': Icons.fitness_center_rounded,
  'savings': Icons.savings_rounded,
  'travel': Icons.flight_takeoff_rounded,
  'general': Icons.category_rounded,
};

IconData iconForKey(String? key, {IconData fallback = Icons.category_rounded}) {
  if (key == null) return fallback;
  return selectableCategoryIcons[key] ?? fallback;
}
