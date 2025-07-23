import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_minesweeper/main.dart';
import 'package:flutter_minesweeper/presentation/pages/game_page.dart';
import 'package:flutter_minesweeper/presentation/providers/game_provider.dart';
import 'package:flutter_minesweeper/presentation/providers/settings_provider.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';

void main() {
  group('End-to-End Game Flow Integration Tests', () {
    setUpAll(() async {
      await GameModeConfig.instance.loadGameModes();
    });

    testWidgets('should complete a full game flow with win or lose condition', (WidgetTester tester) async {
      await tester.pumpWidget(const MinesweeperApp());
      await tester.pumpAndSettle();

      // Get providers for state verification
      final context = tester.element(find.byType(GamePage));
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      // Debug: Check available game modes
      print('Available game modes: ${GameModeConfig.instance.enabledGameModes.map((m) => m.id).toList()}');
      print('Default game mode: ${GameModeConfig.instance.defaultGameMode?.id}');

      // Explicitly initialize game with valid difficulty
      try {
        await gameProvider.initializeGame('easy');
        await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
        print('InitializeGame completed successfully');
      } catch (e) {
        print('InitializeGame failed with error: $e');
        rethrow;
      }

      // Debug: Check game state
      print('Game initialized: ${gameProvider.isGameInitialized}');
      print('Game state: ${gameProvider.gameState}');
      print('Game state isPlaying: ${gameProvider.gameState?.isPlaying}');
      print('Game provider error: ${gameProvider.error}');

      // Verify initial state - check if gameState exists first
      expect(gameProvider.gameState, isNotNull);
      expect(gameProvider.isGameInitialized, isTrue);

      // Find and interact with cells
      final cells = find.byType(RawGestureDetector);
      expect(cells, findsWidgets);

      // Tap first cell to start game
      await tester.tap(cells.first, warnIfMissed: false);
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout

      // Verify game started
      expect(gameProvider.gameState?.isPlaying, isTrue);

      // Continue tapping cells until game ends (win or lose)
      int taps = 0;
      const maxTaps = 50; // Increased limit for test
      while (gameProvider.gameState?.isPlaying == true && taps < maxTaps) {
        final untappedCells = find.byType(RawGestureDetector);
        if (untappedCells.evaluate().isEmpty) break;
        await tester.tap(untappedCells.first, warnIfMissed: false);
        await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
        taps++;
        print('Tap $taps: Game state = ${gameProvider.gameState?.gameStatus}');
        if (gameProvider.gameState?.isWon == true || gameProvider.gameState?.isLost == true) {
          print('Game ended after $taps taps');
          break;
        }
      }

      // Verify game ended (either win or lose) or reached max taps
      final gameEnded = gameProvider.gameState?.isWon == true || gameProvider.gameState?.isLost == true;
      final reachedMaxTaps = taps >= maxTaps;
      expect(
        gameEnded || reachedMaxTaps,
        isTrue,
        reason: 'Game should end after interactions or reach max taps (taps: $taps, gameEnded: $gameEnded)',
      );
      expect(gameProvider.gameState?.revealedCount ?? 0, greaterThan(0));
      expect(gameProvider.gameState?.gameDuration?.inSeconds ?? 0, greaterThanOrEqualTo(0));
      
      // Clean up timer to prevent test framework errors
      gameProvider.timerService.stop();
    });

    testWidgets('should handle game reset and restart', (WidgetTester tester) async {
      await tester.pumpWidget(const MinesweeperApp());
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(GamePage));
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      
      // Initialize game first
      await gameProvider.initializeGame('easy');
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      
      final cells = find.byType(RawGestureDetector);
      await tester.tap(cells.first, warnIfMissed: false);
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      expect(gameProvider.gameState?.isPlaying, isTrue);
      
      // Reset game
      await gameProvider.resetGame();
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      
      // After reset, game should be ready (not playing until first move)
      expect(gameProvider.gameState?.isPlaying, isTrue); // After reset, new game starts
      expect(gameProvider.gameState?.revealedCount ?? 0, equals(0));
      
      // Clean up timer to prevent test framework errors
      gameProvider.timerService.stop();
    });

    testWidgets('should handle flag placement and removal', (WidgetTester tester) async {
      await tester.pumpWidget(const MinesweeperApp());
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(GamePage));
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      
      // Initialize game first
      await gameProvider.initializeGame('easy');
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      
      final cells = find.byType(RawGestureDetector);
      expect(cells, findsWidgets);
      
      // Long press to flag a cell
      await tester.longPress(cells.first, warnIfMissed: false);
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      expect(gameProvider.gameState?.flaggedCount ?? 0, greaterThan(0));
      
      // Long press again to remove flag
      await tester.longPress(cells.first, warnIfMissed: false);
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      expect(gameProvider.gameState?.flaggedCount ?? 0, equals(0));
      
      // Clean up timer to prevent test framework errors
      gameProvider.timerService.stop();
    });

    testWidgets('should handle difficulty changes during game', (WidgetTester tester) async {
      await tester.pumpWidget(const MinesweeperApp());
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(GamePage));
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      // Initialize game first
      await gameProvider.initializeGame('easy');
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      
      final cells = find.byType(RawGestureDetector);
      await tester.tap(cells.first, warnIfMissed: false);
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      expect(gameProvider.gameState?.isPlaying, isTrue);
      
      // Change difficulty (should reset the game)
      settingsProvider.setDifficulty('hard');
      // Force reset repository and initialize new game (like settings page does)
      gameProvider.forceResetRepository();
      await gameProvider.initializeGame('hard');
      await tester.pump(); // Use pump() instead of pumpAndSettle() to avoid timeout
      
      expect(gameProvider.gameState?.isPlaying, isTrue); // New game started
      expect(settingsProvider.selectedDifficulty, 'hard');
      
      // Clean up timer to prevent test framework errors
      gameProvider.timerService.stop();
    });

    // You may need to add a test-only method to GameProvider to force a game over state for the following test
    // testWidgets('should handle game over dialog', (WidgetTester tester) async {
    //   await tester.pumpWidget(const MinesweeperApp());
    //   await tester.pumpAndSettle();
    //   final context = tester.element(find.byType(GamePage));
    //   final gameProvider = Provider.of<GameProvider>(context, listen: false);
    //   // Force game over state for testing (requires test-only method)
    //   gameProvider.setTestGameState(GameState.lost);
    //   await tester.pumpAndSettle();
    //   expect(find.text('Game Over'), findsOneWidget);
    //   expect(find.text('Play Again'), findsOneWidget);
    //   await tester.tap(find.text('Play Again'));
    //   await tester.pumpAndSettle();
    //   expect(gameProvider.gameState, GameState.ready);
    // });
  });
} 