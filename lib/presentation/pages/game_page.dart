import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/game_over_dialog.dart';
import 'settings_page.dart';
import '../../core/constants.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _showGameOverDialog = false;

  @override
  void initState() {
    super.initState();
    // Initialize game when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = context.read<SettingsProvider>();
      context.read<GameProvider>().initializeGame(settingsProvider.selectedDifficulty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper with ML'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // Show game over dialog when game ends
          if (gameProvider.isGameOver && !_showGameOverDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showGameOverDialog = true;
              _showGameOverModal(context, gameProvider);
            });
          }

          if (gameProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (gameProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${gameProvider.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final settingsProvider = context.read<SettingsProvider>();
                      gameProvider.initializeGame(settingsProvider.selectedDifficulty);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Game board
              Expanded(
                child: const GameBoard(),
              ),
              
              // Game controls
              _buildGameControls(context, gameProvider),
            ],
          );
        },
      ),
    );
  }

  void _showSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _showGameOverModal(BuildContext context, GameProvider gameProvider) {
    final gameState = gameProvider.gameState!;
    final isWin = gameProvider.isGameWon;
    final gameDuration = gameProvider.timerService.elapsed;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        isWin: isWin,
        gameDuration: gameDuration,
        onNewGame: () {
          Navigator.of(context).pop();
          _showGameOverDialog = false;
          final settingsProvider = context.read<SettingsProvider>();
          gameProvider.initializeGame(settingsProvider.selectedDifficulty);
        },
        onClose: () {
          Navigator.of(context).pop();
          _showGameOverDialog = false;
          // The board should already be in the correct state from the repository
          // No need to force a UI update
        },
      ),
    );
  }

  Widget _buildGameControls(BuildContext context, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              final settingsProvider = context.read<SettingsProvider>();
              gameProvider.initializeGame(settingsProvider.selectedDifficulty);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
          ),
          ElevatedButton.icon(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
          ),
        ],
      ),
    );
  }



  @override
  void dispose() {
    super.dispose();
  }
} 