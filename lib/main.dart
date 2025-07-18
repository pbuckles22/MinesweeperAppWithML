import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'presentation/providers/game_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'core/game_mode_config.dart';
import 'core/feature_flags.dart';
import 'presentation/pages/game_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Validate game configuration before app starts
  try {
    await GameModeConfig.instance.loadGameModes();
    
    // Initialize FeatureFlags from JSON configuration
    // This ensures the flags are set before any providers are created
    FeatureFlags.enableFirstClickGuarantee = GameModeConfig.instance.defaultKickstarterMode;
    FeatureFlags.enable5050Detection = GameModeConfig.instance.default5050Detection;
    FeatureFlags.enable5050SafeMove = GameModeConfig.instance.default5050SafeMove;
    
    // print('DEBUG: main - FeatureFlags initialized from JSON:');
    // print('DEBUG:   enableFirstClickGuarantee: ${FeatureFlags.enableFirstClickGuarantee}');
    // print('DEBUG:   enable5050Detection: ${FeatureFlags.enable5050Detection}');
    // print('DEBUG:   enable5050SafeMove: ${FeatureFlags.enable5050SafeMove}');
    
    // print('Game configuration validation passed');
  } catch (e) {
    // print('CRITICAL ERROR: Game configuration validation failed: $e');
    // print('App will exit due to configuration error.');
    // Force exit the app immediately
    exit(1);
  }
  
  runApp(const MinesweeperApp());
}

// Hot reload support for development
void hotReload() async {
  await GameModeConfig.instance.reload();
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Minesweeper with ML',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const GamePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}