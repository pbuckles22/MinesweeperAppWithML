import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/pages/game_page.dart';
import 'core/game_mode_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize game mode configuration
  await GameModeConfig.instance.loadGameModes();
  
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