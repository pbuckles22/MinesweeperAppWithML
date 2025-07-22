import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_minesweeper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Visible integration test with progress indicators', (tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();
    
    // Wait a moment so you can see the app launched
    await Future.delayed(const Duration(seconds: 2));
    
    // Find and tap the Easy difficulty button
    final easyButton = find.text('Easy');
    expect(easyButton, findsOneWidget);
    
    // Add a visible delay so you can see the tap
    await tester.tap(easyButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    
    // Find the game board
    final gameBoard = find.byType(GestureDetector);
    expect(gameBoard, findsWidgets);
    
    // Tap the first cell (top-left)
    final firstCell = find.byType(GestureDetector).first;
    await tester.tap(firstCell);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    
    // Tap a few more cells to show progress
    final cells = find.byType(GestureDetector);
    if (cells.evaluate().isNotEmpty && cells.evaluate().length > 1) {
      await tester.tap(cells.at(1));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    if (cells.evaluate().isNotEmpty && cells.evaluate().length > 2) {
      await tester.tap(cells.at(2));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Show completion
    await Future.delayed(const Duration(seconds: 2));
    
    print('✅ Visible integration test completed successfully!');
  });
} 