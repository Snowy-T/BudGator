import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/datasources/app_local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = await AppLocalStorage.create();

  runApp(
    ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(localStorage)],
      child: const BudGatorApp(),
    ),
  );
}

class BudGatorApp extends StatelessWidget {
  const BudGatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BudGator',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
