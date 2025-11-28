import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Green Colors - Modern Nature Theme
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF81C784);
  static const Color accent = Color(0xFFA5D6A7);
  
  // Background Colors
  static const Color background = Color(0xFFF5F9F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8F5E9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
    Color(0xFF81C784),
    Color(0xFFA5D6A7),
    Color(0xFFC8E6C9),
    Color(0xFF1B5E20),
    Color(0xFF388E3C),
    Color(0xFF66BB6A),
  ];
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
