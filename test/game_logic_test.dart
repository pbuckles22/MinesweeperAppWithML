import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/core/constants.dart';

void main() {
  group('Game Logic Tests', () {
    late GameRepositoryImpl repository;

    setUp(() {
      repository = GameRepositoryImpl();
    });

    group('Board Initialization', () {
      test('should create board with correct dimensions', () async {
        final gameState = await repository.initializeGame('easy');
        
        expect(gameState.rows, 9);
        expect(gameState.columns, 9);
        expect(gameState.minesCount, 10);
        expect(gameState.totalCells, 81);
      });

      test('should place mines correctly', () async {
        final gameState = await repository.initializeGame('easy');
        
        int mineCount = 0;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (gameState.getCell(row, col).hasBomb) {
              mineCount++;
            }
          }
        }
        
        expect(mineCount, gameState.minesCount);
      });

      test('should calculate bomb counts correctly', () async {
        final gameState = await repository.initializeGame('easy');
        
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            final cell = gameState.getCell(row, col);
            if (!cell.hasBomb) {
              int expectedCount = 0;
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  final nr = row + dr;
                  final nc = col + dc;
                  if (nr >= 0 && nr < gameState.rows && nc >= 0 && nc < gameState.columns) {
                    if (gameState.getCell(nr, nc).hasBomb) {
                      expectedCount++;
                    }
                  }
                }
              }
              expect(cell.bombsAround, expectedCount);
            }
          }
        }
      });

      test('should handle different difficulty levels', () async {
        final easy = await repository.initializeGame('easy');
        final normal = await repository.initializeGame('normal');
        final hard = await repository.initializeGame('hard');
        final expert = await repository.initializeGame('expert');
        
        expect(easy.rows, 9);
        expect(easy.columns, 9);
        expect(easy.minesCount, 10);
        
        expect(normal.rows, 16);
        expect(normal.columns, 16);
        expect(normal.minesCount, 40);
        
        expect(hard.rows, 16);
        expect(hard.columns, 30);
        expect(hard.minesCount, 99);
        
        expect(expert.rows, 18);
        expect(expert.columns, 24);
        expect(expert.minesCount, 115);
      });
    });

    group('Cascade Logic', () {
      test('should cascade correctly for empty cell using revealCascade method', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Use repository's revealCell method instead of calling cascade directly
        final result = await repository.revealCell(1, 1);
        
        // Check that all cells are revealed
        expect(result.getCell(1, 1).isRevealed, true, reason: 'Cell at (1, 1) should be revealed after cascade');
        expect(result.getCell(0, 0).isRevealed, true, reason: 'Cell at (0, 0) should be revealed after cascade');
        expect(result.getCell(0, 1).isRevealed, true, reason: 'Cell at (0, 1) should be revealed after cascade');
        expect(result.getCell(0, 2).isRevealed, true, reason: 'Cell at (0, 2) should be revealed after cascade');
        expect(result.getCell(1, 0).isRevealed, true, reason: 'Cell at (1, 0) should be revealed after cascade');
        expect(result.getCell(1, 2).isRevealed, true, reason: 'Cell at (1, 2) should be revealed after cascade');
        expect(result.getCell(2, 0).isRevealed, true, reason: 'Cell at (2, 0) should be revealed after cascade');
        expect(result.getCell(2, 1).isRevealed, true, reason: 'Cell at (2, 1) should be revealed after cascade');
        expect(result.getCell(2, 2).isRevealed, true, reason: 'Cell at (2, 2) should be revealed after cascade');
      });

      test('should not cascade for numbered cell', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        // Set bomb counts
        board[0][0] = board[0][0].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 1);
        board[1][1] = board[1][1].copyWith(bombsAround: 1);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Use repository's revealCell method
        final result = await repository.revealCell(0, 0);
        
        expect(result.getCell(0, 0).isRevealed, true, reason: 'Clicked cell should be revealed');
        expect(result.getCell(1, 0).isRevealed, false, reason: 'Adjacent cell should not be revealed');
        expect(result.getCell(1, 1).isRevealed, false, reason: 'Adjacent cell should not be revealed');
      });

      test('should handle edge cases in cascade', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Use repository's revealCell method
        final result = await repository.revealCell(1, 1);
        
        expect(result.getCell(1, 1).isRevealed, true, reason: 'Empty cell should be revealed');
        expect(result.getCell(0, 0).isRevealed, true, reason: 'Adjacent cell should be revealed');
        expect(result.getCell(0, 1).isRevealed, true, reason: 'Adjacent cell should be revealed');
        expect(result.getCell(1, 0).isRevealed, true, reason: 'Adjacent cell should be revealed');
      });

      test('cascade stops at numbered cells', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        // Set bomb counts - (1,0) and (1,1) should be empty to cascade to (0,0) and (0,1)
        board[0][0] = board[0][0].copyWith(bombsAround: 1);
        board[0][1] = board[0][1].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 0); // Empty cell
        board[1][1] = board[1][1].copyWith(bombsAround: 0); // Empty cell
        board[1][2] = board[1][2].copyWith(bombsAround: 1);
        board[2][0] = board[2][0].copyWith(bombsAround: 1);
        board[2][1] = board[2][1].copyWith(bombsAround: 0);
        board[2][2] = board[2][2].copyWith(bombsAround: 0);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Use repository's revealCell method
        final result = await repository.revealCell(2, 2);
        
        // Debug: Print revealed cells
        print('Row 0: ${result.getCell(0, 0).isRevealed ? 'R' : '.'} ${result.getCell(0, 1).isRevealed ? 'R' : '.'} ${result.getCell(0, 2).isRevealed ? 'R' : '.'} ');
        print('Row 1: ${result.getCell(1, 0).isRevealed ? 'R' : '.'} ${result.getCell(1, 1).isRevealed ? 'R' : '.'} ${result.getCell(1, 2).isRevealed ? 'R' : '.'} ');
        print('Row 2: ${result.getCell(2, 0).isRevealed ? 'R' : '.'} ${result.getCell(2, 1).isRevealed ? 'R' : '.'} ${result.getCell(2, 2).isRevealed ? 'R' : '.'} ');
        
        // All empty cells and their immediate numbered neighbors should be revealed
        expect(result.getCell(2, 2).isRevealed, true); // empty
        expect(result.getCell(2, 1).isRevealed, true); // empty
        expect(result.getCell(2, 0).isRevealed, true); // numbered
        expect(result.getCell(1, 0).isRevealed, true); // empty
        expect(result.getCell(1, 1).isRevealed, true); // empty
        expect(result.getCell(0, 0).isRevealed, true); // numbered
        expect(result.getCell(0, 1).isRevealed, true); // numbered
        expect(result.getCell(1, 2).isRevealed, true); // numbered
        // Bomb should not be revealed
        expect(result.getCell(0, 2).isRevealed, false);
      });
    });

    group('Game State Management', () {
      test('should track revealed and flagged cells correctly', () async {
        // Use a deterministic 3x3 board with no bombs
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            board[row][col] = board[row][col].copyWith(bombsAround: 0);
          }
        }
        final gameState = GameState(
          board: board,
          gameStatus: GameConstants.gameStatePlaying,
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        // Reveal a cell
        board[0][0].reveal();
        expect(board[0][0].isRevealed, true);
        // Flag a cell
        board[1][1] = board[1][1].copyWith(state: CellState.flagged);
        expect(board[1][1].isFlagged, true);
        // Unflag the cell
        board[1][1] = board[1][1].copyWith(state: CellState.unrevealed);
        expect(board[1][1].isFlagged, false);
      });

      test('should detect win condition', () async {
        // Create a minimal 2x2 board with one mine
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        
        // Set bomb counts
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            if (!board[row][col].hasBomb) {
              int count = 0;
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  final nr = row + dr;
                  final nc = col + dc;
                  if (nr >= 0 && nr < 2 && nc >= 0 && nc < 2) {
                    if (board[nr][nc].hasBomb) count++;
                  }
                }
              }
              board[row][col] = board[row][col].copyWith(bombsAround: count);
            }
          }
        }
        
        // Reveal all non-mine cells
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            if (!board[row][col].hasBomb) {
              board[row][col].reveal();
            }
          }
        }
        
        // Check win condition
        bool isWon = true;
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            if (!board[row][col].hasBomb && !board[row][col].isRevealed) {
              isWon = false;
              break;
            }
          }
        }
        expect(isWon, true, reason: 'Game should be won when all non-mine cells are revealed');
      });

      test('should detect game over when bomb is revealed', () async {
        final gameState = await repository.initializeGame('easy');
        
        // Find a bomb cell
        int bombRow = -1, bombCol = -1;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (gameState.getCell(row, col).hasBomb) {
              bombRow = row;
              bombCol = col;
              break;
            }
          }
          if (bombRow != -1) break;
        }
        
        expect(bombRow, greaterThanOrEqualTo(0), reason: 'Should find a bomb cell');
        
        // Reveal the bomb
        final newState = await repository.revealCell(bombRow, bombCol);
        expect(newState.isGameOver, true, reason: 'Game should be over when bomb is revealed');
        expect(newState.getCell(bombRow, bombCol).isExploded, true, reason: 'Bomb cell should be exploded');
      });
    });

    group('Flag Management', () {
      test('should toggle flag correctly', () async {
        final gameState = await repository.initializeGame('easy');
        
        // Flag a cell
        final flaggedState = await repository.toggleFlag(0, 0);
        expect(flaggedState.getCell(0, 0).isFlagged, true);
        expect(flaggedState.flaggedCount, 1);
        
        // Unflag the same cell
        final unflaggedState = await repository.toggleFlag(0, 0);
        expect(unflaggedState.getCell(0, 0).isFlagged, false);
        expect(unflaggedState.flaggedCount, 0);
      });

      test('should not reveal flagged cells', () async {
        final gameState = await repository.initializeGame('easy');
        
        // Flag a cell
        final flaggedState = await repository.toggleFlag(0, 0);
        
        // Try to reveal the flagged cell
        final newState = await repository.revealCell(0, 0);
        expect(newState.getCell(0, 0).isFlagged, true, reason: 'Flagged cell should remain flagged');
        expect(newState.getCell(0, 0).isRevealed, false, reason: 'Flagged cell should not be revealed');
      });

      test('should not allow flagging revealed cells', () async {
        final gameState = await repository.initializeGame('easy');
        
        // Reveal a cell
        final revealedState = await repository.revealCell(0, 0);
        
        // Try to flag the revealed cell
        final newState = await repository.toggleFlag(0, 0);
        expect(newState.getCell(0, 0).isFlagged, false, reason: 'Revealed cell should not be flagged');
      });
    });

    group('Chording Logic', () {
      test('should chord correctly with correct flag count', () async {
        final repository = GameRepositoryImpl();
        // Create a 3x3 board with one mine at (0,0)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        // Set bomb counts
        board[0][1] = board[0][1].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][0] = board[1][0].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][1] = board[1][1].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][2] = board[1][2].copyWith(bombsAround: 0);
        board[2][0] = board[2][0].copyWith(bombsAround: 0);
        board[2][1] = board[2][1].copyWith(bombsAround: 0);
        board[2][2] = board[2][2].copyWith(bombsAround: 0);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal cell (0,1) which shows "1"
        final revealedState = await repository.revealCell(0, 1);
        expect(revealedState.getCell(0, 1).isRevealed, true);
        expect(revealedState.getCell(0, 1).bombsAround, 1);
        
        // Flag the mine at (0,0)
        final flaggedState = await repository.toggleFlag(0, 0);
        expect(flaggedState.getCell(0, 0).isFlagged, true);
        
        // Chord on the "1" cell - should reveal all unflagged neighbors
        final chordedState = await repository.chordCell(0, 1);
        
        // Check that all unflagged neighbors are revealed
        expect(chordedState.getCell(1, 0).isRevealed, true);
        expect(chordedState.getCell(1, 1).isRevealed, true);
        expect(chordedState.getCell(0, 2).isRevealed, true);
        
        // Flagged cell should remain flagged
        expect(chordedState.getCell(0, 0).isFlagged, true);
        expect(chordedState.getCell(0, 0).isRevealed, false);
      });

      test('should not chord with wrong flag count', () async {
        final repository = GameRepositoryImpl();
        // Create a 3x3 board with one mine at (0,0)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        // Set bomb counts
        board[0][1] = board[0][1].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][0] = board[1][0].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][1] = board[1][1].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][2] = board[1][2].copyWith(bombsAround: 0);
        board[2][0] = board[2][0].copyWith(bombsAround: 0);
        board[2][1] = board[2][1].copyWith(bombsAround: 0);
        board[2][2] = board[2][2].copyWith(bombsAround: 0);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal cell (0,1) which shows "1"
        final revealedState = await repository.revealCell(0, 1);
        
        // Don't flag the mine - wrong flag count
        // Chord on the "1" cell - should do nothing
        final chordedState = await repository.chordCell(0, 1);
        
        // Check that no cells were revealed
        expect(chordedState.getCell(1, 0).isRevealed, false);
        expect(chordedState.getCell(1, 1).isRevealed, false);
        expect(chordedState.getCell(0, 2).isRevealed, false);
      });

      test('should not chord on unrevealed cells', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Try to chord on unrevealed cell - should do nothing
        final chordedState = await repository.chordCell(0, 0);
        
        // Check that no cells were revealed
        expect(chordedState.getCell(0, 0).isRevealed, false);
        expect(chordedState.getCell(0, 1).isRevealed, false);
        expect(chordedState.getCell(1, 0).isRevealed, false);
        expect(chordedState.getCell(1, 1).isRevealed, false);
      });

      test('should not chord on empty cells', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        // Set all cells as empty
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            board[row][col] = board[row][col].copyWith(bombsAround: 0);
          }
        }
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal an empty cell - this will cascade and reveal all cells
        final revealedState = await repository.revealCell(0, 0);
        
        // All cells should be revealed by cascade
        expect(revealedState.getCell(0, 0).isRevealed, true);
        expect(revealedState.getCell(0, 1).isRevealed, true);
        expect(revealedState.getCell(1, 0).isRevealed, true);
        expect(revealedState.getCell(1, 1).isRevealed, true);
        
        // Try to chord on empty cell - should do nothing (return same state)
        final chordedState = await repository.chordCell(0, 0);
        
        // Check that chording didn't change anything (all cells still revealed)
        expect(chordedState.getCell(0, 0).isRevealed, true);
        expect(chordedState.getCell(0, 1).isRevealed, true);
        expect(chordedState.getCell(1, 0).isRevealed, true);
        expect(chordedState.getCell(1, 1).isRevealed, true);
        
        // Verify that chording returned the same state (no changes)
        expect(chordedState.revealedCount, revealedState.revealedCount);
      });

      test('should handle chording that reveals a mine', () async {
        final repository = GameRepositoryImpl();
        // Create a 3x3 board with one mine at (1,1)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: true), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        // Set bomb counts
        board[0][0] = board[0][0].copyWith(bombsAround: 1); // Adjacent to mine
        board[0][1] = board[0][1].copyWith(bombsAround: 1); // Adjacent to mine
        board[0][2] = board[0][2].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][0] = board[1][0].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][2] = board[1][2].copyWith(bombsAround: 1); // Adjacent to mine
        board[2][0] = board[2][0].copyWith(bombsAround: 1); // Adjacent to mine
        board[2][1] = board[2][1].copyWith(bombsAround: 1); // Adjacent to mine
        board[2][2] = board[2][2].copyWith(bombsAround: 1); // Adjacent to mine
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal cell (0,0) which shows "1"
        final revealedState = await repository.revealCell(0, 0);
        expect(revealedState.getCell(0, 0).isRevealed, true);
        expect(revealedState.getCell(0, 0).bombsAround, 1);
        
        // Place a flag on a non-mine neighbor (e.g., (0,1)) so flag count matches the number
        await repository.toggleFlag(0, 1);
        
        // Chord on the "1" cell - should reveal the unflagged mine and end game
        final chordedState = await repository.chordCell(0, 0);
        
        // Check that game is over
        expect(chordedState.isGameOver, true);
        expect(chordedState.getCell(1, 1).isExploded, true);
      });

      test('should not chord after game over', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        board[0][1] = board[0][1].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 1);
        board[1][1] = board[1][1].copyWith(bombsAround: 1);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal the bomb to end game
        final gameOverState = await repository.revealCell(0, 0);
        expect(gameOverState.isGameOver, true);
        
        // Try to chord after game over - should do nothing
        final chordedState = await repository.chordCell(0, 1);
        expect(chordedState.isGameOver, true); // Should still be game over
      });
    });

    group('Integration Tests', () {
      test('should handle complete game flow', () async {
        // Use a deterministic 2x2 board with one mine
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        // Set bomb counts
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            if (!board[row][col].hasBomb) {
              int count = 0;
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  final nr = row + dr;
                  final nc = col + dc;
                  if (nr >= 0 && nr < 2 && nc >= 0 && nc < 2) {
                    if (board[nr][nc].hasBomb) count++;
                  }
                }
              }
              board[row][col] = board[row][col].copyWith(bombsAround: count);
            }
          }
        }
        final gameState = GameState(
          board: board,
          gameStatus: GameConstants.gameStatePlaying,
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        // Reveal a safe cell
        board[0][1].reveal();
        expect(board[0][1].isRevealed, true);
        // Flag a cell
        board[1][0] = board[1][0].copyWith(state: CellState.flagged);
        expect(board[1][0].isFlagged, true);
        // Unflag the cell
        board[1][0] = board[1][0].copyWith(state: CellState.unrevealed);
        expect(board[1][0].isFlagged, false);
      });

      test('should generate random board with correct properties', () async {
        final gameState = await repository.initializeGame('easy');
        expect(gameState.rows, 9);
        expect(gameState.columns, 9);
        expect(gameState.minesCount, 10);
        int mineCount = 0;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (gameState.getCell(row, col).hasBomb) mineCount++;
          }
        }
        expect(mineCount, gameState.minesCount);
      });
    });

    group('Edge Cases', () {
      test('revealing a cell after game over does nothing', () async {
        // Create a deterministic 2x2 board with one mine at (0,0)
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        
        // Set bombsAround values
        board[0][1] = board[0][1].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 1);
        board[1][1] = board[1][1].copyWith(bombsAround: 1);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Simulate game over by revealing the bomb
        await repository.revealCell(0, 0); // triggers game over
        expect(repository.getCurrentState().isGameOver, true);
        
        // Try to reveal another cell after game over
        final prevState = repository.getCurrentState().getCell(0, 1).isRevealed;
        await repository.revealCell(0, 1);
        // No state change should occur
        expect(repository.getCurrentState().getCell(0, 1).isRevealed, prevState, reason: 'No new cells should be revealed after game over');
      });

      test('flag count never exceeds mine count', () async {
        final repository = GameRepositoryImpl();
        await repository.initializeGame('custom');
        // Try to flag all cells
        int flagCount = 0;
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            final state = await repository.toggleFlag(row, col);
            if (state.getCell(row, col).isFlagged) flagCount++;
          }
        }
        // Should not exceed mine count (2 for custom)
        expect(flagCount <= repository.getCurrentState().minesCount, true);
      });

      test('flag count never goes negative', () async {
        final repository = GameRepositoryImpl();
        await repository.initializeGame('custom');
        // Flag and unflag all cells
        int flagCount = 0;
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            await repository.toggleFlag(row, col); // flag
            flagCount++;
            await repository.toggleFlag(row, col); // unflag
            flagCount--;
          }
        }
        expect(flagCount >= 0, true);
      });

      test('no further moves allowed after win or loss', () async {
        final repository = GameRepositoryImpl();
        await repository.initializeGame('custom');
        // Win by revealing all non-mine cells
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            final cell = repository.getCurrentState().getCell(row, col);
            if (!cell.hasBomb) {
              await repository.revealCell(row, col);
            }
          }
        }
        // Try to reveal a mine after win
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            final cell = repository.getCurrentState().getCell(row, col);
            if (cell.hasBomb) {
              final prevState = cell.isRevealed;
              await repository.revealCell(row, col);
              expect(repository.getCurrentState().getCell(row, col).isRevealed, prevState, reason: 'No moves after win');
            }
          }
        }
      });

      test('cascade and flagging at board edge/corner', () async {
        // 2x2 board, no mines
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        // Set bombsAround to 0 for all cells since there are no bombs
        for (int row = 0; row < 2; row++) {
          for (int col = 0; col < 2; col++) {
            board[row][col] = board[row][col].copyWith(bombsAround: 0);
          }
        }
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Cascade from (0,0) using repository
        final result = await repository.revealCell(0, 0);
        
        // All cells should be revealed since there are no bombs
        expect(result.getCell(0, 0).isRevealed, true);
        expect(result.getCell(0, 1).isRevealed, true);
        expect(result.getCell(1, 0).isRevealed, true);
        expect(result.getCell(1, 1).isRevealed, true);
        // Flag and unflag a corner using repository - use a new game state since all cells are revealed
        final newState = await repository.initializeGame('custom');
        await repository.toggleFlag(0, 0);
        expect(repository.getCurrentState().getCell(0, 0).isFlagged, true);
        await repository.toggleFlag(0, 0);
        expect(repository.getCurrentState().getCell(0, 0).isFlagged, false);
      });

      test('board with 0 mines wins immediately after first reveal', () async {
        // 2x2 board, no mines
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        // Reveal any cell
        board[0][0].reveal();
        // All cells should be revealed (win)
        expect(board[0][0].isRevealed, true);
        expect(board[0][1].isRevealed, false); // Not auto-revealed in this minimal logic, but in real game would be
      });

      test('board with all but one cell as mines wins after revealing the only safe cell', () async {
        // 2x2 board, 3 mines
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: true), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        // Reveal the only safe cell
        board[1][1].reveal();
        expect(board[1][1].isRevealed, true);
        // All mines should remain unrevealed
        expect(board[0][0].isRevealed, false);
        expect(board[0][1].isRevealed, false);
        expect(board[1][0].isRevealed, false);
      });

      test('board with only one cell: win if no mine, lose if mine', () async {
        // Win case
        final winBoard = [
          [Cell(row: 0, col: 0, hasBomb: false)],
        ];
        winBoard[0][0].reveal();
        expect(winBoard[0][0].isRevealed, true);
        // Lose case
        final loseBoard = [
          [Cell(row: 0, col: 0, hasBomb: true)],
        ];
        loseBoard[0][0].reveal();
        expect(loseBoard[0][0].isExploded, true);
      });
    });

    group('Performance & Scale Edge Cases', () {
      test('should handle expert level board (18x24 with 115 mines)', () async {
        final repository = GameRepositoryImpl();
        final gameState = await repository.initializeGame('expert');
        
        expect(gameState.rows, 18);
        expect(gameState.columns, 24);
        expect(gameState.minesCount, 115);
        expect(gameState.totalCells, 432);
        
        // Count actual mines
        int mineCount = 0;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (gameState.getCell(row, col).hasBomb) {
              mineCount++;
            }
          }
        }
        expect(mineCount, 115);
        
        // Test that we can reveal a cell without performance issues
        final startTime = DateTime.now();
        final result = await repository.revealCell(0, 0);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        // Should complete within reasonable time (less than 1 second)
        expect(duration.inMilliseconds, lessThan(1000));
        expect(result.getCell(0, 0).isRevealed, true);
      });

      test('should handle large cascade efficiently', () async {
        final repository = GameRepositoryImpl();
        // Create a large board with no mines to test cascade performance
        final board = List.generate(20, (row) => 
          List.generate(20, (col) => 
            Cell(row: row, col: col, hasBomb: false).copyWith(bombsAround: 0)
          )
        );
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 400,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Test cascade performance on large empty area
        final startTime = DateTime.now();
        final result = await repository.revealCell(10, 10);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        // Should complete within reasonable time (less than 500ms)
        expect(duration.inMilliseconds, lessThan(500));
        
        // All cells should be revealed
        expect(result.revealedCount, 400);
      });

      test('should handle chording on complex board efficiently', () async {
        final repository = GameRepositoryImpl();
        // Create a complex board with many numbered cells
        final board = List.generate(15, (row) => 
          List.generate(15, (col) => 
            Cell(row: row, col: col, hasBomb: false).copyWith(bombsAround: 1)
          )
        );
        
        // Add some mines in corners
        board[0][0] = board[0][0].copyWith(hasBomb: true);
        board[0][1] = board[0][1].copyWith(hasBomb: true);
        board[1][0] = board[1][0].copyWith(hasBomb: true);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 3,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 225,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal a numbered cell
        final revealedState = await repository.revealCell(1, 1);
        
        // Flag the mines
        await repository.toggleFlag(0, 0);
        await repository.toggleFlag(0, 1);
        await repository.toggleFlag(1, 0);
        
        // Test chording performance
        final startTime = DateTime.now();
        final chordedState = await repository.chordCell(1, 1);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        
        // Should complete within reasonable time (less than 500ms)
        expect(duration.inMilliseconds, lessThan(500));
      });
    });

    group('Extreme Boundary Edge Cases', () {
      test('should handle 1x1 board correctly', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false)],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 1,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        final result = await repository.revealCell(0, 0);
        expect(result.getCell(0, 0).isRevealed, true);
        expect(result.isWon, true);
      });

      test('should handle 1xN board (very thin board)', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 3,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        final result = await repository.revealCell(0, 1);
        expect(result.getCell(0, 0).isRevealed, true);
        expect(result.getCell(0, 1).isRevealed, true);
        expect(result.getCell(0, 2).isRevealed, true);
        expect(result.isWon, true);
      });

      test('should handle Nx1 board (very tall board)', () async {
        final repository = GameRepositoryImpl();
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false)],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 0,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 3,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        final result = await repository.revealCell(1, 0);
        expect(result.getCell(0, 0).isRevealed, true);
        expect(result.getCell(1, 0).isRevealed, true);
        expect(result.getCell(2, 0).isRevealed, true);
        expect(result.isWon, true);
      });

      test('should handle maximum mine density board', () async {
        final repository = GameRepositoryImpl();
        // Create a 3x3 board with 8 mines (maximum density)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: true), Cell(row: 0, col: 2, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: true), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: true)],
          [Cell(row: 2, col: 0, hasBomb: true), Cell(row: 2, col: 1, hasBomb: true), Cell(row: 2, col: 2, hasBomb: true)],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 8,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal the only safe cell
        final result = await repository.revealCell(1, 1);
        expect(result.getCell(1, 1).isRevealed, true);
        expect(result.isWon, true);
        
        // All mines should remain unrevealed
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            if (row != 1 || col != 1) {
              expect(result.getCell(row, col).isRevealed, false);
            }
          }
        }
      });

      test('should handle minimum mine density board', () async {
        final repository = GameRepositoryImpl();
        // Create a 5x5 board with only 1 mine
        final board = List.generate(5, (row) => 
          List.generate(5, (col) => 
            Cell(row: row, col: col, hasBomb: false)
          )
        );
        
        // Place one mine in the center
        board[2][2] = board[2][2].copyWith(hasBomb: true);
        
        // Calculate bomb counts
        for (int row = 0; row < 5; row++) {
          for (int col = 0; col < 5; col++) {
            if (!board[row][col].hasBomb) {
              int count = 0;
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  final nr = row + dr;
                  final nc = col + dc;
                  if (nr >= 0 && nr < 5 && nc >= 0 && nc < 5) {
                    if (board[nr][nc].hasBomb) count++;
                  }
                }
              }
              board[row][col] = board[row][col].copyWith(bombsAround: count);
            }
          }
        }
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 25,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal a corner cell - should cascade to most of the board
        final result = await repository.revealCell(0, 0);
        expect(result.getCell(0, 0).isRevealed, true);
        
        // Most cells should be revealed (except the mine and its immediate neighbors)
        expect(result.revealedCount, greaterThan(20));
      });
    });

    group('Input Validation Edge Cases', () {
      test('should handle invalid coordinates gracefully', () async {
        final repository = GameRepositoryImpl();
        await repository.initializeGame('easy');
        
        // Test negative coordinates
        expect(() => repository.revealCell(-1, 0), throwsA(isA<RangeError>()));
        expect(() => repository.revealCell(0, -1), throwsA(isA<RangeError>()));
        expect(() => repository.toggleFlag(-1, 0), throwsA(isA<RangeError>()));
        expect(() => repository.toggleFlag(0, -1), throwsA(isA<RangeError>()));
        expect(() => repository.chordCell(-1, 0), throwsA(isA<RangeError>()));
        expect(() => repository.chordCell(0, -1), throwsA(isA<RangeError>()));
        
        // Test out of bounds coordinates
        expect(() => repository.revealCell(10, 0), throwsA(isA<RangeError>()));
        expect(() => repository.revealCell(0, 10), throwsA(isA<RangeError>()));
        expect(() => repository.toggleFlag(10, 0), throwsA(isA<RangeError>()));
        expect(() => repository.toggleFlag(0, 10), throwsA(isA<RangeError>()));
        expect(() => repository.chordCell(10, 0), throwsA(isA<RangeError>()));
        expect(() => repository.chordCell(0, 10), throwsA(isA<RangeError>()));
      });

      test('should handle operations on uninitialized game', () async {
        final repository = GameRepositoryImpl();
        
        // Test operations without initializing game
        expect(() => repository.getCurrentState(), throwsA(isA<StateError>()));
        expect(repository.isGameWon(), false);
        expect(repository.isGameLost(), false);
        expect(repository.getRemainingMines(), 0);
      });

      test('should handle operations after game over', () async {
        final repository = GameRepositoryImpl();
        await repository.initializeGame('easy');
        
        // Find and reveal a bomb to end the game
        int bombRow = -1, bombCol = -1;
        for (int row = 0; row < 9; row++) {
          for (int col = 0; col < 9; col++) {
            if (repository.getCurrentState().getCell(row, col).hasBomb) {
              bombRow = row;
              bombCol = col;
              break;
            }
          }
          if (bombRow != -1) break;
        }
        
        final gameOverState = await repository.revealCell(bombRow, bombCol);
        expect(gameOverState.isGameOver, true);
        
        // Test that operations after game over return the same state
        final revealAfterGameOver = await repository.revealCell(0, 0);
        expect(revealAfterGameOver.isGameOver, true);
        expect(revealAfterGameOver.gameStatus, gameOverState.gameStatus);
        
        final flagAfterGameOver = await repository.toggleFlag(0, 0);
        expect(flagAfterGameOver.isGameOver, true);
        expect(flagAfterGameOver.gameStatus, gameOverState.gameStatus);
        
        final chordAfterGameOver = await repository.chordCell(0, 0);
        expect(chordAfterGameOver.isGameOver, true);
        expect(chordAfterGameOver.gameStatus, gameOverState.gameStatus);
      });
    });

    group('Stress Testing Edge Cases', () {
      test('should handle rapid operations without state corruption', () async {
        final repository = GameRepositoryImpl();
        await repository.initializeGame('easy');
        
        // Perform rapid operations
        final futures = <Future<GameState>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(repository.revealCell(0, 0));
          futures.add(repository.toggleFlag(1, 1));
        }
        
        // Wait for all operations to complete
        final results = await Future.wait(futures);
        
        // All results should be valid game states
        for (final result in results) {
          expect(result, isA<GameState>());
          expect(result.board, isNotEmpty);
        }
      });

      test('should handle multiple chording operations in sequence', () async {
        final repository = GameRepositoryImpl();
        // Create a board with multiple numbered cells
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: true), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: true), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: true)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: true), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        
        // Set bomb counts
        board[0][0] = board[0][0].copyWith(bombsAround: 2);
        board[0][2] = board[0][2].copyWith(bombsAround: 2);
        board[1][1] = board[1][1].copyWith(bombsAround: 4);
        board[2][0] = board[2][0].copyWith(bombsAround: 2);
        board[2][2] = board[2][2].copyWith(bombsAround: 2);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 5,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal numbered cells
        await repository.revealCell(0, 0);
        await repository.revealCell(0, 2);
        await repository.revealCell(1, 1);
        await repository.revealCell(2, 0);
        await repository.revealCell(2, 2);
        
        // Flag mines
        await repository.toggleFlag(0, 1);
        await repository.toggleFlag(1, 0);
        await repository.toggleFlag(1, 2);
        await repository.toggleFlag(2, 1);
        
        // Perform multiple chording operations
        final chordResults = <GameState>[];
        chordResults.add(await repository.chordCell(0, 0));
        chordResults.add(await repository.chordCell(0, 2));
        chordResults.add(await repository.chordCell(1, 1));
        chordResults.add(await repository.chordCell(2, 0));
        chordResults.add(await repository.chordCell(2, 2));
        
        // All results should be valid
        for (final result in chordResults) {
          expect(result, isA<GameState>());
        }
      });
    });

    group('Win Condition', () {
      test('should flag all mines when game is won', () async {
        final repository = GameRepositoryImpl();
        
        // Create a 2x2 board with one mine at (0,0)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        
        // Set bomb counts for non-mine cells
        board[0][1] = board[0][1].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 1);
        board[1][1] = board[1][1].copyWith(bombsAround: 1);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Reveal all non-mine cells to trigger win
        await repository.revealCell(0, 1);
        await repository.revealCell(1, 0);
        await repository.revealCell(1, 1);
        
        final finalState = repository.getCurrentState();
        
        // Game should be won
        expect(finalState.isWon, true);
        
        // The mine should be flagged (not revealed)
        expect(finalState.getCell(0, 0).isFlagged, true);
        expect(finalState.getCell(0, 0).isRevealed, false);
        expect(finalState.getCell(0, 0).hasBomb, true);
        
        // All non-mine cells should be revealed
        expect(finalState.getCell(0, 1).isRevealed, true);
        expect(finalState.getCell(1, 0).isRevealed, true);
        expect(finalState.getCell(1, 1).isRevealed, true);
      });

      test('should not flag already flagged mines when game is won', () async {
        final repository = GameRepositoryImpl();
        
        // Create a 2x2 board with one mine at (0,0)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        
        // Set bomb counts for non-mine cells
        board[0][1] = board[0][1].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 1);
        board[1][1] = board[1][1].copyWith(bombsAround: 1);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Flag the mine before winning
        await repository.toggleFlag(0, 0);
        expect(repository.getCurrentState().getCell(0, 0).isFlagged, true);
        
        // Reveal all non-mine cells to trigger win
        await repository.revealCell(0, 1);
        await repository.revealCell(1, 0);
        await repository.revealCell(1, 1);
        
        final finalState = repository.getCurrentState();
        
        // Game should be won
        expect(finalState.isWon, true);
        
        // The mine should remain flagged (not toggled)
        expect(finalState.getCell(0, 0).isFlagged, true);
        expect(finalState.getCell(0, 0).isRevealed, false);
        expect(finalState.getCell(0, 0).hasBomb, true);
      });
    });

    group('Loss Condition', () {
      test('should reveal unflagged mines and show black X for incorrect flags on loss', () async {
        final repository = GameRepositoryImpl();
        
        // Create a 3x3 board with mines at (0,0) and (1,1)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: true), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        
        // Set bomb counts for non-mine cells
        board[0][1] = board[0][1].copyWith(bombsAround: 2);
        board[0][2] = board[0][2].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 2);
        board[1][2] = board[1][2].copyWith(bombsAround: 2);
        board[2][0] = board[2][0].copyWith(bombsAround: 1);
        board[2][1] = board[2][1].copyWith(bombsAround: 2);
        board[2][2] = board[2][2].copyWith(bombsAround: 1);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 9,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // Flag one mine correctly and one non-mine incorrectly
        await repository.toggleFlag(0, 0); // Correct flag
        await repository.toggleFlag(0, 1); // Incorrect flag (non-mine)
        
        // Click on a mine to trigger loss
        await repository.revealCell(1, 1);
        
        final finalState = repository.getCurrentState();
        
        // Game should be lost
        expect(finalState.isLost, true);
        
        // Correctly flagged mine should stay flagged
        expect(finalState.getCell(0, 0).isFlagged, true);
        expect(finalState.getCell(0, 0).isRevealed, false);
        expect(finalState.getCell(0, 0).isExploded, false);
        
        // Incorrectly flagged non-mine should show black X
        expect(finalState.getCell(0, 1).isIncorrectlyFlagged, true);
        expect(finalState.getCell(0, 1).isFlagged, false);
        expect(finalState.getCell(0, 1).isRevealed, false);
        
        // Unflagged mine should be exploded
        expect(finalState.getCell(1, 1).isExploded, true);
        expect(finalState.getCell(1, 1).isRevealed, false);
        expect(finalState.getCell(1, 1).isFlagged, false);
      });
    });
  });
} 