import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/services/haptic_service.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HapticService', () {
    setUp(() {
      // Reset feature flag to default state before each test
      FeatureFlags.enableHapticFeedback = true;
    });

    group('when haptic feedback is enabled', () {
      test('lightImpact should not throw exception', () {
        expect(() => HapticService.lightImpact(), returnsNormally);
      });

      test('mediumImpact should not throw exception', () {
        expect(() => HapticService.mediumImpact(), returnsNormally);
      });

      test('heavyImpact should not throw exception', () {
        expect(() => HapticService.heavyImpact(), returnsNormally);
      });

      test('selectionClick should not throw exception', () {
        expect(() => HapticService.selectionClick(), returnsNormally);
      });

      test('vibrate should not throw exception', () {
        expect(() => HapticService.vibrate(), returnsNormally);
      });
    });

    group('when haptic feedback is disabled', () {
      setUp(() {
        FeatureFlags.enableHapticFeedback = false;
      });

      test('lightImpact should not throw exception', () {
        expect(() => HapticService.lightImpact(), returnsNormally);
      });

      test('mediumImpact should not throw exception', () {
        expect(() => HapticService.mediumImpact(), returnsNormally);
      });

      test('heavyImpact should not throw exception', () {
        expect(() => HapticService.heavyImpact(), returnsNormally);
      });

      test('selectionClick should not throw exception', () {
        expect(() => HapticService.selectionClick(), returnsNormally);
      });

      test('vibrate should not throw exception', () {
        expect(() => HapticService.vibrate(), returnsNormally);
      });
    });

    test('all methods should be callable regardless of feature flag state', () {
      // Test with feature flag enabled
      FeatureFlags.enableHapticFeedback = true;
      expect(() => HapticService.lightImpact(), returnsNormally);
      expect(() => HapticService.mediumImpact(), returnsNormally);
      expect(() => HapticService.heavyImpact(), returnsNormally);
      expect(() => HapticService.selectionClick(), returnsNormally);
      expect(() => HapticService.vibrate(), returnsNormally);

      // Test with feature flag disabled
      FeatureFlags.enableHapticFeedback = false;
      expect(() => HapticService.lightImpact(), returnsNormally);
      expect(() => HapticService.mediumImpact(), returnsNormally);
      expect(() => HapticService.heavyImpact(), returnsNormally);
      expect(() => HapticService.selectionClick(), returnsNormally);
      expect(() => HapticService.vibrate(), returnsNormally);
    });
  });
} 