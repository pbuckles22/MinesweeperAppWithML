import '../domain/entities/game_state.dart';
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
  /// Detects 50/50 situations in the current game state.
  /// A 50/50 situation occurs when two unrevealed cells have equal probability
  /// of being mines, making it impossible to determine which is which.
  static List<FiftyFiftySituation> detect5050Situations(GameState gameState) {
    if (!FeatureFlags.enable5050Detection) {
      return [];
    }

    // Step 1: Identify definitely mine cells and exclude them from 50/50 consideration
    final definitelyMineCells = _findDefinitelyMineCells(gameState);
    
    // Step 2: Check for 50/50 patterns in order of priority
    for (int row = 0; row < gameState.rows; row++) {
      for (int col = 0; col < gameState.columns; col++) {
        final cell = gameState.getCell(row, col);
        if (!cell.isRevealed || cell.hasBomb || cell.bombsAround == 0) {
          continue;
        }

        // Check for classic 50/50 pattern (Scenario 1)
        final classic5050 = _checkForClassic5050(gameState, row, col, definitelyMineCells);
        if (classic5050 != null) {
          // print('DEBUG: detect5050Situations - Found classic 50/50: $classic5050');
          return [classic5050]; // Return immediately - only one 50/50 at a time
        }

        // Check for shared constraint 50/50 pattern (Scenario 2)
        final shared5050 = _checkForSharedConstraint5050(gameState, row, col, definitelyMineCells);
        if (shared5050 != null) {
          // print('DEBUG: detect5050Situations - Found shared constraint 50/50: $shared5050');
          return [shared5050]; // Return immediately - only one 50/50 at a time
        }
      }
    }

    // print('DEBUG: detect5050Situations - No 50/50 situations found');
    return [];
  }

  /// Checks if a specific 50/50 situation is still valid in the current game state.
  /// This is used to avoid unnecessary re-detection when the current 50/50 is still valid.
  static bool is5050SituationStillValid(GameState gameState, FiftyFiftySituation situation) {
    if (!FeatureFlags.enable5050Detection) {
      return false;
    }

    // Check if both cells in the 50/50 are still unrevealed and unflagged
    final cell1 = gameState.getCell(situation.row1, situation.col1);
    final cell2 = gameState.getCell(situation.row2, situation.col2);
    
    if (cell1.isRevealed || cell1.isFlagged || cell2.isRevealed || cell2.isFlagged) {
      // print('DEBUG: is5050SituationStillValid - One of the cells is revealed or flagged, 50/50 no longer valid');
      return false;
    }

    // Check if the trigger cell is still valid
    final triggerCell = gameState.getCell(situation.triggerRow, situation.triggerCol);
    if (!triggerCell.isRevealed || triggerCell.hasBomb || triggerCell.bombsAround != situation.number) {
      // print('DEBUG: is5050SituationStillValid - Trigger cell is no longer valid, 50/50 no longer valid');
      return false;
    }

    // Check if the 50/50 logic still applies (this is a simplified check)
    // For a more robust check, we'd need to re-run the detection logic
    final definitelyMineCells = _findDefinitelyMineCells(gameState);
    
    // Check if either candidate cell is now definitely a mine or safe
    if (definitelyMineCells.any((mine) => mine[0] == situation.row1 && mine[1] == situation.col1) ||
        definitelyMineCells.any((mine) => mine[0] == situation.row2 && mine[1] == situation.col2) ||
        definitelyMineCells.any((safe) => safe[0] == -situation.row1 - 1 && safe[1] == -situation.col1 - 1) ||
        definitelyMineCells.any((safe) => safe[0] == -situation.row2 - 1 && safe[1] == -situation.col2 - 1)) {
      // print('DEBUG: is5050SituationStillValid - One of the cells is now definitely a mine or safe, 50/50 no longer valid');
      return false;
    }

    // print('DEBUG: is5050SituationStillValid - 50/50 situation is still valid');
    return true;
  }

  /// Finds cells that are definitely mines (must be flagged).
  /// These are cells that are the only unrevealed neighbor of a revealed number.
  static List<List<int>> _findDefinitelyMineCells(GameState gameState) {
    final mineCells = <List<int>>[];
    
    for (int row = 0; row < gameState.rows; row++) {
      for (int col = 0; col < gameState.columns; col++) {
        final cell = gameState.getCell(row, col);
        if (!cell.isRevealed || cell.hasBomb || cell.bombsAround == 0) {
          continue;
        }
        
        // Count flagged and unrevealed neighbors
        int flaggedCount = 0;
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
            if (neighbor.isFlagged) {
              flaggedCount++;
            } else if (!neighbor.isRevealed) {
              unrevealedNeighbors.add([nr, nc]);
            }
          }
        }
        
        final remainingMines = cell.bombsAround - flaggedCount;
        
        // print('DEBUG: _findDefinitelyMineCells - Cell ($row,$col) number=${cell.bombsAround}, flaggedCount=$flaggedCount, unrevealedNeighbors=$unrevealedNeighbors, remainingMines=$remainingMines');
        
        // If exactly one unrevealed neighbor and it needs exactly one mine, it's definitely a mine
        if (unrevealedNeighbors.length == 1 && remainingMines == 1) {
          // print('DEBUG: _findDefinitelyMineCells - Found definitely mine at ${unrevealedNeighbors.first}');
          mineCells.add(unrevealedNeighbors.first);
        }
        
        // NEW: If all mines are already flagged (remainingMines = 0), then all unrevealed neighbors are safe
        if (remainingMines == 0 && unrevealedNeighbors.isNotEmpty) {
          // print('DEBUG: _findDefinitelyMineCells - Cell ($row,$col) has all mines flagged, marking ${unrevealedNeighbors.length} neighbors as safe');
          // Mark these cells as "definitely safe" by adding them to a special list
          // We'll use a negative index to indicate "definitely safe" cells
          for (final neighbor in unrevealedNeighbors) {
            mineCells.add([-neighbor[0] - 1, -neighbor[1] - 1]); // Use negative indices to mark as safe
          }
        }
      }
    }
    
    // print('DEBUG: _findDefinitelyMineCells - Found ${mineCells.length} definitely mine/safe cells: $mineCells');
    return mineCells;
  }

  /// SCENARIO 1: Classic 50/50 pattern - exactly 2 unrevealed neighbors with exactly 1 remaining mine
  /// AND the two cells are "blocked" by walls/flags with no other revealed cells providing constraints
  static FiftyFiftySituation? _checkForClassic5050(GameState gameState, int row, int col, List<List<int>> definitelyMineCells) {
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
    
    // print('DEBUG: _checkForClassic5050 - Cell ($row,$col) number=$number, flaggedCount=$flaggedCount, unrevealedNeighbors=$unrevealedNeighbors, remainingMines=$remainingMines');
    
    if (unrevealedNeighbors.length == 2 && remainingMines == 1) {
      final cell1 = unrevealedNeighbors[0];
      final cell2 = unrevealedNeighbors[1];
      
      // Verify neither candidate cell is flagged
      final cell1State = gameState.getCell(cell1[0], cell1[1]);
      final cell2State = gameState.getCell(cell2[0], cell2[1]);
      
      if (cell1State.isFlagged || cell2State.isFlagged) {
        return null;
      }
      
      // Check if either candidate cell is definitely a mine or definitely safe
      if (definitelyMineCells.any((mine) => mine[0] == cell1[0] && mine[1] == cell1[1]) ||
          definitelyMineCells.any((mine) => mine[0] == cell2[0] && mine[1] == cell2[1]) ||
          definitelyMineCells.any((safe) => safe[0] == -cell1[0] - 1 && safe[1] == -cell1[1] - 1) ||
          definitelyMineCells.any((safe) => safe[0] == -cell2[0] - 1 && safe[1] == -cell2[1] - 1)) {
        // print('DEBUG: _checkForClassic5050 - One of the candidate cells is definitely a mine or safe, skipping');
        return null;
      }
      
      // For classic 50/50, we need to verify this is truly a 50/50 situation
      // Check if the cells are "blocked" - meaning no other revealed cells provide constraints
      if (!_areCellsBlocked(gameState, cell1[0], cell1[1], cell2[0], cell2[1], row, col)) {
        // print('DEBUG: _checkForClassic5050 - Cells are not blocked (other revealed cells provide constraints), skipping');
        return null;
      }
      
              // print('DEBUG: _checkForClassic5050 - Found valid classic 50/50: ($cell1) vs ($cell2)');
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

  /// SCENARIO 1 Helper: Checks if two cells are "blocked" by walls/flags with only the trigger cell providing constraints
  static bool _areCellsBlocked(GameState gameState, int row1, int col1, int row2, int col2, int triggerRow, int triggerCol) {
    final cellsToCheck = [row1, col1, row2, col2];
    for (int i = 0; i < cellsToCheck.length; i += 2) {
      final cellRow = cellsToCheck[i];
      final cellCol = cellsToCheck[i + 1];
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = cellRow + dr;
          final nc = cellCol + dc;
          if (nr < 0 || nr >= gameState.rows || nc < 0 || nc >= gameState.columns) {
            continue;
          }
          if (nr == triggerRow && nc == triggerCol) {
            continue;
          }
          final neighbor = gameState.getCell(nr, nc);
          if (neighbor.isRevealed && !neighbor.hasBomb && neighbor.bombsAround > 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// SCENARIO 2: Shared constraint 50/50 - multiple revealed cells constrain the same two unrevealed cells
  static FiftyFiftySituation? _checkForSharedConstraint5050(
      GameState gameState, int row, int col, List<List<int>> definitelyMineCells) {
    final cell = gameState.getCell(row, col);
    final number = cell.bombsAround;
    
    // Get all unrevealed, unflagged neighbors of this cell
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
    
    if (unrevealedNeighbors.isEmpty) return null;
    // print('DEBUG: _checkForSharedConstraint5050 - Trigger cell ($row,$col) number=$number unrevealedNeighbors=$unrevealedNeighbors flaggedCount=$flaggedCount');
    
    for (int otherRow = 0; otherRow < gameState.rows; otherRow++) {
      for (int otherCol = 0; otherCol < gameState.columns; otherCol++) {
        if (otherRow == row && otherCol == col) continue; // Skip self
        final otherCell = gameState.getCell(otherRow, otherCol);
        if (!otherCell.isRevealed || otherCell.hasBomb || otherCell.bombsAround == 0) {
          continue;
        }
        final otherUnrevealedNeighbors = <List<int>>[];
        int otherFlaggedCount = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = otherRow + dr;
            final nc = otherCol + dc;
            if (nr < 0 || nr >= gameState.rows || nc < 0 || nc >= gameState.columns) {
              continue;
            }
            final neighbor = gameState.getCell(nr, nc);
            if (neighbor.isFlagged) {
              otherFlaggedCount++;
            } else if (!neighbor.isRevealed) {
              otherUnrevealedNeighbors.add([nr, nc]);
            }
          }
        }
        // print('DEBUG:   Other cell ($otherRow,$otherCol) number=${otherCell.bombsAround} otherUnrevealedNeighbors=$otherUnrevealedNeighbors otherFlaggedCount=$otherFlaggedCount');
        
        // Find intersection of unrevealed neighbors (cells constrained by both revealed cells)
        final intersection = <String, List<int>>{};
        for (final n in unrevealedNeighbors) {
          final key = '${n[0]},${n[1]}';
          for (final otherN in otherUnrevealedNeighbors) {
            if (n[0] == otherN[0] && n[1] == otherN[1]) {
              intersection[key] = n;
              break;
            }
          }
        }
        // print('DEBUG:     Intersection of unrevealed neighbors: $intersection');
        if (intersection.length == 2) {
          final cells = intersection.values.toList();
          final cell1 = cells[0];
          final cell2 = cells[1];
          final cell1State = gameState.getCell(cell1[0], cell1[1]);
          final cell2State = gameState.getCell(cell2[0], cell2[1]);
          if (cell1State.isFlagged || cell2State.isFlagged) { 
            // print('DEBUG:     One of the candidate cells is flagged, skipping'); 
            continue; 
          }
          if (definitelyMineCells.any((mine) => mine[0] == cell1[0] && mine[1] == cell1[1]) ||
              definitelyMineCells.any((mine) => mine[0] == cell2[0] && mine[1] == cell2[1]) ||
              definitelyMineCells.any((safe) => safe[0] == -cell1[0] - 1 && safe[1] == -cell1[1] - 1) ||
              definitelyMineCells.any((safe) => safe[0] == -cell2[0] - 1 && safe[1] == -cell2[1] - 1)) {
            // print('DEBUG:     One of the candidate cells is definitely a mine or safe, skipping');
            continue;
          }
          if (!_areCellsBlockedShared(gameState, cell1[0], cell1[1], cell2[0], cell2[1], row, col, otherRow, otherCol)) {
            // print('DEBUG:     Cells are not blocked (other revealed cells provide constraints), skipping');
            continue;
          }
          final remainingMines1 = number - flaggedCount;
          final remainingMines2 = otherCell.bombsAround - otherFlaggedCount;
          // print('DEBUG:     Remaining mines: trigger=$remainingMines1, other=$remainingMines2');
          if (remainingMines1 + remainingMines2 == 2) {
            // print('DEBUG:     Found shared constraint 50/50: ($cell1) vs ($cell2)');
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
      }
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

  /// Add this helper for shared constraint blocked check
  static bool _areCellsBlockedShared(GameState gameState, int row1, int col1, int row2, int col2, int triggerRow1, int triggerCol1, int triggerRow2, int triggerCol2) {
    final cellsToCheck = [row1, col1, row2, col2];
    for (int i = 0; i < cellsToCheck.length; i += 2) {
      final cellRow = cellsToCheck[i];
      final cellCol = cellsToCheck[i + 1];
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = cellRow + dr;
          final nc = cellCol + dc;
          if (nr < 0 || nr >= gameState.rows || nc < 0 || nc >= gameState.columns) {
            continue;
          }
          if ((nr == triggerRow1 && nc == triggerCol1) || (nr == triggerRow2 && nc == triggerCol2)) {
            continue;
          }
          final neighbor = gameState.getCell(nr, nc);
          if (neighbor.isRevealed && !neighbor.hasBomb && neighbor.bombsAround > 0) {
            return false;
          }
        }
      }
    }
    return true;
  }
} 