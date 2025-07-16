import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/core/constants.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';

void main() {
  setUpAll(() async {
    // Ensure fallback modes are loaded for tests
    await GameModeConfig.instance.reload();
  });
  group('GameConstants', () {
    test('should have correct default board dimensions', () {
      expect(GameConstants.defaultRowCount, equals(18));
      expect(GameConstants.defaultColumnCount, equals(10));
    });

    test('should have correct default bomb generation values', () {
      expect(GameConstants.defaultBombProbability, equals(3));
      expect(GameConstants.defaultMaxProbability, equals(15));
    });

    test('should have correct game state constants', () {
      expect(GameConstants.gameStatePlaying, equals('playing'));
      expect(GameConstants.gameStateWon, equals('won'));
      expect(GameConstants.gameStateLost, equals('lost'));
    });

    test('should have correct animation durations', () {
      expect(GameConstants.tileRevealDuration, equals(const Duration(milliseconds: 150)));
      expect(GameConstants.flagPlacementDuration, equals(const Duration(milliseconds: 100)));
    });

    test('should return difficulty levels from GameModeConfig', () {
      // Ensure GameModeConfig is initialized
      GameModeConfig.instance;
      
      final difficultyLevels = GameConstants.difficultyLevels;
      // print('difficultyLevels: ' + difficultyLevels.toString());
      
      expect(difficultyLevels, isA<Map<String, Map<String, int>>>());
      expect(difficultyLevels, isNotEmpty);
      
      // Check that it contains expected difficulty levels
      expect(difficultyLevels.containsKey('easy'), isTrue);
      expect(difficultyLevels.containsKey('normal'), isTrue);
      expect(difficultyLevels.containsKey('hard'), isTrue);
      expect(difficultyLevels.containsKey('expert'), isTrue);
      expect(difficultyLevels.containsKey('custom'), isTrue);
      
      // Check structure of difficulty levels
      for (final level in difficultyLevels.values) {
        expect(level.containsKey('rows'), isTrue);
        expect(level.containsKey('columns'), isTrue);
        expect(level.containsKey('mines'), isTrue);
        
        expect(level['rows'], isA<int>());
        expect(level['columns'], isA<int>());
        expect(level['mines'], isA<int>());
        
        expect(level['rows']!, greaterThan(0));
        expect(level['columns']!, greaterThan(0));
        expect(level['mines']!, greaterThanOrEqualTo(0));
      }
    });
  });
} 