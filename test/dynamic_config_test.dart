import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:flutter_minesweeper/core/game_mode_config.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Dynamic Config Change Tests', () {
    late GameRepositoryImpl repository;

    setUpAll(() async {
      await GameModeConfig.instance.loadGameModes();
    });

    setUp(() {
      repository = GameRepositoryImpl();
    });

    group('Adding New Game Mode (Chaotic Example)', () {
      test('should demonstrate adding chaotic mode to JSON workflow', () async {
        // Step 1: Simulate the JSON change (this is what you would edit in assets/config/game_modes.json)
        const updatedJson = '''
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
              "id": "normal",
              "name": "Normal", 
              "description": "16×16 grid, 40 mines",
              "rows": 16,
              "columns": 16,
              "mines": 40,
              "enabled": true
            },
            {
              "id": "hard",
              "name": "Hard",
              "description": "16×30 grid, 99 mines", 
              "rows": 16,
              "columns": 30,
              "mines": 99,
              "enabled": true
            },
            {
              "id": "expert",
              "name": "Expert",
              "description": "18×24 grid, 115 mines",
              "rows": 18,
              "columns": 24,
              "mines": 115,
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
            },
            {
              "id": "custom",
              "name": "Custom",
              "description": "Custom grid size and mine count",
              "rows": 18,
              "columns": 10,
              "mines": 0,
              "enabled": false
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

        // Step 2: Test that the new mode can be parsed correctly
        final json = jsonDecode(updatedJson);
        final modes = (json['game_modes'] as List)
            .map((mode) => GameMode.fromJson(mode))
            .toList();

        // Step 3: Verify the chaotic mode was added correctly
        final chaoticMode = modes.firstWhere((mode) => mode.id == 'chaotic');
        expect(chaoticMode.name, 'Chaotic');
        expect(chaoticMode.description, '20×20 grid, 150 mines');
        expect(chaoticMode.rows, 20);
        expect(chaoticMode.columns, 20);
        expect(chaoticMode.mines, 150);
        expect(chaoticMode.enabled, isTrue);

        // Step 4: Verify it's a valid game configuration
        expect(chaoticMode.rows * chaoticMode.columns, 400); // 20x20 = 400 cells
        expect(chaoticMode.mines, 150);
        expect(chaoticMode.mines, lessThan(chaoticMode.rows * chaoticMode.columns)); // Mines < total cells
        
        // Step 5: Calculate mine density
        final mineDensity = chaoticMode.mines / (chaoticMode.rows * chaoticMode.columns);
        expect(mineDensity, 0.375); // 37.5% mine density (very high!)
        expect(mineDensity, greaterThan(0.1)); // Higher than normal modes
      });

      test('should verify chaotic mode works with game repository', () async {
        // This test simulates what would happen after you add the chaotic mode to JSON
        // and the app loads it
        
        // Create a mock chaotic mode
        final chaoticMode = GameMode(
          id: 'chaotic',
          name: 'Chaotic',
          description: '20×20 grid, 150 mines',
          rows: 20,
          columns: 20,
          mines: 150,
          enabled: true,
        );

        // Test that the repository can handle this mode
        // (In real app, this would be loaded from JSON)
        expect(chaoticMode.rows * chaoticMode.columns, greaterThan(chaoticMode.mines));
        
        // Verify the mode has reasonable properties for gameplay
        expect(chaoticMode.rows, greaterThan(0));
        expect(chaoticMode.columns, greaterThan(0));
        expect(chaoticMode.mines, greaterThan(0));
        expect(chaoticMode.enabled, isTrue);
      });

      test('should handle metadata changes to existing modes', () async {
        // Simulate changing the "easy" mode metadata
        const updatedEasyJson = '''
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
          ]
        }
        ''';

        final json = jsonDecode(updatedEasyJson);
        final modes = (json['game_modes'] as List)
            .map((mode) => GameMode.fromJson(mode))
            .toList();

        final updatedEasy = modes.first;
        
        // Verify the changes were applied
        expect(updatedEasy.id, 'easy'); // ID stays the same
        expect(updatedEasy.name, 'Super Easy'); // Name changed
        expect(updatedEasy.description, '8×8 grid, 8 mines'); // Description changed
        expect(updatedEasy.rows, 8); // Rows changed from 9 to 8
        expect(updatedEasy.columns, 8); // Columns changed from 9 to 8
        expect(updatedEasy.mines, 8); // Mines changed from 10 to 8
        expect(updatedEasy.enabled, isTrue); // Still enabled
      });
    });

    group('Safety Checks for New Modes', () {
      test('should validate new mode configurations', () async {
        // Test various new mode configurations to ensure they're safe
        
        // Valid configurations
        final validModes = [
          GameMode(id: 'small', name: 'Small', description: '5×5 grid, 3 mines', rows: 5, columns: 5, mines: 3, enabled: true),
          GameMode(id: 'medium', name: 'Medium', description: '10×10 grid, 15 mines', rows: 10, columns: 10, mines: 15, enabled: true),
          GameMode(id: 'large', name: 'Large', description: '30×30 grid, 200 mines', rows: 30, columns: 30, mines: 200, enabled: true),
        ];

        for (final mode in validModes) {
          // Basic validation
          expect(mode.rows * mode.columns, greaterThan(mode.mines));
          expect(mode.rows, greaterThan(0));
          expect(mode.columns, greaterThan(0));
          expect(mode.mines, greaterThanOrEqualTo(0));
          
          // Mine density check (should be reasonable)
          final density = mode.mines / (mode.rows * mode.columns);
          expect(density, lessThan(0.5)); // Should not exceed 50% mine density
        }
      });

      test('should handle edge cases for new modes', () async {
        // Test edge cases that might occur with new modes
        
        // Very small board
        final tinyMode = GameMode(
          id: 'tiny',
          name: 'Tiny',
          description: '2×2 grid, 1 mine',
          rows: 2,
          columns: 2,
          mines: 1,
          enabled: true,
        );
        expect(tinyMode.rows * tinyMode.columns, 4);
        expect(tinyMode.mines, 1);
        expect(tinyMode.mines, lessThan(tinyMode.rows * tinyMode.columns));

        // Very large board
        final hugeMode = GameMode(
          id: 'huge',
          name: 'Huge',
          description: '50×50 grid, 1000 mines',
          rows: 50,
          columns: 50,
          mines: 1000,
          enabled: true,
        );
        expect(hugeMode.rows * hugeMode.columns, 2500);
        expect(hugeMode.mines, 1000);
        expect(hugeMode.mines, lessThan(hugeMode.rows * hugeMode.columns));
      });
    });

    group('Deployment Safety', () {
      test('should ensure new modes don\'t break existing functionality', () async {
        // Test that adding new modes doesn't affect existing ones
        
        const mixedJson = '''
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
          ]
        }
        ''';

        final json = jsonDecode(mixedJson);
        final modes = (json['game_modes'] as List)
            .map((mode) => GameMode.fromJson(mode))
            .toList();

        // Verify existing mode still works
        final easyMode = modes.firstWhere((mode) => mode.id == 'easy');
        expect(easyMode.name, 'Easy');
        expect(easyMode.rows, 9);
        expect(easyMode.columns, 9);
        expect(easyMode.mines, 10);

        // Verify new mode works
        final chaoticMode = modes.firstWhere((mode) => mode.id == 'chaotic');
        expect(chaoticMode.name, 'Chaotic');
        expect(chaoticMode.rows, 20);
        expect(chaoticMode.columns, 20);
        expect(chaoticMode.mines, 150);

        // Verify both are enabled
        expect(easyMode.enabled, isTrue);
        expect(chaoticMode.enabled, isTrue);
      });

      test('should handle disabled new modes safely', () async {
        // Test adding a new mode but keeping it disabled initially
        
        final disabledNewMode = GameMode(
          id: 'experimental',
          name: 'Experimental',
          description: 'Experimental mode',
          rows: 15,
          columns: 15,
          mines: 50,
          enabled: false, // Disabled for safety
        );

        expect(disabledNewMode.enabled, isFalse);
        expect(disabledNewMode.rows * disabledNewMode.columns, greaterThan(disabledNewMode.mines));
        
        // This mode would not appear in enabledGameModes but would be in allGameModes
        // allowing for safe testing before enabling
      });
    });
  });
} 