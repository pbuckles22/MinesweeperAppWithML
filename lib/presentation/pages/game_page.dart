import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../../core/constants.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String _selectedDifficulty = 'beginner';

  @override
  void initState() {
    super.initState();
    // Initialize game when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().initializeGame(_selectedDifficulty);
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
            onPressed: _showDifficultyDialog,
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
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
                    onPressed: () => gameProvider.initializeGame(_selectedDifficulty),
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

  Widget _buildGameControls(BuildContext context, GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // New game button
          ElevatedButton.icon(
            onPressed: () => gameProvider.initializeGame(_selectedDifficulty),
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
          ),
          
          // Reset game button
          ElevatedButton.icon(
            onPressed: gameProvider.isGameInitialized 
                ? () => gameProvider.resetGame() 
                : null,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: GameConstants.difficultyLevels.keys.map((difficulty) {
            final config = GameConstants.difficultyLevels[difficulty]!;
            return ListTile(
              title: Text(difficulty.toUpperCase()),
              subtitle: Text(
                '${config['rows']}x${config['columns']} - ${config['mines']} mines',
              ),
              trailing: _selectedDifficulty == difficulty 
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                setState(() {
                  _selectedDifficulty = difficulty;
                });
                context.read<GameProvider>().initializeGame(difficulty);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
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