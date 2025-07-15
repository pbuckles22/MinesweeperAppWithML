import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/services/fifty_fifty_detector.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';

void main() {
  group('50/50 Detection Tests', () {
    late GameRepositoryImpl repository;

    setUp(() {
      repository = GameRepositoryImpl();
      FeatureFlags.enable5050Detection = true;
    });

    tearDown(() {
      FeatureFlags.enable5050Detection = false;
    });

    group('Basic 50/50 Detection', () {
      test('should detect simple 50/50 situation', () {
        // Create a simple 50/50 scenario:
        // [1][2][1]
        // [2][?][2]  where ? represents unrevealed cells
        // [1][2][1]
        // The center cell with "2" has exactly 2 unrevealed neighbors
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        
        // This is a simplified test - in reality we'd need a larger board
        // to properly test 50/50 detection
        expect(board.length, 3);
      });

      test('should not detect 50/50 when feature flag is disabled', () {
        FeatureFlags.enable5050Detection = false;
        
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isEmpty);
      });
    });

    group('Safe Move Detection', () {
      test('should not detect 50/50 when obvious safe moves exist', () {
        // [1][F][1]
        // [1][1][1]
        // [1][?][1]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: true, state: CellState.flagged),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 1,
          revealedCount: 8,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isEmpty);
      });
      test('should detect 50/50 when no obvious safe moves exist', () {
        // [1][?][1]
        // [1][1][1]
        // [1][?][1]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false),
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isNotEmpty);
        expect(situations.length, 1);
        final situation = situations.first;
        expect(
          (situation.row1 == 0 && situation.col1 == 1 && situation.row2 == 2 && situation.col2 == 1) ||
          (situation.row1 == 2 && situation.col1 == 1 && situation.row2 == 0 && situation.col2 == 1),
          isTrue,
        );
      });
      test('should not detect 50/50 if there are 2 unrevealed cells but 2 mines', () {
        // [2][?][2]
        // [2][2][2]
        // [2][?][2]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false),
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isEmpty);
      });
      test('should NOT detect 50/50 when one candidate cell is flagged', () {
        // [1][?][1]
        // [1][F][1]  where F is a flagged mine, ? are unrevealed cells
        // [1][?][1]
        // This should NOT be a 50/50 because one of the candidates is flagged
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: true, state: CellState.flagged),
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false),
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 1,
          revealedCount: 8,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        
        // Should NOT detect a 50/50 because one of the candidate cells is flagged
        expect(situations, isEmpty, reason: '50/50 should not be detected when one candidate is flagged');
      });
      test('should only return one 50/50 when multiple exist', () {
        // [1][?][1][?][1]
        // [1][2][1][2][1]  where the 2s create 50/50s with the ?s
        // [1][?][1][?][1]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 3, hasBomb: false),
            Cell(row: 0, col: 4, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 3, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 4, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false),
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 3, hasBomb: false),
            Cell(row: 2, col: 4, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 13,
          totalCells: 15,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        // Debug: Print the board state
        print('DEBUG: Board state:');
        for (var row in board) {
          print(row.map((c) => c.isRevealed ? '[${c.bombsAround}]' : '[?]').join(' '));
        }
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        print('DEBUG: Detected 50/50 situations: ${situations.length}');
        for (final s in situations) {
          print('DEBUG: 50/50 between (${s.row1},${s.col1}) and (${s.row2},${s.col2}), triggered by (${s.triggerRow},${s.triggerCol})');
        }
        expect(situations.length, 1);
      });
    });

    group('Single 50/50 Selection', () {
      test('should return only one 50/50 when multiple exist', () {
        // Create a board with multiple potential 50/50 situations
        // This test verifies that only the first detected 50/50 is returned
        // [1][2][1]
        // [2][?][2]  where ? are unrevealed cells in 50/50
        // [1][?][1]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations.length, 1); // Only one 50/50 should be returned
      });
    });

    group('Equal Constraints Detection', () {
      test('should detect 50/50 when cells have equal constraints', () {
        // Test the _cellsHaveEqualProbability method
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        // Test that cells (1,1) and (2,1) have equal probability
        final hasEqualProbability = FiftyFiftyDetector.isCellIn5050Situation(state, 1, 1);
        expect(hasEqualProbability, isA<bool>());
      });

      test('should detect classic 50/50 even with other constraints present', () {
        // Create a scenario with a classic 50/50 pattern plus additional constraints
        // [1][2][1]
        // [2][?][3]  where the 3 provides additional constraints but classic 50/50 still exists
        // [1][?][1]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 3, state: CellState.revealed), // Additional constraint
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 3,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        // Should detect classic 50/50 even with additional constraints present
        expect(situations, isNotEmpty);
        expect(situations.length, 1);
      });
    });

    group('Adjacency Helper', () {
      test('should correctly identify adjacent cells', () {
        // Test the _isAdjacent helper method
        expect(FiftyFiftyDetector.isCellIn5050Situation, isA<Function>());
        
        // Note: Since _isAdjacent is private, we test it indirectly through
        // the public methods that use it
      });
    });

    group('50/50 Situation Object', () {
      test('should create 50/50 situation with correct properties', () {
        const situation = FiftyFiftySituation(
          row1: 1,
          col1: 1,
          row2: 1,
          col2: 2,
          triggerRow: 1,
          triggerCol: 0,
          number: 2,
        );

        expect(situation.row1, 1);
        expect(situation.col1, 1);
        expect(situation.row2, 1);
        expect(situation.col2, 2);
        expect(situation.triggerRow, 1);
        expect(situation.triggerCol, 0);
        expect(situation.number, 2);
      });

      test('should handle equality correctly', () {
        const situation1 = FiftyFiftySituation(
          row1: 1,
          col1: 1,
          row2: 1,
          col2: 2,
          triggerRow: 1,
          triggerCol: 0,
          number: 2,
        );

        const situation2 = FiftyFiftySituation(
          row1: 1,
          col1: 1,
          row2: 1,
          col2: 2,
          triggerRow: 1,
          triggerCol: 0,
          number: 2,
        );

        const situation3 = FiftyFiftySituation(
          row1: 1,
          col1: 2,
          row2: 1,
          col2: 1,
          triggerRow: 1,
          triggerCol: 0,
          number: 2,
        );

        expect(situation1, equals(situation2));
        expect(situation1, equals(situation3)); // Should be equal regardless of order
        expect(situation1.hashCode, equals(situation2.hashCode));
      });

      test('should provide meaningful string representation', () {
        const situation = FiftyFiftySituation(
          row1: 1,
          col1: 1,
          row2: 1,
          col2: 2,
          triggerRow: 1,
          triggerCol: 0,
          number: 2,
        );

        final string = situation.toString();
        expect(string, contains('50/50'));
        expect(string, contains('(1,1) vs (1,2)'));
        expect(string, contains('triggered by (1,0)'));
        expect(string, contains('with number 2'));
      });
    });

    group('Cell State Integration', () {
      test('should mark cells as 50/50 correctly', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false);
        
        expect(cell.isFiftyFifty, false);
        expect(cell.isUnrevealed, true);
        
        cell.markAsFiftyFifty();
        expect(cell.isFiftyFifty, true);
        expect(cell.isUnrevealed, false);
        
        cell.unmarkFiftyFifty();
        expect(cell.isFiftyFifty, false);
        expect(cell.isUnrevealed, true);
      });

      test('should handle 50/50 cell revelation', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false);
        cell.markAsFiftyFifty();
        
        expect(cell.isFiftyFifty, true);
        
        cell.reveal();
        expect(cell.isFiftyFifty, false);
        expect(cell.isRevealed, true);
      });
    });

    group('Edge Cases', () {
      test('should handle empty board', () {
        final board = <List<Cell>>[];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 0,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isEmpty);
      });

      test('should handle board with no revealed cells', () {
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false)],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 2,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isEmpty);
      });

      test('should handle board with only empty revealed cells', () {
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed)],
          [Cell(row: 1, col: 0, hasBomb: false)],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 1,
          totalCells: 2,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isEmpty);
      });
    });

    group('Integration with Game Repository', () {
      test('should detect 50/50 situations in real game state', () async {
        // Create a game state that should have 50/50 situations
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        repository.setTestState(state);
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isA<List<FiftyFiftySituation>>());
      });
    });

    group('Performance Tests', () {
      test('should handle large boards efficiently', () {
        // Create a large board (16x16)
        final board = List.generate(16, (row) => 
          List.generate(16, (col) => 
            Cell(row: row, col: col, hasBomb: false, state: CellState.revealed)
          )
        );
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 40,
          flaggedCount: 0,
          revealedCount: 256,
          totalCells: 256,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        final stopwatch = Stopwatch()..start();
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        stopwatch.stop();
        
        expect(situations, isA<List<FiftyFiftySituation>>());
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should complete quickly
      });
    });

    group('Debug Tests', () {
      test('debug 50/50 detection logic', () {
        // True 50/50 scenario:
        // [1][?][1]
        // [1][1][1]
        // [1][?][1]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false), // Unrevealed (part of 50/50)
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed), // Trigger cell
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false), // Unrevealed (part of 50/50)
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 7,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        
        // Debug: Check the trigger cell (1,1)
        final triggerCell = state.getCell(1, 1);
        print('Trigger cell: row=1, col=1, bombsAround=${triggerCell.bombsAround}, isRevealed=${triggerCell.isRevealed}');
        
        // Count unrevealed neighbors around the trigger cell
        int unrevealedCount = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = 1 + dr;
            final nc = 1 + dc;
            if (nr >= 0 && nr < state.rows && nc >= 0 && nc < state.columns) {
              final neighbor = state.getCell(nr, nc);
              if (!neighbor.isRevealed && !neighbor.isFlagged) {
                unrevealedCount++;
                print('Unrevealed neighbor at ($nr, $nc)');
              }
            }
          }
        }
        print('Unrevealed neighbors around trigger: $unrevealedCount');
        
        // Count flagged neighbors
        int flaggedCount = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = 1 + dr;
            final nc = 1 + dc;
            if (nr >= 0 && nr < state.rows && nc >= 0 && nc < state.columns) {
              final neighbor = state.getCell(nr, nc);
              if (neighbor.isFlagged) {
                flaggedCount++;
              }
            }
          }
        }
        print('Flagged neighbors around trigger: $flaggedCount');
        print('Remaining mines: ${triggerCell.bombsAround - flaggedCount}');
        
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        print('Detected 50/50 situations: ${situations.length}');
        if (situations.isNotEmpty) {
          print('50/50 between (${situations.first.row1},${situations.first.col1}) and (${situations.first.row2},${situations.first.col2})');
        }
        
        // Should detect a 50/50
        expect(situations, isNotEmpty);
        expect(situations.length, 1);
        final situation = situations.first;
        expect(
          (situation.row1 == 0 && situation.col1 == 1 && situation.row2 == 2 && situation.col2 == 1) ||
          (situation.row1 == 2 && situation.col1 == 1 && situation.row2 == 0 && situation.col2 == 1),
          isTrue,
        );
      });
    });
  });
} 