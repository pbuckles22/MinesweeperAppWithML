import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/cell.dart';
import '../../domain/entities/game_state.dart';
import '../providers/game_provider.dart';
import 'cell_widget.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.gameState;
        
        if (gameState == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            // Game header with stats
            _buildGameHeader(context, gameProvider),
            
            // Game board
            Expanded(
              child: _buildBoard(context, gameProvider, gameState),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameHeader(BuildContext context, GameProvider gameProvider) {
    final gameState = gameProvider.gameState!;
    final stats = gameProvider.getGameStatistics();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mine counter
          _buildStatCard(
            context,
            'Mines',
            '${gameProvider.getRemainingMines()}',
            Icons.warning,
          ),
          
          // Timer
          _buildStatCard(
            context,
            'Time',
            '${stats['gameDuration'] ?? 0}s',
            Icons.timer,
          ),
          
          // Progress
          _buildStatCard(
            context,
            'Progress',
            _progressString(gameState.progressPercentage),
            Icons.bar_chart,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(BuildContext context, GameProvider gameProvider, GameState gameState) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gameState.columns,
        childAspectRatio: 1.0,
      ),
      itemCount: gameState.rows * gameState.columns,
      itemBuilder: (context, index) {
        final row = index ~/ gameState.columns;
        final col = index % gameState.columns;
        
        return CellWidget(
          row: row,
          col: col,
          onTap: () => gameProvider.revealCell(row, col),
          onLongPress: () => gameProvider.toggleFlag(row, col),
        );
      },
    );
  }

  String _progressString(double progress) {
    if (progress.isNaN || progress.isInfinite || progress < 0) return '0%';
    final percent = (progress * 100).clamp(0, 100).toInt();
    return '$percent%';
  }
} 