import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_minesweeper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Basic UI test - app launches and shows main screen', (tester) async {
    print('🚀 Starting basic UI test...');
    
    // Launch the app
    app.main();
    await tester.pumpAndSettle();
    
    print('✅ App launched!');
    
    // Check if we can find the game board (since it loads with Hard difficulty by default)
    expect(find.byType(GestureDetector), findsWidgets);
    
    // Also check for common game elements
    expect(find.byType(Container), findsWidgets);
    
    print('✅ Main screen elements found!');
    
    // Wait a moment so you can see it
    await Future.delayed(const Duration(seconds: 2));
    
    print('✅ Basic UI test completed successfully!');
  });
} 