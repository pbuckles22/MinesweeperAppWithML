import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

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