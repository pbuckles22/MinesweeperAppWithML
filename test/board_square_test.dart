import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/board_square.dart';

void main() {
  group('BoardSquare', () {
    test('constructor with default values', () {
      final square = BoardSquare();
      expect(square.hasBomb, false);
      expect(square.bombsAround, 0);
    });

    test('constructor with custom values', () {
      final square = BoardSquare(hasBomb: true, bombsAround: 3);
      expect(square.hasBomb, true);
      expect(square.bombsAround, 3);
    });

    test('constructor with partial custom values', () {
      final square = BoardSquare(hasBomb: true);
      expect(square.hasBomb, true);
      expect(square.bombsAround, 0);
    });

    test('properties can be modified', () {
      final square = BoardSquare();
      
      square.hasBomb = true;
      expect(square.hasBomb, true);
      
      square.bombsAround = 5;
      expect(square.bombsAround, 5);
      
      square.hasBomb = false;
      expect(square.hasBomb, false);
    });

    test('equality uses default Dart object behavior', () {
      final square1 = BoardSquare(hasBomb: true, bombsAround: 3);
      final square2 = BoardSquare(hasBomb: true, bombsAround: 3);
      
      // Default Dart equality compares by reference, not by value
      expect(square1, isNot(equals(square2)));
      expect(square1, equals(square1)); // Same instance
    });

    test('toString returns default Dart object representation', () {
      final square = BoardSquare(hasBomb: true, bombsAround: 3);
      final str = square.toString();
      expect(str, contains('BoardSquare'));
      expect(str, contains('Instance of'));
    });
  });
} 