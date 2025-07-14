import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameRepository', () {
    late GameRepositoryImpl repository;

    setUpAll(() async {
      // Load config once for all tests
      await GameModeConfig.instance.loadGameModes();
    });

    setUp(() {
      repository = GameRepositoryImpl();
    });

    group('Board Initialization', () {
      test('should initialize board with correct dimensions', () async {
        final gameState = await repository.initializeGame('easy');
        expect(gameState.rows, 9);
        expect(gameState.columns, 9);
        expect(gameState.totalCells, 81);
      });

      test('should place correct number of mines', () async {
        final gameState = await repository.initializeGame('easy');
        int mineCount = 0;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (gameState.getCell(row, col).hasBomb) {
              mineCount++;
            }
          }
        }
        expect(mineCount, 10);
      });

      test('should calculate bombsAround correctly', () async {
        final gameState = await repository.initializeGame('easy');
        bool hasNumberedCells = false;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            final cell = gameState.getCell(row, col);
            if (!cell.hasBomb && cell.bombsAround > 0) {
              hasNumberedCells = true;
              break;
            }
          }
        }
        expect(hasNumberedCells, isTrue);
      });
    });

    group('Cell Revealing', () {
      test('should reveal cell when not flagged', () async {
        final gameState = await repository.initializeGame('easy');
        final result = await repository.revealCell(0, 0);
        expect(result.getCell(0, 0).isRevealed, isTrue);
      });

      test('should not reveal flagged cell', () async {
        final gameState = await repository.initializeGame('easy');
        await repository.toggleFlag(0, 0);
        final result = await repository.revealCell(0, 0);
        expect(result.getCell(0, 0).isRevealed, isFalse);
      });

      test('should trigger game over when revealing mine', () async {
        final gameState = await repository.initializeGame('easy');
        // Find a mine and reveal it
        int mineRow = -1, mineCol = -1;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (gameState.getCell(row, col).hasBomb) {
              mineRow = row;
              mineCol = col;
              break;
            }
          }
          if (mineRow != -1) break;
        }
        
        final result = await repository.revealCell(mineRow, mineCol);
        expect(result.isLost, isTrue);
        expect(result.isWon, isFalse);
      });
    });

    group('Flag Toggling', () {
      test('should toggle flag on unrevealed cell', () async {
        final gameState = await repository.initializeGame('easy');
        final result1 = await repository.toggleFlag(0, 0);
        expect(result1.getCell(0, 0).isFlagged, isTrue);
        
        final result2 = await repository.toggleFlag(0, 0);
        expect(result2.getCell(0, 0).isFlagged, isFalse);
      });

      test('should not toggle flag on revealed cell', () async {
        final gameState = await repository.initializeGame('easy');
        await repository.revealCell(0, 0);
        final result = await repository.toggleFlag(0, 0);
        expect(result.getCell(0, 0).isFlagged, isFalse);
      });

      test('should update flag count correctly', () async {
        final gameState = await repository.initializeGame('easy');
        expect(gameState.flaggedCount, 0);
        
        final result1 = await repository.toggleFlag(0, 0);
        expect(result1.flaggedCount, 1);
        
        final result2 = await repository.toggleFlag(0, 0);
        expect(result2.flaggedCount, 0);
      });
    });

    group('Win Condition', () {
      test('should detect win when all non-mines are revealed', () async {
        final gameState = await repository.initializeGame('easy');
        
        // Reveal all non-mine cells
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (!gameState.getCell(row, col).hasBomb) {
              await repository.revealCell(row, col);
            }
          }
        }
        
        // Get final state
        final finalState = await repository.getCurrentState();
        expect(finalState.isWon, isTrue);
        expect(finalState.isLost, isFalse);
      });
    });

    group('Game Reset', () {
      test('should reset game state correctly', () async {
        final gameState = await repository.initializeGame('easy');
        await repository.revealCell(0, 0);
        await repository.toggleFlag(1, 1);
        
        final resetState = await repository.resetGame();
        
        expect(resetState.isLost, isFalse);
        expect(resetState.isWon, isFalse);
        expect(resetState.flaggedCount, 0);
        
        // Check that all cells are unrevealed and unflagged
        for (int row = 0; row < resetState.rows; row++) {
          for (int col = 0; col < resetState.columns; col++) {
            final cell = resetState.getCell(row, col);
            expect(cell.isRevealed, isFalse);
            expect(cell.isFlagged, isFalse);
          }
        }
      });
    });
  });
} 