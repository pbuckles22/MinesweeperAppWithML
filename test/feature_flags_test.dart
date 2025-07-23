import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GameModeConfig.instance.loadGameModes();
    FeatureFlags.enableFirstClickGuarantee = GameModeConfig.instance.defaultKickstarterMode;
    FeatureFlags.enable5050Detection = GameModeConfig.instance.default5050Detection;
    FeatureFlags.enable5050SafeMove = GameModeConfig.instance.default5050SafeMove;
    // Set other flags as needed if your app does so
  });

  group('FeatureFlags', () {
    test('default values are set correctly', () {
      expect(FeatureFlags.enableFirstClickGuarantee, true); // from JSON
      expect(FeatureFlags.enable5050Detection, true);        // from JSON (now enabled)
      expect(FeatureFlags.enable5050SafeMove, true);         // from JSON
      // Update expectations to match JSON config defaults
      expect(FeatureFlags.enableGameStatistics, true);       // from JSON
      expect(FeatureFlags.enableHapticFeedback, true);       // from JSON
      expect(FeatureFlags.enableBoardReset, false);          // from JSON
      expect(FeatureFlags.enableCustomDifficulty, false);    // from JSON
      expect(FeatureFlags.enableUndoMove, false);            // from JSON
      expect(FeatureFlags.enableHintSystem, false);          // from JSON
      expect(FeatureFlags.enableAutoFlag, false);            // from JSON
      expect(FeatureFlags.enableBestTimes, false);           // from JSON
      expect(FeatureFlags.enableDarkMode, false);            // from JSON
      expect(FeatureFlags.enableAnimations, false);          // from JSON
      expect(FeatureFlags.enableSoundEffects, false);        // from JSON
      expect(FeatureFlags.enableMLAssistance, false);        // from JSON
      expect(FeatureFlags.enableAutoPlay, false);            // from JSON
      expect(FeatureFlags.enableDifficultyPrediction, false); // from JSON
      expect(FeatureFlags.enableDebugMode, false);           // from JSON
      expect(FeatureFlags.enablePerformanceMetrics, false);  // from JSON
      expect(FeatureFlags.enableTestMode, false);            // from JSON
    });

    test('flags can be modified', () {
      final originalValue = FeatureFlags.enableFirstClickGuarantee;
      FeatureFlags.enableFirstClickGuarantee = false;
      expect(FeatureFlags.enableFirstClickGuarantee, false);
      FeatureFlags.enableFirstClickGuarantee = originalValue;
      expect(FeatureFlags.enableFirstClickGuarantee, originalValue);
    });

    test('all flags are boolean values', () {
      expect(FeatureFlags.enableFirstClickGuarantee, isA<bool>());
      expect(FeatureFlags.enableGameStatistics, isA<bool>());
      expect(FeatureFlags.enableBoardReset, isA<bool>());
      expect(FeatureFlags.enableCustomDifficulty, isA<bool>());
      expect(FeatureFlags.enableUndoMove, isA<bool>());
      expect(FeatureFlags.enableHintSystem, isA<bool>());
      expect(FeatureFlags.enableAutoFlag, isA<bool>());
      expect(FeatureFlags.enableBestTimes, isA<bool>());
      expect(FeatureFlags.enable5050Detection, isA<bool>());
      expect(FeatureFlags.enable5050SafeMove, isA<bool>());
      expect(FeatureFlags.enableDarkMode, isA<bool>());
      expect(FeatureFlags.enableAnimations, isA<bool>());
      expect(FeatureFlags.enableSoundEffects, isA<bool>());
      expect(FeatureFlags.enableHapticFeedback, isA<bool>());
      expect(FeatureFlags.enableMLAssistance, isA<bool>());
      expect(FeatureFlags.enableAutoPlay, isA<bool>());
      expect(FeatureFlags.enableDifficultyPrediction, isA<bool>());
      expect(FeatureFlags.enableDebugMode, isA<bool>());
      expect(FeatureFlags.enablePerformanceMetrics, isA<bool>());
      expect(FeatureFlags.enableTestMode, isA<bool>());
    });
  });
} 