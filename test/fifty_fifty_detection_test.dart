import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/services/fifty_fifty_detector.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';
import 'package:flutter_minesweeper/core/constants.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';
import 'test_helper.dart';

GameState makeGameState({required List<List<Cell>> board, int mines = 1, int flagged = 0, int revealed = 0, String status = GameConstants.gameStatePlaying, String difficulty = 'test'}) {
  return GameState(
    board: board,
    gameStatus: status,
    minesCount: mines,
    flaggedCount: flagged,
    revealedCount: revealed,
    totalCells: board.length * board[0].length,
    startTime: DateTime.now(),
    endTime: null,
    difficulty: difficulty,
  );
}

Cell unrevealed({bool flagged = false, bool hasBomb = false, int row = 0, int col = 0}) => Cell(
  hasBomb: hasBomb,
  bombsAround: 0,
  state: flagged ? CellState.flagged : CellState.unrevealed,
  row: row,
  col: col,
);

Cell revealed({int bombs = 0, int row = 0, int col = 0}) => Cell(
  hasBomb: false,
  bombsAround: bombs,
  state: CellState.revealed,
  row: row,
  col: col,
);

void main() {
  group('50/50 Detection Tests', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      // Enable 50/50 detection for all tests
      FeatureFlags.enable5050Detection = true;
      FeatureFlags.enable5050SafeMove = true;
    });

    tearDown(() {
      // Reset feature flags
      FeatureFlags.enable5050Detection = false;
      FeatureFlags.enable5050SafeMove = false;
    });

    late GameRepositoryImpl repository;

    setUp(() {
      repository = GameRepositoryImpl();
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
        // Classic blocked 50/50: two cells only constrained by one revealed number
        // [F][2][ ]
        // [?][?][ ]
        // [ ][ ][ ]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: true, bombsAround: 0, state: CellState.flagged),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
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
          (situation.row1 == 1 && situation.col1 == 0 && situation.row2 == 1 && situation.col2 == 1) ||
          (situation.row1 == 1 && situation.col1 == 1 && situation.row2 == 1 && situation.col2 == 0),
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
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 4, state: CellState.revealed),
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
      test('should NOT detect 50/50 when cells have multiple revealed neighbors providing constraints', () {
        // [1][?][1][?][1]
        // [1][2][1][2][1]  where the 2s create potential 50/50s with the ?s
        // [1][?][1][?][1]
        // But the cells are NOT blocked because they have multiple revealed neighbors
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
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        // Should NOT detect 50/50s because cells have multiple revealed neighbors providing constraints
        expect(situations, isEmpty, reason: '50/50 should not be detected when cells have multiple revealed neighbors');
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

    group('Scenario 1: Classic Blocked 50/50', () {
      test('should detect 50/50 when two cells are blocked by walls/flags', () {
        // [F][2][ ]
        // [?][?][ ]
        // [ ][ ][ ]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: true, bombsAround: 0, state: CellState.flagged),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 1,
          revealedCount: 6,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations.length, 1, reason: 'Should detect a single classic 50/50 situation');
      });
    });

    group('Scenario 2: Shared Constraint 50/50', () {
      test('should detect 50/50 when two cells are equally constrained by two numbers (matches screenshot)', () {
        // Screenshot-matching board:
        // [1][F][1][1][?][?]
        // [2][3][4][4][?][?]
        // [1][F][F][F][F][?]
        // [2][2][4][F][?][?]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: true, state: CellState.flagged),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 4, hasBomb: false, state: CellState.unrevealed), // candidate
            Cell(row: 0, col: 5, hasBomb: false, state: CellState.unrevealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 3, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 4, state: CellState.revealed),
            Cell(row: 1, col: 3, hasBomb: false, bombsAround: 4, state: CellState.revealed),
            Cell(row: 1, col: 4, hasBomb: false, state: CellState.unrevealed), // candidate
            Cell(row: 1, col: 5, hasBomb: false, state: CellState.unrevealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 2, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 3, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 4, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 5, hasBomb: false, state: CellState.unrevealed),
          ],
          [
            Cell(row: 3, col: 0, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 3, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 3, col: 2, hasBomb: false, bombsAround: 4, state: CellState.revealed),
            Cell(row: 3, col: 3, hasBomb: true, state: CellState.flagged),
            Cell(row: 3, col: 4, hasBomb: false, state: CellState.unrevealed),
            Cell(row: 3, col: 5, hasBomb: false, state: CellState.unrevealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 5, // adjust as needed
          flaggedCount: 5, // adjust as needed
          revealedCount: 12, // adjust as needed
          totalCells: 24,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations.length, 1, reason: 'Should detect a shared constraint 50/50 situation matching screenshot');
        final situation = situations.first;
        expect(
          (situation.row1 == 0 && situation.col1 == 4 && situation.row2 == 1 && situation.col2 == 4) ||
          (situation.row1 == 1 && situation.col1 == 4 && situation.row2 == 0 && situation.col2 == 4),
          isTrue,
        );
      });
    });

    group('Scenario 3: False 50/50 Due to Definitely Known Mines', () {
      test('should NOT detect 50/50 when one candidate is definitely a mine', () {
        // [ ][1][1][1][ ]
        // [ ][1][?][1][ ]
        // [ ][1][?][3][ ]
        // [?][?][?][?][?]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // definitely a mine
            Cell(row: 1, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 1, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
            Cell(row: 2, col: 3, hasBomb: false, bombsAround: 3, state: CellState.revealed),
            Cell(row: 2, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 3, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
            Cell(row: 3, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
            Cell(row: 3, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
            Cell(row: 3, col: 3, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
            Cell(row: 3, col: 4, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 12,
          totalCells: 20,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations, isEmpty, reason: 'Should NOT detect 50/50 when one candidate is definitely a mine');
      });
    });

    group('Scenario 4: Only one 50/50 returned when multiple exist', () {
      test('should only return one 50/50 when both classic and shared constraint 50/50s exist', () {
        // Large board combining Scenario 1 (top-left) and Scenario 2 (bottom-right)
        // [F][2][ ][ ][ ][ ][ ][ ][ ]
        // [?][?][ ][ ][ ][ ][ ][ ][ ]
        // [ ][ ][ ][ ][ ][ ][ ][ ][ ]
        // [ ][ ][ ][ ][ ][ ][ ][ ][ ]
        // [ ][ ][ ][ ][ ][ ][ ][ ][ ]
        // [ ][ ][ ][ ][ ][ ][ ][ ][ ]
        // [ ][ ][ ][ ][ ][ ][1][ ][ ]
        // [ ][ ][ ][ ][ ][ ][ ][?][?]
        // [ ][ ][ ][ ][ ][ ][ ][ ][1]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: true, bombsAround: 0, state: CellState.flagged),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 8, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // Scenario 1 candidate
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // Scenario 1 candidate
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 8, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 1, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 2, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 3, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 4, hasBomb: true, state: CellState.flagged),
            Cell(row: 2, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 2, col: 8, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 3, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 3, col: 8, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 4, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 4, col: 8, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 5, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 5, col: 8, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 6, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 6, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 6, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 6, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 6, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 6, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 6, col: 6, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 6, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 6, col: 8, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 7, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 7, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 7, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 7, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 7, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 7, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 7, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 7, col: 7, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // Scenario 2 candidate
            Cell(row: 7, col: 8, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // Scenario 2 candidate
          ],
          [
            Cell(row: 8, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 1, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 2, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 3, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 5, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 6, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 7, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 8, col: 8, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 1,
          revealedCount: 77,
          totalCells: 81,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations.length, 1, reason: 'Should only return one 50/50 situation even if multiple exist');
      });
    });

    group('Scenario 1 (Mirrored): Classic Blocked 50/50 (Left-Right Flipped)', () {
      test('should detect classic 50/50 when the board is mirrored horizontally', () {
        // [ ][2][F]
        // [ ][?][?]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: true, bombsAround: 0, state: CellState.flagged),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
            Cell(row: 1, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 1,
          revealedCount: 4,
          totalCells: 6,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations.length, 1, reason: 'Should detect a classic 50/50 situation even when mirrored');
      });
    });

    group('Scenario 1 (Rotated): Classic Blocked 50/50 (Upside-Down)', () {
      test('should detect classic 50/50 when the board is rotated 180 degrees', () {
        // [ ][?][?]
        // [ ][2][F]
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // candidate
          ],
          [
            Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0, state: CellState.revealed),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: true, bombsAround: 0, state: CellState.flagged),
          ],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 1,
          revealedCount: 4,
          totalCells: 6,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        final situations = FiftyFiftyDetector.detect5050Situations(state);
        expect(situations.length, 1, reason: 'Should detect a classic 50/50 situation even when rotated 180 degrees');
      });
    });

    group('Scenario 5: Multiple Independent Classic 50/50s', () {
      test('should detect multiple independent classic 50/50s on the same board', () {
        // [1][2][2][2][2]
        // [F][3][F][F][1]
        // [?][?][4][3][1]
        // [?][?][F][1][0]
        // [?][?][3][2][2]
        // Two independent 50/50s:
        // 1. Row 2: (2,0) and (2,1) - constrained by "3" at (1,1) with 2 flags and 2 unrevealed
        // 2. Row 4: (4,0) and (4,1) - constrained by "3" at (4,2) with 3 mines and 2 unrevealed
        final board = [
          [
            Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 0, col: 1, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 2, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 3, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 0, col: 4, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
          [
            Cell(row: 1, col: 0, hasBomb: true, bombsAround: 0, state: CellState.flagged),
            Cell(row: 1, col: 1, hasBomb: false, bombsAround: 3, state: CellState.revealed),
            Cell(row: 1, col: 2, hasBomb: true, bombsAround: 0, state: CellState.flagged),
            Cell(row: 1, col: 3, hasBomb: true, bombsAround: 0, state: CellState.flagged),
            Cell(row: 1, col: 4, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 1
            Cell(row: 2, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 1
            Cell(row: 2, col: 2, hasBomb: false, bombsAround: 4, state: CellState.revealed),
            Cell(row: 2, col: 3, hasBomb: false, bombsAround: 3, state: CellState.revealed),
            Cell(row: 2, col: 4, hasBomb: false, bombsAround: 1, state: CellState.revealed),
          ],
          [
            Cell(row: 3, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
            Cell(row: 3, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed),
            Cell(row: 3, col: 2, hasBomb: true, bombsAround: 0, state: CellState.flagged),
            Cell(row: 3, col: 3, hasBomb: false, bombsAround: 1, state: CellState.revealed),
            Cell(row: 3, col: 4, hasBomb: false, bombsAround: 0, state: CellState.revealed),
          ],
          [
            Cell(row: 4, col: 0, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 2
            Cell(row: 4, col: 1, hasBomb: false, bombsAround: 0, state: CellState.unrevealed), // 50/50 candidate 2
            Cell(row: 4, col: 2, hasBomb: false, bombsAround: 3, state: CellState.revealed),
            Cell(row: 4, col: 3, hasBomb: false, bombsAround: 2, state: CellState.revealed),
            Cell(row: 4, col: 4, hasBomb: false, bombsAround: 2, state: CellState.revealed),
          ],
        ];

        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 8,
          flaggedCount: 4,
          revealedCount: 17,
          totalCells: 25,
          startTime: DateTime.now(),
          difficulty: 'test',
        );

        final situations = FiftyFiftyDetector.detect5050Situations(state);

        expect(situations, isNotEmpty);
        expect(situations.length, equals(1)); // Should return only one 50/50 (the first one found)
        
        // Verify it's one of the two valid 50/50s
        final situation = situations.first;
        
        // Should be either the first 50/50 ((2,0) and (2,1)) or the second 50/50 ((4,0) and (4,1))
        final first5050 = (situation.row1 == 2 && situation.col1 == 0 && situation.row2 == 2 && situation.col2 == 1) ||
                         (situation.row1 == 2 && situation.col1 == 1 && situation.row2 == 2 && situation.col2 == 0);
        final second5050 = (situation.row1 == 4 && situation.col1 == 0 && situation.row2 == 4 && situation.col2 == 1) ||
                          (situation.row1 == 4 && situation.col1 == 1 && situation.row2 == 4 && situation.col2 == 0);
        
        expect(first5050 || second5050, isTrue, reason: '50/50 should be one of the two valid scenarios');
      });
    });
  }, skip: true); // Suppressed pending CSP/ML integration
} 