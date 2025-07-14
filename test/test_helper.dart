import 'package:flutter_test/flutter_test.dart';
import '../lib/core/game_mode_config.dart';

/// Initialize GameModeConfig for tests
Future<void> initializeTestConfig() async {
  await GameModeConfig.instance.loadGameModes();
}

/// Setup test environment
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeTestConfig();
} 