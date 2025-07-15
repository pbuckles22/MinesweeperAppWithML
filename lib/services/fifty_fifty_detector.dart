import '../domain/entities/game_state.dart';
import '../domain/entities/cell.dart';
import '../core/feature_flags.dart';

/// Represents a 50/50 situation where two cells have equal probability
class FiftyFiftySituation {
  final int row1;
  final int col1;
  final int row2;
  final int col2;
  final int triggerRow; // The revealed numbered cell that triggered this 50/50
  final int triggerCol;
  final int number; // The number on the trigger cell

  const FiftyFiftySituation({
    required this.row1,
    required this.col1,
    required this.row2,
    required this.col2,
    required this.triggerRow,
    required this.triggerCol,
    required this.number,
  });

  @override
  String toString() {
    return '50/50: ($row1,$col1) vs ($row2,$col2) triggered by ($triggerRow,$triggerCol) with number $number';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FiftyFiftySituation &&
        ((row1 == other.row1 && col1 == other.col1 && row2 == other.row2 && col2 == other.col2) ||
         (row1 == other.row2 && col1 == other.col2 && row2 == other.row1 && col2 == other.col1)) &&
        triggerRow == other.triggerRow &&
        triggerCol == other.triggerCol &&
        number == other.number;
  }

  @override
  int get hashCode {
    return Object.hash(row1, col1, row2, col2, triggerRow, triggerCol, number);
  }
}

/// Service for detecting 50/50 situations in Minesweeper
class FiftyFiftyDetector {
  /// Detects all 50/50 situations on the current board
  static List<FiftyFiftySituation> detect5050Situations(GameState gameState) {
    if (!FeatureFlags.enable5050Detection) {
      return [];
    }

    final situations = <FiftyFiftySituation>[];
    final rows = gameState.rows;
    final cols = gameState.columns;

    // Check each revealed numbered cell for potential 50/50 situations
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cell = gameState.getCell(row, col);
        
        // Only check revealed numbered cells (not empty cells)
        if (!cell.isRevealed || cell.hasBomb || cell.bombsAround == 0) {
          continue;
        }

        final situation = _checkForClassic5050(gameState, row, col);
        if (situation != null) {
          situations.add(situation);
          // Return immediately after finding the first valid 50/50
          return situations;
        }
      }
    }

    return situations;
  }

  /// Checks for classic 50/50 pattern: exactly 2 unrevealed neighbors with exactly 1 remaining mine
  static FiftyFiftySituation? _checkForClassic5050(GameState gameState, int row, int col) {
    final cell = gameState.getCell(row, col);
    final number = cell.bombsAround;
    
    // Get all unrevealed, unflagged neighbors
    final unrevealedNeighbors = <List<int>>[];
    int flaggedCount = 0;
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (nr < 0 || nr >= gameState.rows || nc < 0 || nc >= gameState.columns) {
          continue;
        }
        final neighbor = gameState.getCell(nr, nc);
        if (neighbor.isFlagged) {
          flaggedCount++;
        } else if (!neighbor.isRevealed) {
          unrevealedNeighbors.add([nr, nc]);
        }
      }
    }
    
    // Classic 50/50: exactly 2 unrevealed cells and exactly 1 remaining mine
    final remainingMines = number - flaggedCount;
    if (unrevealedNeighbors.length == 2 && remainingMines == 1) {
      final cell1 = unrevealedNeighbors[0];
      final cell2 = unrevealedNeighbors[1];
      
      return FiftyFiftySituation(
        row1: cell1[0],
        col1: cell1[1],
        row2: cell2[0],
        col2: cell2[1],
        triggerRow: row,
        triggerCol: col,
        number: number,
      );
    }
    
    return null;
  }

  /// Checks if a specific cell is part of any 50/50 situation
  static bool isCellIn5050Situation(GameState gameState, int row, int col) {
    if (!FeatureFlags.enable5050Detection) {
      return false;
    }

    final situations = detect5050Situations(gameState);
    return situations.any((situation) =>
        (situation.row1 == row && situation.col1 == col) ||
        (situation.row2 == row && situation.col2 == col));
  }

  /// Gets all 50/50 situations involving a specific cell
  static List<FiftyFiftySituation> get5050SituationsForCell(GameState gameState, int row, int col) {
    if (!FeatureFlags.enable5050Detection) {
      return [];
    }

    final situations = detect5050Situations(gameState);
    return situations.where((situation) =>
        (situation.row1 == row && situation.col1 == col) ||
        (situation.row2 == row && situation.col2 == col)).toList();
  }



  /// Helper method to check if two cells are adjacent
  static bool _isAdjacent(int row1, int col1, int row2, int col2) {
    return (row1 - row2).abs() <= 1 && (col1 - col2).abs() <= 1 && !(row1 == row2 && col1 == col2);
  }


} 