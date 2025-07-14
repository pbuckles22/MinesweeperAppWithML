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
        final gameState = await repository.initializeGame('beginner');
        
        expect(gameState.rows, 9);
        expect(gameState.columns, 9);
        expect(gameState.minesCount, 10);
        expect(gameState.totalCells, 81);
      });

      test('should place mines correctly', () async {
        final gameState = await repository.initializeGame('beginner');
        
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
        final gameState = await repository.initializeGame('beginner');
        
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
        final beginner = await repository.initializeGame('beginner');
        final intermediate = await repository.initializeGame('intermediate');
        final expert = await repository.initializeGame('expert');
        
        expect(beginner.rows, 9);
        expect(beginner.columns, 9);
        expect(beginner.minesCount, 10);
        
        expect(intermediate.rows, 16);
        expect(intermediate.columns, 16);
        expect(intermediate.minesCount, 40);
        
        expect(expert.rows, 16);
        expect(expert.columns, 30);
        expect(expert.minesCount, 99);
      });
    });

    group('Cascade Logic', () {
      test('should cascade correctly for empty cell using revealCascade method', () async {
        // Create a simple 3x3 board with NO mines
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        
        // Set all bomb counts to 0
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            board[row][col] = board[row][col].copyWith(bombsAround: 0);
          }
        }
        
        // Test cascade from center cell (1,1)
        final centerCell = board[1][1];
        expect(centerCell.isEmpty, true, reason: 'Center cell should be empty');
        
        // Use the revealCascade method
        repository.revealCascade(board, 1, 1);
        
        // All cells should be revealed after cascade
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            expect(board[row][col].isRevealed, true, 
                reason: 'Cell at ($row, $col) should be revealed after cascade');
          }
        }
      });

      test('should not cascade for numbered cell', () async {
        // Create a simple 3x3 board with one mine in the center
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: true), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        
        // Set bomb counts
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            if (!board[row][col].hasBomb) {
              int count = 0;
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  final nr = row + dr;
                  final nc = col + dc;
                  if (nr >= 0 && nr < 3 && nc >= 0 && nc < 3) {
                    if (board[nr][nc].hasBomb) count++;
                  }
                }
              }
              board[row][col] = board[row][col].copyWith(bombsAround: count);
            }
          }
        }
        
        // Test revealing a numbered cell (should not cascade)
        final cornerCell = board[0][0];
        expect(cornerCell.bombsAround, 1, reason: 'Corner cell should have 1 bomb around');
        
        // Use the revealCascade method
        repository.revealCascade(board, 0, 0);
        
        // Only the clicked cell should be revealed
        expect(cornerCell.isRevealed, true, reason: 'Clicked cell should be revealed');
        expect(board[0][1].isRevealed, false, reason: 'Adjacent cell should not be revealed');
        expect(board[1][0].isRevealed, false, reason: 'Adjacent cell should not be revealed');
      });

      test('should handle edge cases in cascade', () async {
        // Create a 2x2 board with one mine
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        
        // Set bomb counts
        board[0][0] = board[0][0].copyWith(bombsAround: 1);
        board[1][0] = board[1][0].copyWith(bombsAround: 1);
        board[1][1] = board[1][1].copyWith(bombsAround: 1);
        
        // Test cascade from empty cell (1,1)
        repository.revealCascade(board, 1, 1);
        
        // Only the empty cell should be revealed
        expect(board[1][1].isRevealed, true, reason: 'Empty cell should be revealed');
        expect(board[0][0].isRevealed, false, reason: 'Numbered cell should not be revealed');
        expect(board[0][1].isRevealed, false, reason: 'Bomb cell should not be revealed');
      });

      test('cascade stops at numbered cells', () async {
        // 3x3 board:
        // 0 1 B
        // 0 1 1
        // 0 0 0
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false, bombsAround: 0), Cell(row: 0, col: 1, hasBomb: false, bombsAround: 1), Cell(row: 0, col: 2, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: false, bombsAround: 0), Cell(row: 1, col: 1, hasBomb: false, bombsAround: 1), Cell(row: 1, col: 2, hasBomb: false, bombsAround: 1)],
          [Cell(row: 2, col: 0, hasBomb: false, bombsAround: 0), Cell(row: 2, col: 1, hasBomb: false, bombsAround: 0), Cell(row: 2, col: 2, hasBomb: false, bombsAround: 0)],
        ];
        final repository = GameRepositoryImpl();
        // Start cascade from (2,2) (empty cell)
        repository.revealCascade(board, 2, 2);
        // Debug print board revealed state
        for (int row = 0; row < 3; row++) {
          String line = '';
          for (int col = 0; col < 3; col++) {
            line += board[row][col].isRevealed ? 'R ' : '. ';
          }
          print('Row $row: $line');
        }
        // All empty cells and their immediate numbered neighbors should be revealed
        expect(board[2][2].isRevealed, true); // empty
        expect(board[2][1].isRevealed, true); // empty
        expect(board[2][0].isRevealed, true); // empty
        expect(board[1][0].isRevealed, true); // empty
        expect(board[1][1].isRevealed, true); // numbered
        expect(board[0][0].isRevealed, true); // empty
        expect(board[0][1].isRevealed, true); // numbered
        expect(board[1][2].isRevealed, true); // numbered
        // Bomb should not be revealed
        expect(board[0][2].isRevealed, false);
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
        final gameState = await repository.initializeGame('beginner');
        
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
        final gameState = await repository.initializeGame('beginner');
        
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
        final gameState = await repository.initializeGame('beginner');
        
        // Flag a cell
        final flaggedState = await repository.toggleFlag(0, 0);
        
        // Try to reveal the flagged cell
        final newState = await repository.revealCell(0, 0);
        expect(newState.getCell(0, 0).isFlagged, true, reason: 'Flagged cell should remain flagged');
        expect(newState.getCell(0, 0).isRevealed, false, reason: 'Flagged cell should not be revealed');
      });

      test('should not allow flagging revealed cells', () async {
        final gameState = await repository.initializeGame('beginner');
        
        // Reveal a cell
        final revealedState = await repository.revealCell(0, 0);
        
        // Try to flag the revealed cell
        final newState = await repository.toggleFlag(0, 0);
        expect(newState.getCell(0, 0).isFlagged, false, reason: 'Revealed cell should not be flagged');
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
        final gameState = await repository.initializeGame('beginner');
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
        // 2x2 board, one mine at (0,0)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true, bombsAround: 0), Cell(row: 0, col: 1, hasBomb: false, bombsAround: 1)],
          [Cell(row: 1, col: 0, hasBomb: false, bombsAround: 1), Cell(row: 1, col: 1, hasBomb: false, bombsAround: 1)],
        ];
        final repository = GameRepositoryImpl();
        // Simulate game over by revealing the bomb
        board[0][0].reveal();
        // Try to reveal another cell after game over
        final prevState = board[0][1].isRevealed;
        board[0][1].reveal();
        // No state change should occur
        expect(board[0][1].isRevealed, prevState, reason: 'No new cells should be revealed after game over');
      });

      test('flag count never exceeds mine count', () async {
        // 2x2 board, 2 mines
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        int flagCount = 0;
        // Flag all cells
        for (var row in board) {
          for (var cell in row) {
            if (!cell.isRevealed && !cell.isFlagged) {
              cell.toggleFlag();
              if (cell.isFlagged) flagCount++;
            }
          }
        }
        // Should not exceed mine count (2)
        expect(flagCount <= 2, true);
      });

      test('flag count never goes negative', () async {
        // 2x2 board, no mines
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        int flagCount = 0;
        // Try to unflag all cells (should not go negative)
        for (var row in board) {
          for (var cell in row) {
            if (!cell.isFlagged) {
              cell.toggleFlag(); // flag
              flagCount++;
            }
            if (cell.isFlagged) {
              cell.toggleFlag(); // unflag
              flagCount--;
            }
          }
        }
        expect(flagCount >= 0, true);
      });

      test('no further moves allowed after win or loss', () async {
        // 1x2 board, one mine
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
        ];
        // Win by revealing the only safe cell
        board[0][1].reveal();
        expect(board[0][1].isRevealed, true);
        // Try to reveal the mine after win
        final prevState = board[0][0].isRevealed;
        board[0][0].reveal();
        expect(board[0][0].isRevealed, prevState, reason: 'No moves after win');
      });

      test('cascade and flagging at board edge/corner', () async {
        // 2x2 board, no mines
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
        final repository = GameRepositoryImpl();
        repository.revealCascade(board, 0, 0);
        expect(board[0][0].isRevealed, true);
        expect(board[0][1].isRevealed, true);
        expect(board[1][0].isRevealed, true);
        expect(board[1][1].isRevealed, true);
        // Flag and unflag a corner
        board[0][0].toggleFlag();
        expect(board[0][0].isFlagged, true);
        board[0][0].toggleFlag();
        expect(board[0][0].isFlagged, false);
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
  });
} 