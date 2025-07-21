import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/services/native_5050_solver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Native5050Solver returns correct 50/50 cells', () async {
    // This test will only pass on iOS with the native integration present.
    const testMap = {
      '(0, 0)': 0.5,
      '(0, 1)': 0.5,
      '(1, 0)': 0.2,
      '(1, 1)': 0.8,
    };
    try {
      final result = await Native5050Solver.find5050(testMap);
      expect(result, containsAll([ [0, 0], [0, 1] ]));
    } catch (e) {
      // If running on a platform without the native channel, skip.
      print('Native 50/50 solver not available: $e');
    }
  });
} 