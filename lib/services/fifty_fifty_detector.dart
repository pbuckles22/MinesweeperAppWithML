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

        final situation = _checkFor5050AroundCell(gameState, row, col);
        if (situation != null) {
          situations.add(situation);
        }
      }
    }

    return situations;
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

  /// Checks if there's a 50/50 situation around a specific revealed numbered cell
  static FiftyFiftySituation? _checkFor5050AroundCell(GameState gameState, int row, int col) {
    final cell = gameState.getCell(row, col);
    final number = cell.bombsAround;
    
    // Get all unrevealed, unflagged neighbors
    final unrevealedNeighbors = <List<int>>[];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        final nr = row + dr;
        final nc = col + dc;
        
        if (nr < 0 || nr >= gameState.rows || nc < 0 || nc >= gameState.columns) {
          continue;
        }
        
        final neighbor = gameState.getCell(nr, nc);
        if (!neighbor.isRevealed && !neighbor.isFlagged) {
          unrevealedNeighbors.add([nr, nc]);
        }
      }
    }
    
    // Count flagged neighbors
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
        }
      }
    }
    
    // Check if this could be a 50/50 situation
    // A 50/50 occurs when:
    // 1. Exactly 2 unrevealed cells remain
    // 2. The number minus flagged count equals 2
    // 3. Both cells have equal probability (no logical deduction possible)
    
    final remainingMines = number - flaggedCount;
    if (unrevealedNeighbors.length == 2 && remainingMines == 2) {
      // Check if both cells have equal probability by analyzing their neighbors
      final cell1 = unrevealedNeighbors[0];
      final cell2 = unrevealedNeighbors[1];
      
      if (_cellsHaveEqualProbability(gameState, cell1[0], cell1[1], cell2[0], cell2[1])) {
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
    }
    
    return null;
  }

  /// Determines if two cells have equal probability of being mines
  /// This is a simplified check - in a full implementation, this would use
  /// constraint satisfaction or other advanced algorithms
  static bool _cellsHaveEqualProbability(GameState gameState, int row1, int col1, int row2, int col2) {
    // For now, we'll use a simple heuristic:
    // If both cells are adjacent to the same revealed numbered cells with the same constraints,
    // they likely have equal probability
    
    final neighbors1 = _getRevealedNumberedNeighbors(gameState, row1, col1);
    final neighbors2 = _getRevealedNumberedNeighbors(gameState, row2, col2);
    
    // If they share the same revealed numbered neighbors, they likely have equal probability
    if (neighbors1.length == neighbors2.length) {
      for (final neighbor1 in neighbors1) {
        bool found = false;
        for (final neighbor2 in neighbors2) {
          if (neighbor1[0] == neighbor2[0] && neighbor1[1] == neighbor2[1]) {
            found = true;
            break;
          }
        }
        if (!found) return false;
      }
      return true;
    }
    
    return false;
  }

  /// Gets all revealed numbered cells that are neighbors of a given cell
  static List<List<int>> _getRevealedNumberedNeighbors(GameState gameState, int row, int col) {
    final neighbors = <List<int>>[];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        final nr = row + dr;
        final nc = col + dc;
        
        if (nr < 0 || nr >= gameState.rows || nc < 0 || nc >= gameState.columns) {
          continue;
        }
        
        final neighbor = gameState.getCell(nr, nc);
        if (neighbor.isRevealed && !neighbor.hasBomb && neighbor.bombsAround > 0) {
          neighbors.add([nr, nc]);
        }
      }
    }
    
    return neighbors;
  }

  /// Determines if a 50/50 situation is actually unsolvable
  /// This is a more sophisticated check that would analyze the entire board state
  static bool is5050Unsolvable(GameState gameState, FiftyFiftySituation situation) {
    // For now, we'll assume that if we detect a 50/50, it's unsolvable
    // In a full implementation, this would use constraint satisfaction algorithms
    // to determine if there's a logical way to solve the situation
    
    // Check if there are any other revealed cells that could provide additional information
    final additionalInfo = _hasAdditionalInformation(gameState, situation);
    
    return !additionalInfo;
  }

  /// Checks if there's additional information available that could solve the 50/50
  static bool _hasAdditionalInformation(GameState gameState, FiftyFiftySituation situation) {
    // Check if there are other revealed numbered cells that could provide constraints
    // on the two cells in the 50/50 situation
    
    final cell1Neighbors = _getRevealedNumberedNeighbors(gameState, situation.row1, situation.col1);
    final cell2Neighbors = _getRevealedNumberedNeighbors(gameState, situation.row2, situation.col2);
    
    // If either cell has additional revealed numbered neighbors beyond the trigger cell,
    // there might be additional information
    for (final neighbor in cell1Neighbors) {
      if (neighbor[0] != situation.triggerRow || neighbor[1] != situation.triggerCol) {
        // Check if this neighbor provides additional constraints
        if (_providesAdditionalConstraints(gameState, neighbor[0], neighbor[1], situation)) {
          return true;
        }
      }
    }
    
    for (final neighbor in cell2Neighbors) {
      if (neighbor[0] != situation.triggerRow || neighbor[1] != situation.triggerCol) {
        // Check if this neighbor provides additional constraints
        if (_providesAdditionalConstraints(gameState, neighbor[0], neighbor[1], situation)) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// Checks if a revealed numbered cell provides additional constraints on a 50/50 situation
  static bool _providesAdditionalConstraints(GameState gameState, int row, int col, FiftyFiftySituation situation) {
    final cell = gameState.getCell(row, col);
    final number = cell.bombsAround;
    
    // Count flagged and unrevealed neighbors
    int flaggedCount = 0;
    int unrevealedCount = 0;
    bool involves5050Cell1 = false;
    bool involves5050Cell2 = false;
    
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
          unrevealedCount++;
          if (nr == situation.row1 && nc == situation.col1) {
            involves5050Cell1 = true;
          }
          if (nr == situation.row2 && nc == situation.col2) {
            involves5050Cell2 = true;
          }
        }
      }
    }
    
    // If this cell involves one or both 50/50 cells, it might provide additional constraints
    if (involves5050Cell1 || involves5050Cell2) {
      final remainingMines = number - flaggedCount;
      
      // If the remaining mines don't match the unrevealed count, there's a constraint
      if (remainingMines != unrevealedCount) {
        return true;
      }
    }
    
    return false;
  }
} 