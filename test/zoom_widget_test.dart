import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/presentation/pages/game_page.dart';
import 'package:flutter_minesweeper/presentation/providers/game_provider.dart';
import 'package:flutter_minesweeper/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';
import 'package:flutter_minesweeper/services/timer_service.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() async {
    // Load config once for all tests
    await GameModeConfig.instance.loadGameModes();
  });
  
  testWidgets('Zoom controls change board scale', (WidgetTester tester) async {
    final gameProvider = GameProvider();
    // Use test state instead of real initialization to avoid hanging
    gameProvider.testGameState = _createTestGameState();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerService()),
          ChangeNotifierProvider.value(value: gameProvider),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: const MaterialApp(home: GamePage()),
      ),
    );

    // Wait for the board to load
    await tester.pumpAndSettle();

    // Find the zoom in and zoom out buttons
    final zoomInButton = find.byIcon(Icons.zoom_in);
    final zoomOutButton = find.byIcon(Icons.zoom_out);
    expect(zoomInButton, findsOneWidget);
    expect(zoomOutButton, findsOneWidget);

    // Find the GridView (the actual board)
    final gridView = find.byType(GridView);
    expect(gridView, findsOneWidget);
    
    // Get initial grid delegate
    final initialGridDelegate = tester.widget<GridView>(gridView).gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    double initialSpacing = initialGridDelegate.mainAxisSpacing;

    // Tap zoom in
    await tester.tap(zoomInButton);
    await tester.pumpAndSettle();
    
    // Get updated grid delegate
    final zoomedInGridDelegate = tester.widget<GridView>(gridView).gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    double zoomedInSpacing = zoomedInGridDelegate.mainAxisSpacing;
    expect(zoomedInSpacing, greaterThan(initialSpacing));

    // Tap zoom out
    await tester.tap(zoomOutButton);
    await tester.pumpAndSettle();
    
    // Get final grid delegate
    final zoomedOutGridDelegate = tester.widget<GridView>(gridView).gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    double zoomedOutSpacing = zoomedOutGridDelegate.mainAxisSpacing;
    expect(zoomedOutSpacing, lessThanOrEqualTo(zoomedInSpacing));
  });

  testWidgets('Zoom controls remain visible when zoomed in', (WidgetTester tester) async {
    final gameProvider = GameProvider();
    // Use test state instead of real initialization to avoid hanging
    gameProvider.testGameState = _createTestGameState();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TimerService()),
          ChangeNotifierProvider.value(value: gameProvider),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ],
        child: MaterialApp(
          home: GamePage(),
        ),
      ),
    );

    // Wait for the board to load
    await tester.pumpAndSettle();

    // Find zoom controls
    final zoomInButton = find.byIcon(Icons.zoom_in);
    final zoomOutButton = find.byIcon(Icons.zoom_out);
    
    // Zoom in multiple times
    for (int i = 0; i < 5; i++) {
      await tester.tap(zoomInButton);
      await tester.pumpAndSettle();
    }

    // Verify zoom controls are still visible
    expect(find.byIcon(Icons.zoom_in), findsOneWidget);
    expect(find.byIcon(Icons.zoom_out), findsOneWidget);
  });
}

// Helper method to create test game state
GameState _createTestGameState() {
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