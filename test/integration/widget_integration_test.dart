import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_minesweeper/presentation/providers/game_provider.dart';
import 'package:flutter_minesweeper/presentation/providers/settings_provider.dart';
import 'package:flutter_minesweeper/presentation/widgets/game_board.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';

void main() {
  group('Widget Integration Tests', () {
    late GameProvider gameProvider;
    late SettingsProvider settingsProvider;

    setUpAll(() async {
      // Load game mode configuration before running tests
      await GameModeConfig.instance.loadGameModes();
    });

    setUp(() {
      gameProvider = GameProvider();
      settingsProvider = SettingsProvider();
      
      // Disable First Click Guarantee for testing
      FeatureFlags.enableFirstClickGuarantee = false;
    });

    tearDown(() {
      gameProvider.dispose();
      settingsProvider.dispose();
    });

    Widget createTestApp({required Widget child}) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<GameProvider>.value(value: gameProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          ],
          child: Scaffold(body: child),
        ),
      );
    }

    group('GameBoard Rendering Tests', () {
      testWidgets('should display board with correct dimensions', (WidgetTester tester) async {
        gameProvider.testGameState = _createWinnableGameState();
        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        // Wait for board to initialize
        await tester.pumpAndSettle();

        // Verify board is displayed
        expect(find.byType(GameBoard), findsOneWidget);
        
        // Verify cells are displayed (should be 81 for 9x9 board)
        // Note: GameBoard has additional GestureDetectors for zoom and controls
        expect(find.byType(GestureDetector), findsNWidgets(84)); // 81 cells + 1 zoom + 2 buttons
      });

      testWidgets('should display game header with stats', (WidgetTester tester) async {
        gameProvider.testGameState = _createWinnableGameState();
        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        await tester.pumpAndSettle();

        // Verify game header elements are present
        expect(find.text('Mines'), findsOneWidget);
        expect(find.text('Time'), findsOneWidget);
        expect(find.text('Progress'), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);
        expect(find.byIcon(Icons.timer), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      });

      testWidgets('should display zoom controls', (WidgetTester tester) async {
        gameProvider.testGameState = _createWinnableGameState();
        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        await tester.pumpAndSettle();

        // Verify zoom controls are present
        expect(find.byIcon(Icons.zoom_in), findsOneWidget);
        expect(find.byIcon(Icons.zoom_out), findsOneWidget);
        expect(find.text('100%'), findsOneWidget);
      });

      testWidgets('should handle empty game state gracefully', (WidgetTester tester) async {
        // Create provider with no initial state
        final emptyProvider = GameProvider();

        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        // Don't use pumpAndSettle for empty state - just pump once
        await tester.pump();

        // Should not crash with empty state
        expect(emptyProvider.isGameOver, false);
        expect(emptyProvider.gameState?.revealedCount ?? 0, 0);
      });
    });

    group('Provider Integration Tests', () {
      testWidgets('should handle settings changes', (WidgetTester tester) async {
        gameProvider.testGameState = _createWinnableGameState();
        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        await tester.pumpAndSettle();

        // Toggle first click guarantee
        settingsProvider.toggleFirstClickGuarantee();
        await tester.pumpAndSettle();

        expect(settingsProvider.isFirstClickGuaranteeEnabled, true);
        expect(FeatureFlags.enableFirstClickGuarantee, true);
      });

      testWidgets('should handle game initialization', (WidgetTester tester) async {
        gameProvider.testGameState = _createWinnableGameState();
        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        await tester.pumpAndSettle();

        // Verify initial state
        expect(gameProvider.isGameInitialized, true);
        expect(gameProvider.isPlaying, true);
        expect(gameProvider.isGameOver, false);
        expect(gameProvider.gameState?.rows ?? 0, 9);
        expect(gameProvider.gameState?.columns ?? 0, 9);
        expect(gameProvider.gameState?.minesCount ?? 0, 1);
      });

      testWidgets('should handle different difficulty levels', (WidgetTester tester) async {
        // Test provider functionality directly without widget
        await gameProvider.initializeGame('normal');
        
        // Verify the game was initialized properly
        expect(gameProvider.isGameInitialized, true);
        expect(gameProvider.gameState?.rows ?? 0, 16);
        expect(gameProvider.gameState?.columns ?? 0, 16);
        expect(gameProvider.gameState?.minesCount ?? 0, 40);
        expect(gameProvider.gameState?.difficulty, 'normal');
      });

      testWidgets('should handle game statistics', (WidgetTester tester) async {
        // Test provider functionality directly without widget
        await gameProvider.initializeGame('easy');
        
        // Verify the game was initialized properly
        expect(gameProvider.isGameInitialized, true);
        expect(gameProvider.gameState?.difficulty, 'easy');
        
        final stats = gameProvider.getGameStatistics();
        
        expect(stats['difficulty'], 'easy');
        expect(stats['minesCount'], greaterThan(0));
        expect(stats['flaggedCount'], 0);
        expect(stats['isGameOver'], false);
        expect(stats['isWon'], false);
        expect(stats['isLost'], false);
      });

      testWidgets('should handle large board initialization', (WidgetTester tester) async {
        // Test provider functionality directly without widget
        await gameProvider.initializeGame('expert');
        
        // Verify the game was initialized properly
        expect(gameProvider.isGameInitialized, true);
        expect(gameProvider.gameState?.rows ?? 0, 18); // Expert mode has 18 rows
        expect(gameProvider.gameState?.columns ?? 0, 24); // Expert mode has 24 columns
        expect(gameProvider.gameState?.minesCount ?? 0, 115); // Expert mode has 115 mines
        expect(gameProvider.gameState?.difficulty, 'expert');
      });


    });

    group('Widget Error Handling Tests', () {
      testWidgets('should handle invalid cell positions gracefully', (WidgetTester tester) async {
        gameProvider.testGameState = _createWinnableGameState();
        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        await tester.pumpAndSettle();

        // Try to access invalid cell positions
        expect(() => gameProvider.getCell(-1, -1), returnsNormally);
        expect(() => gameProvider.getCell(100, 100), returnsNormally);
        
        // Should return null for invalid positions
        expect(gameProvider.getCell(-1, -1), null);
        expect(gameProvider.getCell(100, 100), null);
      });
    });

    group('Performance and Memory Tests', () {
      testWidgets('should handle rapid state changes', (WidgetTester tester) async {
        gameProvider.testGameState = _createWinnableGameState();
        await tester.pumpWidget(createTestApp(
          child: GameBoard(),
        ));

        await tester.pumpAndSettle();

        // Rapidly change game state
        for (int i = 0; i < 5; i++) {
          await gameProvider.initializeGame('easy');
          await tester.pump(Duration(milliseconds: 10));
        }

        await tester.pumpAndSettle();

        // Should handle rapid state changes without crashing
        expect(gameProvider.isGameInitialized, true);
      });
    });
  });
}

// Helper methods to create test game states
GameState _createWinnableGameState() {
  final board = List.generate(9, (row) => 
    List.generate(9, (col) => Cell(row: row, col: col, hasBomb: false))
  );
  
  // Add one mine in the corner
  board[0][0] = board[0][0].copyWith(hasBomb: true);
  
  // Set bomb counts for safe cells
  for (int row = 0; row < 9; row++) {
    for (int col = 0; col < 9; col++) {
      if (!board[row][col].hasBomb) {
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = row + dr;
            final nc = col + dc;
            if (nr >= 0 && nr < 9 && nc >= 0 && nc < 9) {
              if (board[nr][nc].hasBomb) count++;
            }
          }
        }
        board[row][col] = board[row][col].copyWith(bombsAround: count);
      }
    }
  }

  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 1,
    flaggedCount: 0,
    revealedCount: 0,
    totalCells: 81,
    startTime: DateTime.now(),
    difficulty: 'easy',
  );
} 