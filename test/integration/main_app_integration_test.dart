import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_minesweeper/main.dart';
import 'package:flutter_minesweeper/presentation/pages/settings_page.dart';
import 'package:flutter_minesweeper/presentation/providers/game_provider.dart';
import 'package:flutter_minesweeper/presentation/providers/settings_provider.dart';
import 'package:flutter_minesweeper/presentation/pages/game_page.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';

void main() {
  group('Main App Integration Tests', () {
    setUpAll(() {
      // Enable test mode to prevent native solver calls during tests
      FeatureFlags.enableTestMode = true;
    });
    testWidgets('should launch app and show main game screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MinesweeperApp());
      await tester.pumpAndSettle();
      // Should show the game board or a recognizable widget
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.textContaining('Minesweeper'), findsWidgets);
    });

    testWidgets('should navigate to settings and back', (WidgetTester tester) async {
      await tester.pumpWidget(const MinesweeperApp());
      await tester.pumpAndSettle();
      // Open settings (assume settings icon is present)
      final settingsIcon = find.byIcon(Icons.settings);
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();
      // Should show settings page
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();
      // Should return to game
      expect(find.textContaining('Minesweeper'), findsWidgets);
    });

    testWidgets('should initialize providers', (WidgetTester tester) async {
      await tester.pumpWidget(const MinesweeperApp());
      await tester.pumpAndSettle();
      // Find providers in the widget tree using GamePage context
      final context = tester.element(find.byType(GamePage));
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      expect(gameProvider, isNotNull);
      expect(settingsProvider, isNotNull);
    });
  });
} 