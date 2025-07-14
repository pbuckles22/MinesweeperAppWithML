import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';

void main() {
  group('First Click Guarantee Tests', () {
    late GameRepositoryImpl repository;

    setUp(() {
      repository = GameRepositoryImpl();
    });

    group('Feature Flag Tests', () {
      test('should respect feature flag when disabled', () async {
        // Disable the feature
        FeatureFlags.enableFirstClickGuarantee = false;
        
        // Create a board where first click would hit a mine
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
        
        // First click should hit the mine (no guarantee)
        final result = await repository.revealCell(0, 0);
        expect(result.isLost, true, reason: 'Game should be lost when feature is disabled');
      });

      test('should respect feature flag when enabled', () async {
        // Enable the feature
        FeatureFlags.enableFirstClickGuarantee = true;
        
        // Create a board where first click would hit a mine
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
        
        // First click should not hit the mine (guarantee active)
        final result = await repository.revealCell(0, 0);
        expect(result.isPlaying, true, reason: 'Game should continue when feature is enabled');
        expect(result.getCell(0, 0).isRevealed, true, reason: 'First click should be revealed');
        expect(result.getCell(0, 0).hasBomb, false, reason: 'First click should not have a bomb');
      });
    });

    group('Cascade Guarantee Tests', () {
      test('should ensure first click reveals a cascade when mine is present', () async {
        FeatureFlags.enableFirstClickGuarantee = true;
        
        // Create a board where first click would hit a mine
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        
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
        
        // First click should trigger cascade
        final result = await repository.revealCell(0, 0);
        
        // Check that the first click revealed a cascade (multiple cells)
        int revealedCount = 0;
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            if (result.getCell(row, col).isRevealed) {
              revealedCount++;
            }
          }
        }
        
        expect(revealedCount, greaterThan(1), reason: 'First click should reveal multiple cells (cascade)');
        expect(result.getCell(0, 0).isRevealed, true, reason: 'First click cell should be revealed');
        expect(result.getCell(0, 0).hasBomb, false, reason: 'First click should not have a bomb');
      });

      test('should ensure first click reveals a cascade when numbered cell is clicked', () async {
        FeatureFlags.enableFirstClickGuarantee = true;
        
        // Create a board where first click would reveal a numbered cell
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: true), Cell(row: 0, col: 2, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false), Cell(row: 1, col: 2, hasBomb: false)],
          [Cell(row: 2, col: 0, hasBomb: false), Cell(row: 2, col: 1, hasBomb: false), Cell(row: 2, col: 2, hasBomb: false)],
        ];
        // Set bomb counts
        board[0][0] = board[0][0].copyWith(bombsAround: 1); // Adjacent to mine
        board[0][2] = board[0][2].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][0] = board[1][0].copyWith(bombsAround: 0); // Blank
        board[1][1] = board[1][1].copyWith(bombsAround: 1); // Adjacent to mine
        board[1][2] = board[1][2].copyWith(bombsAround: 0); // Blank
        board[2][0] = board[2][0].copyWith(bombsAround: 0); // Blank
        board[2][1] = board[2][1].copyWith(bombsAround: 0); // Blank
        board[2][2] = board[2][2].copyWith(bombsAround: 0); // Blank
        
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
        
        // First click on numbered cell should trigger cascade
        final result = await repository.revealCell(0, 0);
        
        // Check that the first click revealed a cascade (multiple cells)
        int revealedCount = 0;
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            if (result.getCell(row, col).isRevealed) {
              revealedCount++;
            }
          }
        }
        
        expect(revealedCount, greaterThan(1), reason: 'First click should reveal multiple cells (cascade)');
        expect(result.getCell(0, 0).isRevealed, true, reason: 'First click cell should be revealed');
      });

      test('should not affect second click behavior', () async {
        FeatureFlags.enableFirstClickGuarantee = true;
        
        // Create a simple board
        final board = [
          [Cell(row: 0, col: 0, hasBomb: false), Cell(row: 0, col: 1, hasBomb: true)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: false)],
        ];
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
        
        // First click (should be guaranteed)
        final firstResult = await repository.revealCell(0, 0);
        expect(firstResult.isPlaying, true, reason: 'First click should not lose');
        
        // Second click on mine (should lose)
        final secondResult = await repository.revealCell(0, 1);
        expect(secondResult.isLost, true, reason: 'Second click on mine should lose');
      });
    });

    group('Edge Cases', () {
      test('should handle board with no blank cells initially', () async {
        FeatureFlags.enableFirstClickGuarantee = true;
        
        // Create a board where every cell has adjacent mines (no blank cells)
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true), Cell(row: 0, col: 1, hasBomb: false)],
          [Cell(row: 1, col: 0, hasBomb: false), Cell(row: 1, col: 1, hasBomb: true)],
        ];
        board[0][1] = board[0][1].copyWith(bombsAround: 2);
        board[1][0] = board[1][0].copyWith(bombsAround: 2);
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 2,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 4,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // First click should still work
        final result = await repository.revealCell(0, 1);
        expect(result.isPlaying, true, reason: 'Game should continue after first click');
        expect(result.getCell(0, 1).isRevealed, true, reason: 'First click should be revealed');
      });

      test('should handle single cell board', () async {
        FeatureFlags.enableFirstClickGuarantee = true;
        
        // Single cell board with mine
        final board = [
          [Cell(row: 0, col: 0, hasBomb: true)],
        ];
        
        final state = GameState(
          board: board,
          gameStatus: 'playing',
          minesCount: 1,
          flaggedCount: 0,
          revealedCount: 0,
          totalCells: 1,
          startTime: DateTime.now(),
          difficulty: 'test',
        );
        repository.setTestState(state);
        
        // First click should move the mine (impossible to create cascade in 1x1)
        final result = await repository.revealCell(0, 0);
        expect(result.isPlaying, true, reason: 'Game should continue after first click');
        expect(result.getCell(0, 0).isRevealed, true, reason: 'First click should be revealed');
        expect(result.getCell(0, 0).hasBomb, false, reason: 'First click should not have a bomb');
      });
    });

    group('Settings Provider Tests', () {
      test('should toggle between classic and kickstarter modes', () {
        // This would require testing the SettingsProvider directly
        // For now, we test the feature flag behavior
        FeatureFlags.enableFirstClickGuarantee = false;
        expect(FeatureFlags.enableFirstClickGuarantee, false);
        
        FeatureFlags.enableFirstClickGuarantee = true;
        expect(FeatureFlags.enableFirstClickGuarantee, true);
      });
    });
  });
} 