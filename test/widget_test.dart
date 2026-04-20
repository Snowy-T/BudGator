import 'package:budgator/data/datasources/app_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budgator/main.dart';

void main() {
  testWidgets('Budgator app renders home shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await AppLocalStorage.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageProvider.overrideWithValue(storage)],
        child: const BudGatorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BudGatorApp), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
