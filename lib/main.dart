import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BudGatorApp()));
}

class BudGatorApp extends StatelessWidget {
  const BudGatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudGator',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
