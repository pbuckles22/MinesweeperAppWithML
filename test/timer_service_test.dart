import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/services/timer_service.dart';
import 'dart:async';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TimerService', () {
    late TimerService timerService;

    setUp(() {
      timerService = TimerService();
    });

    tearDown(() {
      timerService.dispose();
    });

    test('should start and update elapsed time', () async {
      timerService.start();
      expect(timerService.isRunning, true);
      await Future.delayed(const Duration(milliseconds: 1100));
      expect(timerService.elapsed.inSeconds, greaterThanOrEqualTo(1));
    });

    test('should stop and not update elapsed time', () async {
      timerService.start();
      await Future.delayed(const Duration(milliseconds: 1100));
      timerService.stop();
      final elapsed = timerService.elapsed;
      await Future.delayed(const Duration(milliseconds: 1100));
      expect(timerService.elapsed, elapsed);
      expect(timerService.isRunning, false);
    });

    test('should reset elapsed time', () async {
      timerService.start();
      await Future.delayed(const Duration(milliseconds: 1100));
      timerService.reset();
      expect(timerService.elapsed, Duration.zero);
      expect(timerService.isRunning, false);
    });
  });
} 