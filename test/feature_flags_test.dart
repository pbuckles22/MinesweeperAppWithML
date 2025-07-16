import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';

void main() {
  group('FeatureFlags', () {
    test('default values are set correctly', () {
      expect(FeatureFlags.enableFirstClickGuarantee, true);
      expect(FeatureFlags.enableGameStatistics, true);
      expect(FeatureFlags.enableBoardReset, false);
      expect(FeatureFlags.enableCustomDifficulty, false);
      expect(FeatureFlags.enableUndoMove, false);
      expect(FeatureFlags.enableHintSystem, false);
      expect(FeatureFlags.enableAutoFlag, false);
      expect(FeatureFlags.enableBestTimes, false);
      expect(FeatureFlags.enable5050Detection, false);
      expect(FeatureFlags.enable5050SafeMove, false);
      expect(FeatureFlags.enableDarkMode, false);
      expect(FeatureFlags.enableAnimations, false);
      expect(FeatureFlags.enableSoundEffects, false);
      expect(FeatureFlags.enableHapticFeedback, true);
      expect(FeatureFlags.enableMLAssistance, false);
      expect(FeatureFlags.enableAutoPlay, false);
      expect(FeatureFlags.enableDifficultyPrediction, false);
      expect(FeatureFlags.enableDebugMode, false);
      expect(FeatureFlags.enablePerformanceMetrics, false);
      expect(FeatureFlags.enableTestMode, false);
    });

    test('flags can be modified', () {
      // Test that flags can be changed (useful for testing different configurations)
      final originalValue = FeatureFlags.enableFirstClickGuarantee;
      
      FeatureFlags.enableFirstClickGuarantee = false;
      expect(FeatureFlags.enableFirstClickGuarantee, false);
      
      // Restore original value
      FeatureFlags.enableFirstClickGuarantee = originalValue;
      expect(FeatureFlags.enableFirstClickGuarantee, originalValue);
    });

    test('all flags are boolean values', () {
      // Verify all flags are boolean (this test documents the expected types)
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