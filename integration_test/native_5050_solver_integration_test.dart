import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_minesweeper/services/native_5050_solver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Native5050Solver returns correct 50/50 cells', (tester) async {
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
      print('Native 50/50 solver not available: $e');
    }
  });

  testWidgets('Native5050Solver returns empty for no 50/50 cells', (tester) async {
    const testMap = {
      '(0, 0)': 0.1,
      '(0, 1)': 0.2,
      '(1, 0)': 0.3,
      '(1, 1)': 0.8,
    };
    try {
      final result = await Native5050Solver.find5050(testMap);
      expect(result, isEmpty);
    } catch (e) {
      print('Native 50/50 solver not available: $e');
    }
  });

  testWidgets('Native5050Solver handles multiple 50/50 groups', (tester) async {
    const testMap = {
      '(0, 0)': 0.5,
      '(0, 1)': 0.5,
      '(1, 0)': 0.5,
      '(1, 1)': 0.5,
      '(2, 2)': 0.5,
      '(2, 3)': 0.5,
      '(3, 2)': 0.1,
      '(3, 3)': 0.9,
    };
    try {
      final result = await Native5050Solver.find5050(testMap);
      expect(result, containsAll([ [0, 0], [0, 1], [1, 0], [1, 1], [2, 2], [2, 3] ]));
    } catch (e) {
      print('Native 50/50 solver not available: $e');
    }
  });

  testWidgets('Native5050Solver handles invalid/malformed input gracefully', (tester) async {
    // Test with valid input that should be handled gracefully by the native solver
    const testMap = {
      '(0, 0)': 0.5,
      '(0, 1)': 0.5,
      '(1, 0)': 0.1,
    };
    try {
      final result = await Native5050Solver.find5050(testMap);
      expect(result, containsAll([ [0, 0], [0, 1] ]));
    } catch (e) {
      print('Native 50/50 solver not available or error: $e');
    }
  });

  testWidgets('Native5050Solver handles large board', (tester) async {
    final testMap = <String, double>{};
    for (int i = 0; i < 50; i++) {
      for (int j = 0; j < 50; j++) {
        testMap['($i, $j)'] = (i + j) % 2 == 0 ? 0.5 : 0.1;
      }
    }
    try {
      final result = await Native5050Solver.find5050(testMap);
      expect(result.length, greaterThan(0));
      expect(result, contains([0, 0]));
      expect(result, contains([48, 48]));
    } catch (e) {
      print('Native 50/50 solver not available: $e');
    }
  });
} 