import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_minesweeper/core/game_mode_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('GameModeConfig Dynamic Loading Tests', () {
    late GameModeConfig config;

    setUpAll(() async {
      config = GameModeConfig.instance;
      await config.loadGameModes();
    });

    group('Dynamic Game Mode Loading', () {
      test('should load all enabled game modes from JSON', () {
        final enabledModes = config.enabledGameModes;
        expect(enabledModes.length, greaterThan(0));
        
        // Verify each mode has required properties
        for (final mode in enabledModes) {
          expect(mode.id, isNotEmpty);
          expect(mode.name, isNotEmpty);
          expect(mode.description, isNotEmpty);
          expect(mode.rows, greaterThan(0));
          expect(mode.columns, greaterThan(0));
          expect(mode.mines, greaterThanOrEqualTo(0));
          expect(mode.enabled, isTrue);
        }
      });

      test('should handle new game mode addition (chaotic example)', () async {
        // Simulate adding a new "chaotic" mode to JSON
        const newModeJson = '''
        {
          "game_modes": [
            {
              "id": "easy",
              "name": "Easy",
              "description": "9×9 grid, 10 mines",
              "rows": 9,
              "columns": 9,
              "mines": 10,
              "enabled": true
            },
            {
              "id": "chaotic",
              "name": "Chaotic",
              "description": "20×20 grid, 150 mines",
              "rows": 20,
              "columns": 20,
              "mines": 150,
              "enabled": true
            }
          ],
          "defaults": {
            "game_mode": "easy",
            "features": {
              "kickstarter_mode": false,
              "5050_detection": false,
              "5050_safe_move": false
            }
          }
        }
        ''';

        // Test that the config can parse new modes
        final json = jsonDecode(newModeJson);
        final modes = (json['game_modes'] as List)
            .map((mode) => GameMode.fromJson(mode))
            .toList();

        expect(modes.length, 2);
        
        final chaoticMode = modes.firstWhere((mode) => mode.id == 'chaotic');
        expect(chaoticMode.name, 'Chaotic');
        expect(chaoticMode.description, '20×20 grid, 150 mines');
        expect(chaoticMode.rows, 20);
        expect(chaoticMode.columns, 20);
        expect(chaoticMode.mines, 150);
        expect(chaoticMode.enabled, isTrue);
      });

      test('should handle metadata changes safely', () async {
        // Test changing existing mode metadata
        const updatedModeJson = '''
        {
          "game_modes": [
            {
              "id": "easy",
              "name": "Super Easy",
              "description": "8×8 grid, 8 mines",
              "rows": 8,
              "columns": 8,
              "mines": 8,
              "enabled": true
            }
          ],
          "defaults": {
            "game_mode": "easy",
            "features": {
              "kickstarter_mode": false,
              "5050_detection": false,
              "5050_safe_move": false
            }
          }
        }
        ''';

        final json = jsonDecode(updatedModeJson);
        final modes = (json['game_modes'] as List)
            .map((mode) => GameMode.fromJson(mode))
            .toList();

        final updatedMode = modes.first;
        expect(updatedMode.id, 'easy');
        expect(updatedMode.name, 'Super Easy');
        expect(updatedMode.description, '8×8 grid, 8 mines');
        expect(updatedMode.rows, 8);
        expect(updatedMode.columns, 8);
        expect(updatedMode.mines, 8);
      });

      test('should handle disabled game modes', () {
        final allModes = config.allGameModes;
        final enabledModes = config.enabledGameModes;
        
        // Should have some disabled modes (like 'custom')
        expect(allModes.length, greaterThanOrEqualTo(enabledModes.length));
        
        // Verify disabled modes are not in enabled list
        final disabledModes = allModes.where((mode) => !mode.enabled).toList();
        expect(disabledModes.length, greaterThanOrEqualTo(1));
        
        for (final disabledMode in disabledModes) {
          expect(config.enabledGameModes.contains(disabledMode), isFalse);
        }
      });

      test('should handle invalid game mode gracefully', () {
        // Test with invalid mode ID
        final invalidMode = config.getGameMode('nonexistent');
        expect(invalidMode, isNull);
        
        // Test with empty mode ID
        final emptyMode = config.getGameMode('');
        expect(emptyMode, isNull);
      });

      test('should provide backward compatibility', () {
        final difficultyLevels = config.difficultyLevels;
        expect(difficultyLevels, isNotEmpty);
        
        // Verify each mode has the expected structure
        for (final entry in difficultyLevels.entries) {
          final modeId = entry.key;
          final modeData = entry.value;
          
          expect(modeData.containsKey('rows'), isTrue);
          expect(modeData.containsKey('columns'), isTrue);
          expect(modeData.containsKey('mines'), isTrue);
          
          expect(modeData['rows'], isA<int>());
          expect(modeData['columns'], isA<int>());
          expect(modeData['mines'], isA<int>());
        }
      });
    });

    group('JSON Schema Validation', () {
      test('should handle missing optional fields', () async {
        const minimalJson = '''
        {
          "game_modes": [
            {
              "id": "minimal",
              "name": "Minimal",
              "description": "Minimal config",
              "rows": 5,
              "columns": 5,
              "mines": 5,
              "enabled": true
            }
          ]
        }
        ''';

        final json = jsonDecode(minimalJson);
        final modes = (json['game_modes'] as List)
            .map((mode) => GameMode.fromJson(mode))
            .toList();

        expect(modes.length, 1);
        expect(modes.first.id, 'minimal');
      });

      test('should handle feature defaults', () {
        expect(config.defaultKickstarterMode, isA<bool>());
        expect(config.default5050Detection, isA<bool>());
        expect(config.default5050SafeMove, isA<bool>());
      });

      test('should handle extreme values safely', () async {
        const extremeJson = '''
        {
          "game_modes": [
            {
              "id": "extreme",
              "name": "Extreme",
              "description": "Very large board",
              "rows": 100,
              "columns": 100,
              "mines": 5000,
              "enabled": true
            }
          ]
        }
        ''';

        final json = jsonDecode(extremeJson);
        final modes = (json['game_modes'] as List)
            .map((mode) => GameMode.fromJson(mode))
            .toList();

        final extremeMode = modes.first;
        expect(extremeMode.rows, 100);
        expect(extremeMode.columns, 100);
        expect(extremeMode.mines, 5000);
      });
    });

    group('Runtime Safety', () {
      test('should reload config without errors', () async {
        // Test that reloading doesn't cause issues
        await config.reload();
        
        final modes = config.enabledGameModes;
        expect(modes.length, greaterThan(0));
        
        // Verify default mode still exists
        final defaultMode = config.defaultGameMode;
        expect(defaultMode, isNotNull);
      });

      test('should handle concurrent access safely', () async {
        // Test multiple simultaneous config accesses
        final futures = <Future>[];
        
        for (int i = 0; i < 10; i++) {
          futures.add(config.loadGameModes());
        }
        
        await Future.wait(futures);
        
        // Should still work correctly
        expect(config.enabledGameModes.length, greaterThan(0));
      });

      test('should provide consistent game mode lists', () {
        final modes1 = config.enabledGameModes;
        final modes2 = config.enabledGameModes;
        
        expect(modes1.length, modes2.length);
        expect(modes1.map((m) => m.id).toList(), modes2.map((m) => m.id).toList());
      });
    });

    group('Integration with Game Logic', () {
      test('should work with repository initialization', () async {
        final enabledModes = config.enabledGameModes;
        
        for (final mode in enabledModes) {
          // Test that each mode can be used to initialize a game
          expect(mode.rows * mode.columns, greaterThan(mode.mines));
          expect(mode.mines, greaterThanOrEqualTo(0));
          expect(mode.rows, greaterThan(0));
          expect(mode.columns, greaterThan(0));
        }
      });

      test('should handle new high-density modes', () async {
        // Test a new "chaotic" mode with high mine density
        final chaoticMode = GameMode(
          id: 'chaotic',
          name: 'Chaotic',
          description: '20×20 grid, 150 mines',
          rows: 20,
          columns: 20,
          mines: 150,
          enabled: true,
        );

        // Verify the mode is valid
        expect(chaoticMode.rows * chaoticMode.columns, 400);
        expect(chaoticMode.mines, 150);
        expect(chaoticMode.mines / (chaoticMode.rows * chaoticMode.columns), 0.375); // 37.5% mine density
        
        // This should be a valid configuration
        expect(chaoticMode.mines, lessThan(chaoticMode.rows * chaoticMode.columns));
      });
    });
  });
} 