import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/game_provider.dart';
import '../../core/game_mode_config.dart';
import '../../core/icon_utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Game Mode Section
              _buildSectionHeader(context, 'Game Mode'),
              const SizedBox(height: 8),
              
              // First Click Guarantee Toggle
              _buildGameModeToggle(context, settingsProvider),
              const SizedBox(height: 16),
              
              // Mode Description
              _buildModeDescription(context, settingsProvider),
              const SizedBox(height: 24),
              
              // Board Size Section
              _buildSectionHeader(context, 'Board Size'),
              const SizedBox(height: 8),
              
              // Difficulty Selection
              _buildDifficultySelection(context, settingsProvider),
              const SizedBox(height: 24),
              
              // Reset to Defaults
              _buildResetButton(context, settingsProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildGameModeToggle(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settingsProvider.isKickstarterMode ? 'Kickstarter Mode' : 'Classic Mode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settingsProvider.isKickstarterMode 
                            ? 'First click always reveals a cascade'
                            : 'Classic Minesweeper rules',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settingsProvider.isFirstClickGuaranteeEnabled,
                  onChanged: (value) {
                    settingsProvider.setGameMode(value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeDescription(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  settingsProvider.isKickstarterMode ? Icons.auto_awesome : Icons.sports_esports,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  settingsProvider.isKickstarterMode ? 'Kickstarter Mode' : 'Classic Mode',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              settingsProvider.isKickstarterMode
                  ? 'The first click will always reveal a cascade (blank area), giving you a meaningful starting position. Mines are intelligently moved to ensure this happens.'
                  : 'Traditional Minesweeper rules. The first click could hit a mine, revealing a single numbered cell, or trigger a cascade. Pure random chance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelection(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Difficulty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dynamic difficulty options from JSON config
            ...GameModeConfig.instance.enabledGameModes.map((mode) {
              return Column(
                children: [
                  _buildDifficultyOption(
                    context,
                    settingsProvider,
                    mode.name,
                    mode.description,
                    mode.id,
                    IconUtils.getIconFromString(mode.icon) ?? Icons.games,
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }



  Widget _buildDifficultyOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    String title,
    String subtitle,
    String difficulty,
    IconData icon,
  ) {
    final isSelected = settingsProvider.selectedDifficulty == difficulty;
    
    return InkWell(
      onTap: () {
        _handleDifficultyChange(context, settingsProvider, difficulty);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _handleDifficultyChange(
    BuildContext context,
    SettingsProvider settingsProvider,
    String newDifficulty,
  ) {
    // Check if there's an active game
    final gameProvider = context.read<GameProvider>();
    final hasActiveGame = gameProvider.gameState != null && 
                         gameProvider.gameState!.gameStatus == 'playing';
    
    if (hasActiveGame) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game in Progress'),
          content: const Text(
            'You have a game in progress. Changing the difficulty will start a new game. Do you want to continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                settingsProvider.setDifficulty(newDifficulty);
                // Start new game with new difficulty
                gameProvider.initializeGame(newDifficulty);
              },
              child: const Text('Start New Game'),
            ),
          ],
        ),
      );
    } else {
      // No active game, just change difficulty
      settingsProvider.setDifficulty(newDifficulty);
    }
  }

  Widget _buildResetButton(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.restore),
        title: const Text('Reset to Defaults'),
        subtitle: const Text('Restore all settings to their default values'),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Reset Settings'),
              content: const Text('Are you sure you want to reset all settings to their default values?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    settingsProvider.resetToDefaults();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings reset to defaults'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 