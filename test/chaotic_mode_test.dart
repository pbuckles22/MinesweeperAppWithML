import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';
import 'package:flutter_minesweeper/data/repositories/game_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Chaotic Mode Integration Test', () {
    late GameRepositoryImpl repository;

    setUpAll(() async {
      await GameModeConfig.instance.loadGameModes();
    });

    setUp(() {
      repository = GameRepositoryImpl();
    });

    test('should load chaotic mode from JSON and verify properties', () {
      final config = GameModeConfig.instance;
      
      // Verify chaotic mode exists in the loaded config
      final chaoticMode = config.getGameMode('chaotic');
      expect(chaoticMode, isNotNull);
      
      if (chaoticMode != null) {
        expect(chaoticMode.id, 'chaotic');
        expect(chaoticMode.name, 'Chaotic');
        expect(chaoticMode.description, '20×20 grid, 150 mines');
        expect(chaoticMode.rows, 20);
        expect(chaoticMode.columns, 20);
        expect(chaoticMode.mines, 150);
        expect(chaoticMode.enabled, isTrue);
        
        // Verify it's a valid configuration
        expect(chaoticMode.rows * chaoticMode.columns, 400); // 20x20 = 400 cells
        expect(chaoticMode.mines, lessThan(chaoticMode.rows * chaoticMode.columns));
        
        // Calculate mine density
        final mineDensity = chaoticMode.mines / (chaoticMode.rows * chaoticMode.columns);
        expect(mineDensity, 0.375); // 37.5% mine density
        expect(mineDensity, greaterThan(0.3)); // Very high density
      }
    });

    test('should include chaotic mode in enabled game modes list', () {
      final config = GameModeConfig.instance;
      final enabledModes = config.enabledGameModes;
      
      // Verify chaotic mode is in the enabled list
      final chaoticMode = enabledModes.firstWhere(
        (mode) => mode.id == 'chaotic',
        orElse: () => throw StateError('Chaotic mode not found in enabled modes'),
      );
      
      expect(chaoticMode.name, 'Chaotic');
      expect(chaoticMode.enabled, isTrue);
    });

    test('should verify chaotic mode works with game repository', () async {
      final config = GameModeConfig.instance;
      final chaoticMode = config.getGameMode('chaotic');
      
      expect(chaoticMode, isNotNull);
      
      if (chaoticMode != null) {
        // Test that the repository can initialize a game with chaotic mode
        final gameState = await repository.initializeGame('chaotic');
        
        expect(gameState.rows, 20);
        expect(gameState.columns, 20);
        expect(gameState.minesCount, 150);
        expect(gameState.totalCells, 400);
        
        // Verify the board was created correctly
        expect(gameState.board.length, 20);
        expect(gameState.board[0].length, 20);
        
        // Count actual mines
        int mineCount = 0;
        for (int row = 0; row < gameState.rows; row++) {
          for (int col = 0; col < gameState.columns; col++) {
            if (gameState.getCell(row, col).hasBomb) {
              mineCount++;
            }
          }
        }
        expect(mineCount, 150);
      }
    });

    test('should verify chaotic mode appears in difficulty levels map', () {
      final config = GameModeConfig.instance;
      final difficultyLevels = config.difficultyLevels;
      
      expect(difficultyLevels.containsKey('chaotic'), isTrue);
      
      final chaoticData = difficultyLevels['chaotic'];
      expect(chaoticData, isNotNull);
      
      if (chaoticData != null) {
        expect(chaoticData['rows'], 20);
        expect(chaoticData['columns'], 20);
        expect(chaoticData['mines'], 150);
      }
    });

    test('should verify chaotic mode has higher mine density than other modes', () {
      final config = GameModeConfig.instance;
      final enabledModes = config.enabledGameModes;
      
      final chaoticMode = enabledModes.firstWhere((mode) => mode.id == 'chaotic');
      final easyMode = enabledModes.firstWhere((mode) => mode.id == 'easy');
      final normalMode = enabledModes.firstWhere((mode) => mode.id == 'normal');
      final hardMode = enabledModes.firstWhere((mode) => mode.id == 'hard');
      final expertMode = enabledModes.firstWhere((mode) => mode.id == 'expert');
      
      // Calculate mine densities
      final chaoticDensity = chaoticMode.mines / (chaoticMode.rows * chaoticMode.columns);
      final easyDensity = easyMode.mines / (easyMode.rows * easyMode.columns);
      final normalDensity = normalMode.mines / (normalMode.rows * normalMode.columns);
      final hardDensity = hardMode.mines / (hardMode.rows * hardMode.columns);
      final expertDensity = expertMode.mines / (expertMode.rows * expertMode.columns);
      
      // Chaotic should have the highest density
      expect(chaoticDensity, greaterThan(easyDensity));
      expect(chaoticDensity, greaterThan(normalDensity));
      expect(chaoticDensity, greaterThan(hardDensity));
      expect(chaoticDensity, greaterThan(expertDensity));
      
      // Verify the actual values
      expect(chaoticDensity, 0.375); // 37.5%
      expect(easyDensity, closeTo(0.123, 0.001)); // ~12.3%
      expect(normalDensity, closeTo(0.156, 0.001)); // ~15.6%
      expect(hardDensity, closeTo(0.206, 0.001)); // ~20.6%
      expect(expertDensity, closeTo(0.266, 0.001)); // ~26.6%
    });

    test('should verify chaotic mode is safe for deployment', () {
      final config = GameModeConfig.instance;
      final chaoticMode = config.getGameMode('chaotic');
      
      expect(chaoticMode, isNotNull);
      
      if (chaoticMode != null) {
        // Safety checks
        expect(chaoticMode.rows, greaterThan(0));
        expect(chaoticMode.columns, greaterThan(0));
        expect(chaoticMode.mines, greaterThan(0));
        expect(chaoticMode.mines, lessThan(chaoticMode.rows * chaoticMode.columns));
        expect(chaoticMode.enabled, isTrue);
        
        // Reasonable size limits
        expect(chaoticMode.rows, lessThan(100)); // Not too large
        expect(chaoticMode.columns, lessThan(100)); // Not too large
        expect(chaoticMode.mines, lessThan(1000)); // Not too many mines
        
        // Mine density should be reasonable (even if high)
        final density = chaoticMode.mines / (chaoticMode.rows * chaoticMode.columns);
        expect(density, lessThan(0.5)); // Should not exceed 50%
      }
    });
  });
} 