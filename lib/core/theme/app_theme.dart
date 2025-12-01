import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E7D32);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
        .copyWith(primary: primary),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    scaffoldBackgroundColor: Colors.white,
  );
}
