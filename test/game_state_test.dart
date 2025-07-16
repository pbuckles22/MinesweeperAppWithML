// NOTE: This test file is excluded from coverage runs due to segmentation faults
// caused by platform channel calls and file I/O operations in dependencies.
// The tests work correctly (8/8 pass) but the coverage tool crashes when
// instrumenting code that uses rootBundle.loadString, DateTime.now(), or
// complex singleton initialization patterns.
// 
// Root causes:
// - GameModeConfig.instance triggers file I/O via rootBundle.loadString
// - GameState.gameDuration uses DateTime.now() 
// - Constants.dart imports GameModeConfig which has platform channel calls
// - Complex data structures in difficultyLevels getter
//
// This is a known limitation of Flutter's coverage tools with certain code patterns.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/domain/entities/game_state.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';

void main() {
  group('GameState', () {
    late List<List<Cell>> board;
    setUp(() {
      board = List.generate(2, (row) => List.generate(2, (col) => Cell(row: row, col: col, hasBomb: false)));
    });

    test('constructor and basic getters', () {
      final state = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 1,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: DateTime(2023, 1, 1),
        endTime: DateTime(2023, 1, 1, 0, 1),
        difficulty: 'easy',
      );
      expect(state.rows, 2);
      expect(state.columns, 2);
      expect(state.isPlaying, true);
      expect(state.isWon, false);
      expect(state.isLost, false);
      expect(state.isGameOver, false);
      expect(state.remainingMines, 1);
      expect(state.progressPercentage, 0.0);
      expect(state.gameDuration, const Duration(minutes: 1));
    });

    test('getCell returns correct cell and throws on out of bounds', () {
      final state = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 1,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: null,
        endTime: null,
        difficulty: 'easy',
      );
      expect(state.getCell(0, 1), board[0][1]);
      expect(() => state.getCell(2, 0), throwsRangeError);
      expect(() => state.getCell(0, 2), throwsRangeError);
    });

    test('getNeighbors returns correct neighbors', () {
      final state = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 1,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: null,
        endTime: null,
        difficulty: 'easy',
      );
      // Center cell (0,0) neighbors
      final neighbors = state.getNeighbors(0, 0);
      expect(neighbors.length, 3);
      expect(neighbors, containsAll([board[0][1], board[1][0], board[1][1]]));
    });

    test('copyWith creates a new instance with updated values', () {
      final state = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 1,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: DateTime(2023, 1, 1),
        endTime: DateTime(2023, 1, 1, 0, 1),
        difficulty: 'easy',
      );
      final newBoard = List.generate(1, (row) => List.generate(1, (col) => Cell(row: row, col: col, hasBomb: true)));
      final copy = state.copyWith(
        board: newBoard,
        gameStatus: 'won',
        minesCount: 2,
        flaggedCount: 1,
        revealedCount: 2,
        totalCells: 1,
        startTime: DateTime(2023, 2, 2),
        endTime: DateTime(2023, 2, 2, 0, 2),
        difficulty: 'hard',
      );
      expect(copy.board, newBoard);
      expect(copy.gameStatus, 'won');
      expect(copy.minesCount, 2);
      expect(copy.flaggedCount, 1);
      expect(copy.revealedCount, 2);
      expect(copy.totalCells, 1);
      expect(copy.startTime, DateTime(2023, 2, 2));
      expect(copy.endTime, DateTime(2023, 2, 2, 0, 2));
      expect(copy.difficulty, 'hard');
    });

    test('equality and hashCode', () {
      final state1 = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 1,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: DateTime(2023, 1, 1),
        endTime: DateTime(2023, 1, 1, 0, 1),
        difficulty: 'easy',
      );
      final state2 = state1.copyWith();
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
      final state3 = state1.copyWith(gameStatus: 'won');
      expect(state1, isNot(equals(state3)));
      expect(state1.hashCode, isNot(equals(state3.hashCode)));
    });

    test('toString returns a string containing key info', () {
      final state = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 1,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: DateTime(2023, 1, 1),
        endTime: DateTime(2023, 1, 1, 0, 1),
        difficulty: 'easy',
      );
      final str = state.toString();
      expect(str, contains('GameState'));
      expect(str, contains('status: playing'));
      expect(str, contains('mines: 1'));
      expect(str, contains('flagged: 0'));
      expect(str, contains('revealed: 0'));
      expect(str, contains('difficulty: easy'));
    });

    test('progressPercentage handles edge cases', () {
      final state = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 4,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: null,
        endTime: null,
        difficulty: 'easy',
      );
      expect(state.progressPercentage, 0.0);
    });

    test('gameDuration returns null if startTime is null', () {
      final state = GameState(
        board: board,
        gameStatus: 'playing',
        minesCount: 1,
        flaggedCount: 0,
        revealedCount: 0,
        totalCells: 4,
        startTime: null,
        endTime: null,
        difficulty: 'easy',
      );
      expect(state.gameDuration, isNull);
    });
  });
} 