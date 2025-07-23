import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';

void main() {
  group('Game Logic Integration Tests', () {
    late GameRepositoryImpl repository;

    setUp(() {
      repository = GameRepositoryImpl();
    });

    test('Complete game flow with deterministic board', () async {
      // Create a deterministic game state
      final testState = _createDeterministicGameState();
      repository.setTestState(testState);
      
      // Test initial state
      expect(repository.isGameWon(), false);
      expect(repository.isGameLost(), false);
      expect(repository.getRemainingMines(), 2);
      
      // Reveal a safe cell (should cascade)
      final result = await repository.revealCell(1, 1);
      
      expect(result.isPlaying, true);
      expect(result.revealedCount, greaterThan(0));
      expect(result.isGameOver, false);
      
      // Verify cascade worked
      final cell = result.getCell(1, 1);
      expect(cell.isRevealed, true);
      expect(cell.isExploded, false);
    });

    test('Win scenario with deterministic board', () async {
      // Create a board where we can win by revealing all safe cells
      final testState = _createWinnableGameState();
      repository.setTestState(testState);
      
      // Reveal all safe cells
      for (int row = 0; row < testState.rows; row++) {
        for (int col = 0; col < testState.columns; col++) {
          final cell = testState.getCell(row, col);
          if (!cell.hasBomb) {
            await repository.revealCell(row, col);
          }
        }
      }
      
      final finalState = repository.getCurrentState();
      expect(finalState.isWon, true);
      expect(finalState.isGameOver, true);
      expect(finalState.isPlaying, false);
    });

    test('Loss scenario with deterministic board', () async {
      // Create a board where clicking any cell loses
      final testState = _createLoseableGameState();
      repository.setTestState(testState);
      
      // Disable first click guarantee for this test
      final originalFlag = FeatureFlags.enableFirstClickGuarantee;
      FeatureFlags.enableFirstClickGuarantee = false;
      
      try {
        // Click on a mine
        final result = await repository.revealCell(0, 0);
        
        // Debug: print the actual result
        print('Game status: ${result.gameStatus}');
        print('Is lost: ${result.isLost}');
        print('Is game over: ${result.isGameOver}');
        
        expect(result.isLost, true);
        expect(result.isGameOver, true);
        expect(result.isPlaying, false);
        
        // Verify the hit bomb is marked correctly
        final hitCell = result.getCell(0, 0);
        expect(hitCell.isHitBomb, true);
      } finally {
        // Restore the original flag
        FeatureFlags.enableFirstClickGuarantee = originalFlag;
      }
    });

    test('Flag management integration', () async {
      final testState = _createDeterministicGameState();
      repository.setTestState(testState);
      
      // Flag a cell
      var result = await repository.toggleFlag(0, 0);
      expect(result.flaggedCount, 1);
      expect(result.remainingMines, 1);
      
      // Unflag the cell
      result = await repository.toggleFlag(0, 0);
      expect(result.flaggedCount, 0);
      expect(result.remainingMines, 2);
    });

    test('Chord functionality integration', () async {
      // Create a board with a revealed numbered cell
      final testState = _createChordableGameState();
      repository.setTestState(testState);
      
      // Chord on a revealed numbered cell with correct flags
      final result = await repository.chordCell(1, 1);
      
      // Should reveal unflagged neighbors
      expect(result.revealedCount, greaterThan(0));
    });

    test('Game statistics integration', () async {
      final testState = _createDeterministicGameState();
      repository.setTestState(testState);
      
      // Make some moves
      await repository.revealCell(1, 1);
      await repository.toggleFlag(0, 0);
      
      final stats = repository.getGameStatistics();
      
      expect(stats['difficulty'], 'easy');
      expect(stats['minesCount'], 2);
      expect(stats['flaggedCount'], 1);
      expect(stats['isGameOver'], false);
      expect(stats['isWon'], false);
      expect(stats['isLost'], false);
    });

    test('Error handling integration', () async {
      final testState = _createDeterministicGameState();
      repository.setTestState(testState);
      
      // Test invalid position
      expect(() => repository.revealCell(-1, -1), throwsRangeError);
      expect(() => repository.revealCell(10, 10), throwsRangeError);
    });
  });
}

// Helper methods to create deterministic test game states
GameState _createDeterministicGameState() {
  // 3x3 board with 2 mines in corners
  final board = List.generate(3, (row) => 
    List.generate(3, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: (row == 0 && col == 0) || (row == 2 && col == 2), // Mines in corners
      bombsAround: _calculateBombsAround(row, col, [
        [0, 0], [2, 2] // Mine positions
      ]),
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 2,
    flaggedCount: 0,
    revealedCount: 0,
    totalCells: 9,
    difficulty: 'easy',
  );
}

GameState _createWinnableGameState() {
  // 3x3 board with no mines
  final board = List.generate(3, (row) => 
    List.generate(3, (col) => Cell(
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
    totalCells: 9,
    difficulty: 'easy',
  );
}

GameState _createLoseableGameState() {
  // 3x3 board with all mines
  final board = List.generate(3, (row) => 
    List.generate(3, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: true,
      bombsAround: 0,
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 9,
    flaggedCount: 0,
    revealedCount: 0,
    totalCells: 9,
    difficulty: 'easy',
  );
}

GameState _createChordableGameState() {
  // Create a board with a revealed numbered cell and some flags
  final board = List.generate(3, (row) => 
    List.generate(3, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: (row == 0 && col == 0) || (row == 0 && col == 1), // 2 mines
      bombsAround: _calculateBombsAround(row, col, [
        [0, 0], [0, 1] // Mine positions
      ]),
      state: row == 1 && col == 1 ? CellState.revealed : CellState.unrevealed, // Center revealed
    ))
  );
  
  // Set one flag
  board[0][0].state = CellState.flagged;
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 2,
    flaggedCount: 1,
    revealedCount: 1,
    totalCells: 9,
    difficulty: 'easy',
  );
}

int _calculateBombsAround(int row, int col, List<List<int>> minePositions) {
  if (minePositions.any((pos) => pos[0] == row && pos[1] == col)) {
    return 0; // This cell is a mine
  }
  
  int count = 0;
  for (int dr = -1; dr <= 1; dr++) {
    for (int dc = -1; dc <= 1; dc++) {
      if (dr == 0 && dc == 0) continue;
      final nr = row + dr;
      final nc = col + dc;
      if (nr >= 0 && nr < 3 && nc >= 0 && nc < 3) {
        if (minePositions.any((pos) => pos[0] == nr && pos[1] == nc)) {
          count++;
        }
      }
    }
  }
  return count;
} 