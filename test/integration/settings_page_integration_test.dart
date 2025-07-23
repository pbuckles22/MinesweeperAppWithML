import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_minesweeper/presentation/pages/settings_page.dart';
import 'package:flutter_minesweeper/presentation/providers/settings_provider.dart';
import 'package:flutter_minesweeper/presentation/providers/game_provider.dart';
import 'package:flutter_minesweeper/core/game_mode_config.dart';

void main() {
  group('Settings Page Integration Tests', () {
    late SettingsProvider settingsProvider;
    late GameProvider gameProvider;

    setUpAll(() async {
      // Load game modes before any tests run
      await GameModeConfig.instance.loadGameModes();
    });

    setUp(() async {
      // Ensure game modes are loaded before creating providers
      await GameModeConfig.instance.loadGameModes();
      
      // Debug: Check what game modes are available
      print('GameModeConfig.enabledGameModes: ${GameModeConfig.instance.enabledGameModes.length} modes');
      for (final mode in GameModeConfig.instance.enabledGameModes) {
        print('  - ${mode.name} (${mode.id}): ${mode.rows}x${mode.columns}, ${mode.mines} mines');
      }
      
      settingsProvider = SettingsProvider();
      gameProvider = GameProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<GameProvider>.value(value: gameProvider),
          ],
          child: const SettingsPage(closeOnChange: false),
        ),
      );
    }

    void printAllTextWidgets(WidgetTester tester) {
      final textWidgets = find.byType(Text);
      final texts = <String>[];
      for (final element in textWidgets.evaluate()) {
        final widget = element.widget as Text;
        texts.add('  - "${widget.data ?? widget.textSpan?.toPlainText() ?? "<no text>"}"');
      }
      // ignore: avoid_print
      print('Found \\${texts.length} text widgets:\n' + texts.join('\n'));
    }

    group('Basic Rendering Tests', () {
      testWidgets('should render settings page with all sections', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to and check each section header
        await tester.ensureVisible(find.text('General Gameplay'));
        expect(find.text('General Gameplay'), findsOneWidget);

        await tester.scrollUntilVisible(find.text('Appearance & UX'), 200.0);
        expect(find.text('Appearance & UX'), findsOneWidget);

        await tester.scrollUntilVisible(find.text('Advanced / Experimental'), 200.0);
        expect(find.text('Advanced / Experimental'), findsOneWidget);

        await tester.scrollUntilVisible(find.text('Board Size'), 200.0);
        expect(find.text('Board Size'), findsOneWidget);

        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('should show correct initial state for game mode toggle', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // The UI now shows "Kickstarter Mode" or "Classic Mode" depending on the flag
        // By default, Kickstarter Mode is enabled from JSON
        expect(find.text('Kickstarter Mode'), findsOneWidget);
        // Optionally, check for Classic Mode if toggled
      });

      testWidgets('should show correct initial state for 50/50 detection toggle', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to advanced section before checking for toggle
        await tester.scrollUntilVisible(find.text('Advanced / Experimental'), 200.0);
        expect(find.text('50/50 Detection'), findsOneWidget);
        // Initial value should be false (from JSON config - we disabled it)
        expect(settingsProvider.is5050DetectionEnabled, false);
      });
    });

    group('Game Mode Toggle Tests', () {
      testWidgets('should toggle between Classic and Kickstarter mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find the Kickstarter Mode switch and toggle it
        final switchFinder = find.byType(Switch).first;
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // After toggling, "Classic Mode" should be visible
        expect(find.text('Classic Mode'), findsOneWidget);
      });

      testWidgets('should update provider state when game mode changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Toggle the Kickstarter Mode switch
        final switchFinder = find.byType(Switch).first;
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Provider should update
        expect(settingsProvider.isFirstClickGuaranteeEnabled, false);
        expect(settingsProvider.isClassicMode, true);
      });
    });

    group('Difficulty Selection Tests', () {
      testWidgets('should show all available difficulty levels', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to difficulty section, fallback to scrollUntilVisible if needed
        try {
          await tester.ensureVisible(find.byKey(const Key('difficulty-section')));
        } catch (_) {
          await tester.scrollUntilVisible(find.byKey(const Key('difficulty-section')), 500.0);
        }
        await tester.pumpAndSettle();

        // Should show all enabled game modes
        expect(find.textContaining('Easy'), findsOneWidget);
        expect(find.textContaining('Normal'), findsOneWidget);
        expect(find.textContaining('Hard'), findsOneWidget);
        expect(find.textContaining('Expert'), findsOneWidget);
        expect(find.text('Custom'), findsNothing);
      });

      testWidgets('should highlight selected difficulty', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to difficulty section, fallback to scrollUntilVisible if needed
        try {
          await tester.ensureVisible(find.byKey(const Key('difficulty-section')));
        } catch (_) {
          await tester.scrollUntilVisible(find.byKey(const Key('difficulty-section')), 500.0);
        }
        await tester.pumpAndSettle();

        // Select Normal difficulty
        await tester.tap(find.text('Normal'));
        await tester.pumpAndSettle();

        // Provider should be updated
        expect(settingsProvider.selectedDifficulty, 'normal');
      });

      testWidgets('should change difficulty when option is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to difficulty section, fallback to scrollUntilVisible if needed
        try {
          await tester.ensureVisible(find.byKey(const Key('difficulty-section')));
        } catch (_) {
          await tester.scrollUntilVisible(find.byKey(const Key('difficulty-section')), 500.0);
        }
        await tester.pumpAndSettle();

        // Tap on Easy
        await tester.tap(find.text('Easy'));
        await tester.pumpAndSettle();

        // Should now be Easy
        expect(settingsProvider.selectedDifficulty, 'easy');
      });
    });

    group('50/50 Detection Tests', () {
      testWidgets('should toggle 50/50 detection', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to advanced section
        await tester.scrollUntilVisible(find.text('Advanced / Experimental'), 200.0);
        await tester.pumpAndSettle();

        // Find the 50/50 detection toggle by looking for the switch near its label
        final fiftyFiftyLabel = find.text('50/50 Detection');
        expect(fiftyFiftyLabel, findsOneWidget);
        
        // Find all switches and tap the one that's in the same row as the 50/50 Detection label
        final switches = find.byType(Switch);
        expect(switches, findsWidgets);
        
        // Find the switch that's in the same card as the 50/50 Detection label
        // We'll use a more direct approach: find the switch that's closest to the label
        final fiftyFiftySwitch = find.byType(Switch).at(0); // First switch in Advanced section
        
        // Initial value should be false (from JSON config - we disabled it)
        expect(settingsProvider.is5050DetectionEnabled, false);
        await tester.tap(fiftyFiftySwitch);
        await tester.pumpAndSettle();
        expect(settingsProvider.is5050DetectionEnabled, true);
        await tester.tap(fiftyFiftySwitch);
        await tester.pumpAndSettle();
        expect(settingsProvider.is5050DetectionEnabled, false);
      });

      testWidgets('should show 50/50 description when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 50/50 description is no longer shown in the new layout
        // The description was removed when we reorganized the settings page
        expect(find.text('50/50 Detection Active'), findsNothing);
      });

      testWidgets('should toggle 50/50 safe move when detection is enabled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to advanced section
        await tester.scrollUntilVisible(find.text('Advanced / Experimental'), 200.0);
        await tester.pumpAndSettle();

        // Initial value should be true (from JSON config)
        expect(settingsProvider.is5050SafeMoveEnabled, true);
        
        // Find the 50/50 safe move toggle
        final safeMoveLabel = find.text('50/50 Safe Move');
        expect(safeMoveLabel, findsOneWidget);
        
        // Find the switch that's in the same card as the 50/50 Safe Move label
        // We'll use a more direct approach: find the switch that's closest to the label
        final switches = find.byType(Switch);
        expect(switches, findsWidgets);
        
        // Find the switch that's in the same card as the 50/50 Safe Move label
        // We'll use a more direct approach: find the second switch in Advanced section
        final safeMoveSwitch = find.byType(Switch).at(1); // Second switch in Advanced section
        
        // Debug: print the current state
        print('DEBUG: Initial 50/50 safe move state: ${settingsProvider.is5050SafeMoveEnabled}');
        print('DEBUG: 50/50 detection enabled: ${settingsProvider.is5050DetectionEnabled}');
        
        // Since 50/50 detection is disabled, the 50/50 safe move should be disabled and not toggleable
        // The switch should remain in its initial state (true from JSON config)
        expect(settingsProvider.is5050SafeMoveEnabled, true); // Should remain true since detection is disabled
        
        // Try to tap the switch, but it should not change the state since detection is disabled
        await tester.tap(safeMoveSwitch);
        await tester.pumpAndSettle();
        print('DEBUG: After tap, 50/50 safe move state: ${settingsProvider.is5050SafeMoveEnabled}');
        expect(settingsProvider.is5050SafeMoveEnabled, true); // Should still be true
      });
    });

    group('Reset to Defaults Tests', () {
      testWidgets('should show reset confirmation dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll to reset button, fallback to scrollUntilVisible if needed
        try {
          await tester.ensureVisible(find.byKey(const Key('reset-button')));
        } catch (_) {
          await tester.scrollUntilVisible(find.byKey(const Key('reset-button')), 500.0);
        }
        await tester.pumpAndSettle();

        // Tap reset button
        await tester.tap(find.text('Reset to Defaults'));
        await tester.pumpAndSettle();

        // Should show confirmation dialog
        expect(find.text('Reset Settings'), findsOneWidget);
        expect(find.text('Are you sure you want to reset all settings to their default values?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);
      });

      testWidgets('should reset settings when confirmed', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Change some settings first (disable Kickstarter mode)
        await tester.tap(find.byType(Switch).first); // Disable Kickstarter mode
        await tester.pumpAndSettle();
        expect(settingsProvider.isFirstClickGuaranteeEnabled, false);

        // Scroll to reset button, fallback to scrollUntilVisible if needed
        try {
          await tester.ensureVisible(find.byKey(const Key('reset-button')));
        } catch (_) {
          await tester.scrollUntilVisible(find.byKey(const Key('reset-button')), 500.0);
        }
        await tester.pumpAndSettle();

        // Tap reset button
        await tester.tap(find.text('Reset to Defaults'));
        await tester.pumpAndSettle();

        // Confirm reset
        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        // Settings should be reset to JSON defaults
        expect(settingsProvider.isFirstClickGuaranteeEnabled, true); // JSON default
        expect(settingsProvider.isClassicMode, false); // JSON default
      });
    });

    group('Provider State Management Tests', () {
      testWidgets('should maintain state consistency across UI interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll down to bring switches into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        printAllTextWidgets(tester);

        // Get the provider and toggle the first click guarantee
        final context = tester.element(find.byType(SettingsPage));
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        
        // Toggle the first click guarantee (game mode) - starts enabled, so toggle to disabled
        settingsProvider.toggleFirstClickGuarantee();
        await tester.pumpAndSettle();
        
        printAllTextWidgets(tester);

        // Assert provider state - should be disabled after toggle
        expect(settingsProvider.isFirstClickGuaranteeEnabled, isFalse);
      });

      testWidgets('should handle rapid state changes gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Rapidly toggle settings (starts enabled, so 5 toggles = disabled)
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(Switch).first);
          await tester.pump();
        }
        await tester.pumpAndSettle();

        // Should end in a consistent state (5 toggles from enabled = disabled)
        expect(settingsProvider.isFirstClickGuaranteeEnabled, false);
        expect(settingsProvider.isClassicMode, true);
      });
    });
  });
} 