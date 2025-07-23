// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/services/timer_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter_minesweeper/main.dart';
import 'package:flutter_minesweeper/presentation/providers/game_provider.dart';
import 'package:flutter_minesweeper/presentation/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerService()),
          ChangeNotifierProvider(create: (_) => GameProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MinesweeperApp(),
      ),
    );
    // Find the app title
    expect(find.text('Minesweeper with ML'), findsOneWidget);
  });
}
