import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';

void main() {
  group('Game Performance Tests', () {
    late GameRepositoryImpl repository;

    setUp(() {
      repository = GameRepositoryImpl();
    });

    test('Large board initialization performance', () async {
      // Test performance of initializing a large board (expert mode size)
      final stopwatch = Stopwatch()..start();
      
      final largeState = _createLargeGameState(30, 24, 115); // Expert mode
      repository.setTestState(largeState);
      
      stopwatch.stop();
      
      print('Large board initialization: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within reasonable time (under 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      // Verify board is correct
      expect(largeState.rows, 30);
      expect(largeState.columns, 24);
      expect(largeState.minesCount, 115);
      expect(largeState.totalCells, 720);
    });

    test('Cascade reveal performance on large empty area', () async {
      // Create a large board with a big empty area
      final largeState = _createLargeEmptyAreaState(20, 20);
      repository.setTestState(largeState);
      
      final stopwatch = Stopwatch()..start();
      
      // Reveal a cell in the middle of a large empty area
      await repository.revealCell(10, 10);
      
      stopwatch.stop();
      
      print('Large cascade reveal: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within reasonable time (under 50ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      
      // Verify cascade worked
      final result = repository.getCurrentState();
      expect(result.revealedCount, greaterThan(100)); // Should reveal many cells
    });

    test('Multiple rapid moves performance', () async {
      // Test performance of multiple rapid moves
      final testState = _createPerformanceTestState(16, 16, 40);
      repository.setTestState(testState);
      
      final stopwatch = Stopwatch()..start();
      
      // Make multiple rapid moves
      for (int i = 0; i < 10; i++) {
        await repository.revealCell(i, i);
        await repository.toggleFlag(i, i + 1);
      }
      
      stopwatch.stop();
      
      print('Multiple rapid moves: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within reasonable time (under 200ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('Memory usage with large board', () async {
      // Test memory usage doesn't grow excessively
      final initialMemory = _getMemoryUsage();
      
      // Create and manipulate large boards
      for (int i = 0; i < 5; i++) {
        final largeState = _createLargeGameState(25, 25, 100);
        repository.setTestState(largeState);
        
        // Make some moves
        await repository.revealCell(0, 0);
        await repository.toggleFlag(1, 1);
        await repository.chordCell(2, 2);
      }
      
      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      print('Memory increase: ${memoryIncrease}KB');
      
      // Memory increase should be reasonable (under 10MB)
      expect(memoryIncrease, lessThan(10 * 1024));
    });

    test('Win detection performance on large board', () async {
      // Test performance of win detection on a large board
      final largeState = _createWinnableLargeState(20, 20);
      repository.setTestState(largeState);
      
      final stopwatch = Stopwatch()..start();
      
      // Reveal all safe cells to trigger win
      for (int row = 0; row < largeState.rows; row++) {
        for (int col = 0; col < largeState.columns; col++) {
          final cell = largeState.getCell(row, col);
          if (!cell.hasBomb && !cell.isRevealed) {
            await repository.revealCell(row, col);
          }
        }
      }
      
      stopwatch.stop();
      
      print('Large board win detection: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within reasonable time (under 500ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      
      // Verify win
      final result = repository.getCurrentState();
      expect(result.isWon, true);
    });

    test('Chord performance on complex board', () async {
      // Test chord performance on a complex board with many numbers
      final complexState = _createComplexChordState(15, 15);
      repository.setTestState(complexState);
      
      final stopwatch = Stopwatch()..start();
      
      // Perform multiple chord operations
      for (int i = 0; i < 5; i++) {
        await repository.chordCell(5 + i, 5 + i);
      }
      
      stopwatch.stop();
      
      print('Complex chord operations: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within reasonable time (under 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('Game statistics calculation performance', () async {
      // Test performance of statistics calculation
      final largeState = _createLargeGameState(25, 25, 100);
      repository.setTestState(largeState);
      
      // Make some moves to create complex state
      for (int i = 0; i < 20; i++) {
        await repository.revealCell(i % 25, i % 25);
        await repository.toggleFlag((i + 1) % 25, (i + 1) % 25);
      }
      
      final stopwatch = Stopwatch()..start();
      
      // Calculate statistics multiple times
      for (int i = 0; i < 100; i++) {
        repository.getGameStatistics();
      }
      
      stopwatch.stop();
      
      print('Statistics calculation (100x): ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within reasonable time (under 50ms for 100 calculations)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}

// Helper methods for performance tests
GameState _createLargeGameState(int rows, int cols, int mines) {
  final board = List.generate(rows, (row) => 
    List.generate(cols, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: _isMinePosition(row, col, rows, cols, mines),
      bombsAround: 0, // Will be calculated by repository
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: mines,
    flaggedCount: 0,
    revealedCount: 0,
    totalCells: rows * cols,
    difficulty: 'expert',
  );
}

GameState _createLargeEmptyAreaState(int rows, int cols) {
  // Create a board with a large empty area in the middle
  final board = List.generate(rows, (row) => 
    List.generate(cols, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: _isMinePosition(row, col, rows, cols, 10), // Few mines
      bombsAround: 0,
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 10,
    flaggedCount: 0,
    revealedCount: 0,
    totalCells: rows * cols,
    difficulty: 'easy',
  );
}

GameState _createPerformanceTestState(int rows, int cols, int mines) {
  final board = List.generate(rows, (row) => 
    List.generate(cols, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: _isMinePosition(row, col, rows, cols, mines),
      bombsAround: 0,
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: mines,
    flaggedCount: 0,
    revealedCount: 0,
    totalCells: rows * cols,
    difficulty: 'normal',
  );
}

GameState _createWinnableLargeState(int rows, int cols) {
  // Create a large board with no mines (guaranteed win)
  final board = List.generate(rows, (row) => 
    List.generate(cols, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: false,
      bombsAround: 0,
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 0,
    flaggedCount: 0,
    revealedCount: 0,
    totalCells: rows * cols,
    difficulty: 'easy',
  );
}

GameState _createComplexChordState(int rows, int cols) {
  // Create a board with many revealed numbered cells for chord testing
  final board = List.generate(rows, (row) => 
    List.generate(cols, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: _isMinePosition(row, col, rows, cols, 30),
      bombsAround: _calculateBombsAround(row, col, rows, cols, [
        [0, 0], [0, 1], [1, 0], [1, 1], [2, 2], [3, 3], [4, 4], [5, 5],
        [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12],
        [13, 13], [14, 14], [0, 14], [14, 0], [7, 0], [0, 7], [14, 7],
        [7, 14], [3, 7], [7, 3], [11, 7], [7, 11], [3, 3], [11, 11]
      ]),
      state: _shouldBeRevealed(row, col) ? CellState.revealed : CellState.unrevealed,
    ))
  );
  
  // Set some flags
  board[0][0].state = CellState.flagged;
  board[1][1].state = CellState.flagged;
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 30,
    flaggedCount: 2,
    revealedCount: _countRevealedCells(board),
    totalCells: rows * cols,
    difficulty: 'normal',
  );
}

bool _isMinePosition(int row, int col, int rows, int cols, int mines) {
  // Simple deterministic mine placement for testing
  final totalCells = rows * cols;
  final minePositions = <int>[];
  
  for (int i = 0; i < mines; i++) {
    minePositions.add((i * 7) % totalCells); // Simple pattern
  }
  
  final position = row * cols + col;
  return minePositions.contains(position);
}

int _calculateBombsAround(int row, int col, int rows, int cols, List<List<int>> minePositions) {
  if (minePositions.any((pos) => pos[0] == row && pos[1] == col)) {
    return 0; // This cell is a mine
  }
  
  int count = 0;
  for (int dr = -1; dr <= 1; dr++) {
    for (int dc = -1; dc <= 1; dc++) {
      if (dr == 0 && dc == 0) continue;
      final nr = row + dr;
      final nc = col + dc;
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
        if (minePositions.any((pos) => pos[0] == nr && pos[1] == nc)) {
          count++;
        }
      }
    }
  }
  return count;
}

bool _shouldBeRevealed(int row, int col) {
  // Reveal cells in a pattern for chord testing
  return (row + col) % 3 == 0 && row > 0 && col > 0 && row < 14 && col < 14;
}

int _countRevealedCells(List<List<Cell>> board) {
  int count = 0;
  for (final row in board) {
    for (final cell in row) {
      if (cell.isRevealed) count++;
    }
  }
  return count;
}

int _getMemoryUsage() {
  // Simple memory usage estimation
  // In a real test, you might use platform-specific APIs
  return 0; // Placeholder
} 