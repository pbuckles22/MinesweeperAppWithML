// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_minesweeper/main.dart';

void main() {
  testWidgets('Minesweeper app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MinesweeperApp());

    // Verify that the app title is displayed
    expect(find.text('Minesweeper with ML'), findsOneWidget);

    // Verify that the game board is present (should show loading initially)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the game to initialize
    await tester.pumpAndSettle();

    // Verify that the game board is now visible
    expect(find.byType(GridView), findsOneWidget);
  });
}
