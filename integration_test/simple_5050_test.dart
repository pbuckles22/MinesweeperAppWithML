import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_minesweeper/services/native_5050_solver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simple 50/50 test - basic functionality', (tester) async {
    print('🚀 Starting simple 50/50 test...');
    
    const testMap = {
      '(0, 0)': 0.5,
      '(0, 1)': 0.5,
      '(1, 0)': 0.2,
      '(1, 1)': 0.8,
    };
    
    try {
      print('📞 Calling native 50/50 solver...');
      final result = await Native5050Solver.find5050(testMap);
      print('✅ Result: $result');
      expect(result, containsAll([ [0, 0], [0, 1] ]));
      print('✅ Test passed!');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  });
} 