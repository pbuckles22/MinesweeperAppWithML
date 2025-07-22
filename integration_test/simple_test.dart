import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_minesweeper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simple app launch test', (tester) async {
    print('🚀 Starting simple integration test...');
    
    // Launch the app
    app.main();
    await tester.pumpAndSettle();
    
    print('✅ App launched successfully!');
    
    // Wait a bit so you can see it's working
    await Future.delayed(const Duration(seconds: 3));
    
    print('✅ Simple test completed!');
  });
} 