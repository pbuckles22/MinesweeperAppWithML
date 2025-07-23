import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/domain/entities/cell.dart';

void main() {
  group('Cell Tests', () {
    group('Constructor and Basic Properties', () {
      test('should create cell with default values', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false);
        
        expect(cell.hasBomb, isFalse);
        expect(cell.bombsAround, equals(0));
        expect(cell.state, equals(CellState.unrevealed));
        expect(cell.row, equals(0));
        expect(cell.col, equals(0));
      });

      test('should create cell with custom values', () {
        final cell = Cell(
          row: 5, 
          col: 3, 
          hasBomb: true, 
          bombsAround: 2, 
          state: CellState.flagged
        );
        
        expect(cell.hasBomb, isTrue);
        expect(cell.bombsAround, equals(2));
        expect(cell.state, equals(CellState.flagged));
        expect(cell.row, equals(5));
        expect(cell.col, equals(3));
      });

      test('should create bomb cell', () {
        final cell = Cell(row: 1, col: 1, hasBomb: true);
        
        expect(cell.hasBomb, isTrue);
        expect(cell.bombsAround, equals(0));
        expect(cell.state, equals(CellState.unrevealed));
      });

      test('should create cell with bombs around', () {
        final cell = Cell(row: 2, col: 2, hasBomb: false, bombsAround: 3);
        
        expect(cell.hasBomb, isFalse);
        expect(cell.bombsAround, equals(3));
        expect(cell.state, equals(CellState.unrevealed));
      });
    });

    group('State Getters', () {
      test('isRevealed should return true for revealed state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.revealed);
        expect(cell.isRevealed, isTrue);
      });

      test('isRevealed should return false for other states', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.unrevealed);
        expect(cell.isRevealed, isFalse);
      });

      test('isFlagged should return true for flagged state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.flagged);
        expect(cell.isFlagged, isTrue);
      });

      test('isFlagged should return false for other states', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.unrevealed);
        expect(cell.isFlagged, isFalse);
      });

      test('isExploded should return true for exploded state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.exploded);
        expect(cell.isExploded, isTrue);
      });

      test('isExploded should return false for other states', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.unrevealed);
        expect(cell.isExploded, isFalse);
      });

      test('isUnrevealed should return true for unrevealed state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.unrevealed);
        expect(cell.isUnrevealed, isTrue);
      });

      test('isUnrevealed should return false for other states', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.revealed);
        expect(cell.isUnrevealed, isFalse);
      });

      test('isIncorrectlyFlagged should return true for incorrectlyFlagged state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.incorrectlyFlagged);
        expect(cell.isIncorrectlyFlagged, isTrue);
      });

      test('isIncorrectlyFlagged should return false for other states', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.unrevealed);
        expect(cell.isIncorrectlyFlagged, isFalse);
      });

      test('isHitBomb should return true for hitBomb state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.hitBomb);
        expect(cell.isHitBomb, isTrue);
      });

      test('isHitBomb should return false for other states', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.unrevealed);
        expect(cell.isHitBomb, isFalse);
      });

      test('isFiftyFifty should return true for fiftyFifty state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.fiftyFifty);
        expect(cell.isFiftyFifty, isTrue);
      });

      test('isFiftyFifty should return false for other states', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.unrevealed);
        expect(cell.isFiftyFifty, isFalse);
      });
    });

    group('isEmpty Property', () {
      test('should return true for empty cell (no bomb, no bombs around)', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, bombsAround: 0);
        expect(cell.isEmpty, isTrue);
      });

      test('should return false for cell with bomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, bombsAround: 0);
        expect(cell.isEmpty, isFalse);
      });

      test('should return false for cell with bombs around', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, bombsAround: 1);
        expect(cell.isEmpty, isFalse);
      });

      test('should return false for cell with bomb and bombs around', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, bombsAround: 2);
        expect(cell.isEmpty, isFalse);
      });
    });

    group('reveal() Method', () {
      test('should reveal non-bomb cell to revealed state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, bombsAround: 2);
        cell.reveal();
        expect(cell.state, equals(CellState.revealed));
        expect(cell.isRevealed, isTrue);
      });

      test('should reveal bomb cell to exploded state', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, bombsAround: 0);
        cell.reveal();
        expect(cell.state, equals(CellState.exploded));
        expect(cell.isExploded, isTrue);
      });

      test('should reveal fiftyFifty cell to revealed state if no bomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.fiftyFifty);
        cell.reveal();
        expect(cell.state, equals(CellState.revealed));
        expect(cell.isRevealed, isTrue);
      });

      test('should reveal fiftyFifty cell to exploded state if has bomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.fiftyFifty);
        cell.reveal();
        expect(cell.state, equals(CellState.exploded));
        expect(cell.isExploded, isTrue);
      });

      test('should not change state if already revealed', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.revealed);
        cell.reveal();
        expect(cell.state, equals(CellState.revealed));
      });

      test('should not change state if already exploded', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.exploded);
        cell.reveal();
        expect(cell.state, equals(CellState.exploded));
      });

      test('should not change state if flagged', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.flagged);
        cell.reveal();
        expect(cell.state, equals(CellState.flagged));
      });

      test('should not change state if incorrectly flagged', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.incorrectlyFlagged);
        cell.reveal();
        expect(cell.state, equals(CellState.incorrectlyFlagged));
      });

      test('should not change state if hit bomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.hitBomb);
        cell.reveal();
        expect(cell.state, equals(CellState.hitBomb));
      });
    });

    group('toggleFlag() Method', () {
      test('should flag an unrevealed cell', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false);
        cell.toggleFlag();
        expect(cell.state, equals(CellState.flagged));
        expect(cell.isFlagged, isTrue);
      });

      test('should unflag a flagged cell', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.flagged);
        cell.toggleFlag();
        expect(cell.state, equals(CellState.unrevealed));
        expect(cell.isUnrevealed, isTrue);
      });

      test('should flag a fiftyFifty cell', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.fiftyFifty);
        cell.toggleFlag();
        expect(cell.state, equals(CellState.flagged));
      });

      test('should not flag a revealed cell', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.revealed);
        cell.toggleFlag();
        expect(cell.state, equals(CellState.revealed));
      });

      test('should not flag an exploded cell', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.exploded);
        cell.toggleFlag();
        expect(cell.state, equals(CellState.exploded));
      });
    });

    group('markAsFiftyFifty() and unmarkFiftyFifty() Methods', () {
      test('should mark an unrevealed cell as fiftyFifty', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false);
        cell.markAsFiftyFifty();
        expect(cell.state, equals(CellState.fiftyFifty));
        expect(cell.isFiftyFifty, isTrue);
      });

      test('should not mark a revealed cell as fiftyFifty', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.revealed);
        cell.markAsFiftyFifty();
        expect(cell.state, equals(CellState.revealed));
      });

      test('should unmark a fiftyFifty cell to unrevealed', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.fiftyFifty);
        cell.unmarkFiftyFifty();
        expect(cell.state, equals(CellState.unrevealed));
        expect(cell.isUnrevealed, isTrue);
      });

      test('should not unmark a non-fiftyFifty cell', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.revealed);
        cell.unmarkFiftyFifty();
        expect(cell.state, equals(CellState.revealed));
      });
    });

    group('forceReveal() Method', () {
      test('should set state to hitBomb if isHitBomb and hasBomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true);
        cell.forceReveal(isHitBomb: true);
        expect(cell.state, equals(CellState.hitBomb));
        expect(cell.isHitBomb, isTrue);
      });

      test('should set state to incorrectlyFlagged if flagged, showIncorrectFlag, and not a bomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.flagged);
        cell.forceReveal(showIncorrectFlag: true);
        expect(cell.state, equals(CellState.incorrectlyFlagged));
        expect(cell.isIncorrectlyFlagged, isTrue);
      });

      test('should keep flagged state if flagged, hasBomb, and not exploded', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.flagged);
        cell.forceReveal(exploded: false);
        expect(cell.state, equals(CellState.flagged));
        expect(cell.isFlagged, isTrue);
      });

      test('should set state to exploded if flagged, hasBomb, and exploded', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.flagged);
        cell.forceReveal(exploded: true);
        expect(cell.state, equals(CellState.exploded));
        expect(cell.isExploded, isTrue);
      });

      test('should set state to revealed if flagged, not a bomb, and not showIncorrectFlag', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.flagged);
        cell.forceReveal();
        expect(cell.state, equals(CellState.revealed));
        expect(cell.isRevealed, isTrue);
      });

      test('should set state to revealed if unrevealed and not a bomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false);
        cell.forceReveal();
        expect(cell.state, equals(CellState.revealed));
      });

      test('should set state to exploded if unrevealed and hasBomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true);
        cell.forceReveal();
        expect(cell.state, equals(CellState.exploded));
      });

      test('should set state to revealed if unrevealed and hasBomb but exploded is false', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true);
        cell.forceReveal(exploded: false);
        expect(cell.state, equals(CellState.revealed));
      });

      test('should set state to revealed if fiftyFifty and not a bomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: false, state: CellState.fiftyFifty);
        cell.forceReveal();
        expect(cell.state, equals(CellState.revealed));
      });

      test('should set state to exploded if fiftyFifty and hasBomb', () {
        final cell = Cell(row: 0, col: 0, hasBomb: true, state: CellState.fiftyFifty);
        cell.forceReveal();
        expect(cell.state, equals(CellState.exploded));
      });
    });

    group('copyWith() Method', () {
      test('should copy cell with no changes if no arguments', () {
        final cell = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        final copy = cell.copyWith();
        expect(copy, equals(cell));
        expect(copy.hashCode, equals(cell.hashCode));
      });

      test('should copy cell with new values', () {
        final cell = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        final copy = cell.copyWith(row: 5, col: 6, hasBomb: false, bombsAround: 1, state: CellState.revealed);
        expect(copy.row, equals(5));
        expect(copy.col, equals(6));
        expect(copy.hasBomb, isFalse);
        expect(copy.bombsAround, equals(1));
        expect(copy.state, equals(CellState.revealed));
      });
    });

    group('Equality and hashCode', () {
      test('should be equal if all properties are the same', () {
        final cell1 = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        final cell2 = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        expect(cell1, equals(cell2));
        expect(cell1.hashCode, equals(cell2.hashCode));
      });

      test('should not be equal if any property is different', () {
        final cell1 = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        final cell2 = Cell(row: 1, col: 2, hasBomb: false, bombsAround: 3, state: CellState.flagged);
        final cell3 = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 2, state: CellState.flagged);
        final cell4 = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 3, state: CellState.revealed);
        final cell5 = Cell(row: 0, col: 2, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        final cell6 = Cell(row: 1, col: 0, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        expect(cell1 == cell2, isFalse);
        expect(cell1 == cell3, isFalse);
        expect(cell1 == cell4, isFalse);
        expect(cell1 == cell5, isFalse);
        expect(cell1 == cell6, isFalse);
      });
    });

    group('toString() Method', () {
      test('should return a string representation of the cell', () {
        final cell = Cell(row: 1, col: 2, hasBomb: true, bombsAround: 3, state: CellState.flagged);
        final str = cell.toString();
        expect(str, contains('row: 1'));
        expect(str, contains('col: 2'));
        expect(str, contains('hasBomb: true'));
        expect(str, contains('bombsAround: 3'));
        expect(str, contains('state: CellState.flagged'));
      });
    });
  });
} 