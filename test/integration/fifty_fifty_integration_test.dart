import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/services/fifty_fifty_detector.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';

void main() {
  group('50/50 Detection Integration Tests', () {
    setUp(() {
      // Enable 50/50 detection for all tests
      FeatureFlags.enable5050Detection = true;
    });

    test('Classic 50/50 scenario detection', () async {
      // Create a classic 50/50 scenario: exactly 2 unrevealed neighbors with exactly 1 remaining mine
      final gameState = _createClassic5050Scenario();
      
      // Debug: Print the board state
      print('Board state:');
      for (int row = 0; row < gameState.rows; row++) {
        String rowStr = '';
        for (int col = 0; col < gameState.columns; col++) {
          final cell = gameState.getCell(row, col);
          if (cell.isRevealed) {
            rowStr += '${cell.bombsAround} ';
          } else if (cell.isFlagged) {
            rowStr += 'F ';
          } else {
            rowStr += '. ';
          }
        }
        print('Row $row: $rowStr');
      }
      
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      
      print('Detected situations: ${situations.length}');
      for (final situation in situations) {
        print('  ${situation}');
      }
      
      expect(situations.length, 1);
      expect(situations.first.row1, 1);
      expect(situations.first.col1, 1);
      expect(situations.first.row2, 1);
      expect(situations.first.col2, 2);
      expect(situations.first.number, 1);
    });

    test('Shared constraint 50/50 scenario detection', () async {
      // Create a shared constraint 50/50 scenario
      final gameState = _createSharedConstraint5050Scenario();
      
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      
      expect(situations.length, 1);
      expect(situations.first.number, greaterThan(0));
    });

    test('No 50/50 detection when not present', () async {
      // Create a board with no 50/50 situations
      final gameState = _createNo5050Scenario();
      
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      
      expect(situations.length, 0);
    });

    test('50/50 detection with multiple constraints', () async {
      // Create a complex scenario with multiple constraints
      final gameState = _createComplex5050Scenario();
      
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      
      expect(situations.length, greaterThan(0));
      
      // Verify that detected situations are valid
      for (final situation in situations) {
        expect(situation.number, greaterThan(0));
        expect(situation.row1, greaterThanOrEqualTo(0));
        expect(situation.col1, greaterThanOrEqualTo(0));
        expect(situation.row2, greaterThanOrEqualTo(0));
        expect(situation.col2, greaterThanOrEqualTo(0));
      }
    });

    test('Cell-specific 50/50 detection', () async {
      // Test detection for specific cells
      final gameState = _createClassic5050Scenario();
      
      // Test cell that should be in 50/50
      final isIn5050 = FiftyFiftyDetector.isCellIn5050Situation(gameState, 1, 1);
      expect(isIn5050, true);
      
      // Test cell that should not be in 50/50
      final isNotIn5050 = FiftyFiftyDetector.isCellIn5050Situation(gameState, 0, 0);
      expect(isNotIn5050, false);
    });

    test('50/50 situations for specific cell', () async {
      // Test getting 50/50 situations for a specific cell
      final gameState = _createClassic5050Scenario();
      
      final situations = FiftyFiftyDetector.get5050SituationsForCell(gameState, 1, 1);
      
      expect(situations.length, 1);
      expect(situations.first.row1, 1);
      expect(situations.first.col1, 1);
      expect(situations.first.row2, 1);
      expect(situations.first.col2, 2);
    });

    test('50/50 detection with flags', () async {
      // Test 50/50 detection when some cells are flagged
      final gameState = _create5050WithFlagsScenario();
      
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      
      // Should NOT detect 50/50 when candidate cells are flagged
      expect(situations.length, 0);
    });

    test('50/50 detection disabled when feature flag is off', () async {
      // Test that detection is disabled when feature flag is off
      FeatureFlags.enable5050Detection = false;
      
      final gameState = _createClassic5050Scenario();
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      
      expect(situations.length, 0);
      
      // Re-enable for other tests
      FeatureFlags.enable5050Detection = true;
    });

    test('50/50 detection on large board', () async {
      // Test 50/50 detection performance on a larger board
      final gameState = _createLargeBoard5050Scenario();
      
      final stopwatch = Stopwatch()..start();
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      stopwatch.stop();
      
      print('50/50 detection on large board: ${stopwatch.elapsedMilliseconds}ms');
      
      // Should complete within reasonable time (under 50ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      
      // Should find some situations
      expect(situations.length, greaterThan(0));
    });

    test('50/50 number validation', () async {
      // Test that number values are reasonable
      final gameState = _createClassic5050Scenario();
      
      final situations = FiftyFiftyDetector.detect5050Situations(gameState);
      
      for (final situation in situations) {
        expect(situation.number, greaterThan(0));
        expect(situation.number, lessThanOrEqualTo(8));
      }
    });
  });
}

// Helper methods to create test scenarios
GameState _createClassic5050Scenario() {
  // Create a 3x3 board with a classic 50/50 scenario
  // Center cell (1,1) has number 1 with exactly 2 unrevealed neighbors
  final board = List.generate(3, (row) => 
    List.generate(3, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: false,
      bombsAround: _getClassic5050BombsAround(row, col),
      state: _getClassic5050CellState(row, col),
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 1,
    flaggedCount: 0,
    revealedCount: 4,
    totalCells: 9,
    difficulty: 'easy',
  );
}

GameState _createSharedConstraint5050Scenario() {
  // Create a board with shared constraint 50/50
  // Two revealed cells (1,1) and (1,2) both constrain the same two unrevealed cells (0,1) and (2,1)
  final board = List.generate(4, (row) => 
    List.generate(4, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: false,
      bombsAround: _getSharedConstraintBombsAround(row, col),
      state: _getSharedConstraintCellState(row, col),
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 2,
    flaggedCount: 0,
    revealedCount: 8,
    totalCells: 16,
    difficulty: 'normal',
  );
}

GameState _createNo5050Scenario() {
  // Create a board with no 50/50 situations
  final board = List.generate(3, (row) => 
    List.generate(3, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: false,
      bombsAround: 0,
      state: CellState.unrevealed,
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

GameState _createComplex5050Scenario() {
  // Create a complex board with multiple 50/50 situations
  final board = List.generate(5, (row) => 
    List.generate(5, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: false,
      bombsAround: _getComplexBombsAround(row, col),
      state: _getComplexCellState(row, col),
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 3,
    flaggedCount: 0,
    revealedCount: 15,
    totalCells: 25,
    difficulty: 'normal',
  );
}

GameState _create5050WithFlagsScenario() {
  // Create a 50/50 scenario with some flags
  // This creates a classic 50/50 where one of the candidate cells is flagged
  final board = List.generate(3, (row) => 
    List.generate(3, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: false,
      bombsAround: _getClassic5050BombsAround(row, col),
      state: _get5050WithFlagsCellState(row, col),
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 1,
    flaggedCount: 1,
    revealedCount: 3,
    totalCells: 9,
    difficulty: 'easy',
  );
}

GameState _createLargeBoard5050Scenario() {
  // Create a larger board with 50/50 situations
  // Create a classic 50/50 pattern in the center of the board
  final board = List.generate(10, (row) => 
    List.generate(10, (col) => Cell(
      row: row, 
      col: col, 
      hasBomb: false,
      bombsAround: _getLargeBoardBombsAround(row, col),
      state: _getLargeBoardCellState(row, col),
    ))
  );
  
  return GameState(
    board: board,
    gameStatus: 'playing',
    minesCount: 10,
    flaggedCount: 2,
    revealedCount: 60,
    totalCells: 100,
    difficulty: 'hard',
  );
}

// Helper methods for cell states and bomb counts
int _getClassic5050BombsAround(int row, int col) {
  // Center cell (1,1) has number 1, others have 0
  if (row == 1 && col == 1) return 1;
  return 0;
}

CellState _getClassic5050CellState(int row, int col) {
  // Reveal cells around the 50/50 situation (center cell and its neighbors)
  // Center cell (1,1) is revealed with number 1
  // Neighbors (0,1), (1,0), (1,2), (2,1) are revealed
  // Only (0,0) and (0,2) remain unrevealed - this creates a classic 50/50
  if (row == 1 && col == 1) {
    return CellState.revealed; // Center cell revealed
  } else if ((row == 0 && col == 1) || (row == 1 && col == 0) || 
             (row == 1 && col == 2) || (row == 2 && col == 1)) {
    return CellState.revealed; // Adjacent cells revealed
  } else if ((row == 2 && col == 0) || (row == 2 && col == 2)) {
    return CellState.revealed; // Reveal bottom cells to leave only 2 unrevealed
  }
  return CellState.unrevealed; // Only (0,0) and (0,2) remain unrevealed
}

int _getSharedConstraintBombsAround(int row, int col) {
  // Create shared constraint scenario
  // Cell (1,1) has number 1, cell (1,2) has number 1
  // Both constrain the same two cells (0,1) and (2,1)
  if (row == 1 && col == 1) return 1;
  if (row == 1 && col == 2) return 1;
  return 0;
}

CellState _getSharedConstraintCellState(int row, int col) {
  // Reveal cells to create shared constraint scenario
  // Reveal cells (1,1) and (1,2) - these will constrain (0,1) and (2,1)
  // Reveal other cells to block the candidate cells
  if (row == 1 && (col == 1 || col == 2)) {
    return CellState.revealed; // The two revealed cells that create the constraint
  } else if ((row == 0 && col == 0) || (row == 0 && col == 2) || 
             (row == 2 && col == 0) || (row == 2 && col == 2)) {
    return CellState.revealed; // Block the candidate cells
  }
  return CellState.unrevealed; // (0,1) and (2,1) remain unrevealed
}

int _getComplexBombsAround(int row, int col) {
  // Create complex scenario with multiple constraints
  if (row == 2 && col == 2) return 2;
  if (row == 2 && col == 3) return 1;
  if (row == 3 && col == 2) return 1;
  if (row == 3 && col == 3) return 2;
  return 0;
}

CellState _getComplexCellState(int row, int col) {
  // Reveal cells in a pattern for complex scenario
  if ((row + col) % 3 == 0 && row < 4 && col < 4) {
    return CellState.revealed;
  }
  return CellState.unrevealed;
}

CellState _get5050WithFlagsCellState(int row, int col) {
  // Create a scenario where one of the candidate cells is flagged
  // This should NOT create a 50/50 because flagged cells are excluded
  if (row == 0 && col == 0) {
    return CellState.flagged; // Flag one of the candidate cells
  } else if (row == 1 && col == 1) {
    return CellState.revealed; // Center cell revealed
  } else if ((row == 0 && col == 1) || (row == 1 && col == 0) || (row == 2 && col == 1)) {
    return CellState.revealed; // Adjacent cells revealed
  }
  return CellState.unrevealed; // (0,2) and (2,0) remain unrevealed
}

int _getLargeBoardBombsAround(int row, int col) {
  // Create bomb counts for large board scenario
  // Create a classic 50/50 pattern in the center
  if (row == 5 && col == 5) return 1; // Center cell with number 1
  return 0;
}

CellState _getLargeBoardCellState(int row, int col) {
  // Reveal cells in a pattern for large board
  // Create a classic 50/50 pattern in the center (around cell 5,5)
  if (row == 5 && col == 5) {
    return CellState.revealed; // Center cell revealed
  } else if ((row == 4 && col == 5) || (row == 5 && col == 4) || 
             (row == 5 && col == 6) || (row == 6 && col == 5)) {
    return CellState.revealed; // Adjacent cells revealed
  } else if ((row + col) % 4 == 0 && row < 8 && col < 8) {
    return CellState.revealed; // Other cells revealed in pattern
  }
  return CellState.unrevealed; // (4,4) and (4,6) remain unrevealed - classic 50/50
} 