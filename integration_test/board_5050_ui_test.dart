import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_minesweeper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('50/50 UI indicator appears after move', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Start a new game (if needed, tap the new game button)
    // You may need to adjust this if your UI has a specific button
    final newGameButton = find.byIcon(Icons.refresh);
    if (newGameButton.evaluate().isNotEmpty) {
      await tester.tap(newGameButton);
      await tester.pumpAndSettle();
    }

    // Tap the first unrevealed cell
    final cellFinder = find.byType(Container).first;
    await tester.tap(cellFinder);
    await tester.pumpAndSettle();

    // Look for a 50/50 indicator (orange border or icon)
    // This assumes the 50/50 indicator uses Icons.help_outline and orange color
    final indicatorFinder = find.byIcon(Icons.help_outline);
    expect(indicatorFinder, findsWidgets);
  });
} 