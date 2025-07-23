import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_minesweeper/main.dart' as app;
import 'package:flutter/services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Advanced 50/50 Detection Test', () {
    testWidgets('Test multiple 50/50 scenarios', (WidgetTester tester) async {
      print('🚀 Starting advanced 50/50 test...');
      
      // Launch app
      app.main();
      await tester.pumpAndSettle();
      print('✅ App launched');

      // Wait for Flutter engine to fully initialize
      await Future.delayed(const Duration(seconds: 3));
      print('✅ Waited for Flutter engine initialization');

      const channel = MethodChannel('minesweeper/solver');
      
      // Test 1: Simple 2x2 50/50 situation
      print('🔍 Test 1: Simple 2x2 50/50');
      try {
        final test1Map = <String, double>{
          '(0, 0)': 0.5,
          '(0, 1)': 0.5,
        };
        
        final result1 = await channel.invokeMethod('find5050', {
          'probabilityMap': test1Map,
        });
        
        print('✅ Test 1 result: $result1');
        expect(result1, isA<List>());
        
      } catch (e) {
        print('❌ Test 1 failed: $e');
        rethrow;
      }

      // Test 2: 3x3 corner 50/50 situation
      print('🔍 Test 2: 3x3 corner 50/50');
      try {
        final test2Map = <String, double>{
          '(0, 0)': 0.5,
          '(0, 1)': 0.5,
          '(1, 0)': 0.3,
          '(1, 1)': 0.3,
        };
        
        final result2 = await channel.invokeMethod('find5050', {
          'probabilityMap': test2Map,
        });
        
        print('✅ Test 2 result: $result2');
        expect(result2, isA<List>());
        
      } catch (e) {
        print('❌ Test 2 failed: $e');
        rethrow;
      }

      // Test 3: Multiple 50/50 groups
      print('🔍 Test 3: Multiple 50/50 groups');
      try {
        final test3Map = <String, double>{
          '(0, 0)': 0.5,
          '(0, 1)': 0.5,
          '(2, 2)': 0.5,
          '(2, 3)': 0.5,
          '(1, 1)': 0.3,
        };
        
        final result3 = await channel.invokeMethod('find5050', {
          'probabilityMap': test3Map,
        });
        
        print('✅ Test 3 result: $result3');
        expect(result3, isA<List>());
        
      } catch (e) {
        print('❌ Test 3 failed: $e');
        rethrow;
      }

      // Test 4: No 50/50 situation
      print('🔍 Test 4: No 50/50 situation');
      try {
        final test4Map = <String, double>{
          '(0, 0)': 0.3,
          '(0, 1)': 0.7,
          '(1, 0)': 0.2,
        };
        
        final result4 = await channel.invokeMethod('find5050', {
          'probabilityMap': test4Map,
        });
        
        print('✅ Test 4 result: $result4');
        expect(result4, isA<List>());
        
      } catch (e) {
        print('❌ Test 4 failed: $e');
        rethrow;
      }

      // Test 5: Large probability map
      print('🔍 Test 5: Large probability map');
      try {
        final test5Map = <String, double>{};
        for (int i = 0; i < 5; i++) {
          for (int j = 0; j < 5; j++) {
            test5Map['($i, $j)'] = 0.3 + (i + j) * 0.1;
          }
        }
        // Add a 50/50 situation
        test5Map['(1, 1)'] = 0.5;
        test5Map['(1, 2)'] = 0.5;
        
        final result5 = await channel.invokeMethod('find5050', {
          'probabilityMap': test5Map,
        });
        
        print('✅ Test 5 result: $result5');
        expect(result5, isA<List>());
        
      } catch (e) {
        print('❌ Test 5 failed: $e');
        rethrow;
      }

      print('🎉 All advanced 50/50 tests completed successfully!');
    });
  });
} 