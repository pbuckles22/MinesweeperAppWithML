import 'package:flutter_test/flutter_test.dart';
import '../lib/core/game_mode_config.dart';
import 'package:flutter_minesweeper/services/timer_service.dart';
import 'package:flutter_minesweeper/core/feature_flags.dart';

/// Initialize GameModeConfig for tests
Future<void> initializeTestConfig() async {
  await GameModeConfig.instance.loadGameModes();
}

/// Setup test environment
Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Enable test mode to prevent native solver calls during tests
  FeatureFlags.enableTestMode = true;
  
  await initializeTestConfig();
} 