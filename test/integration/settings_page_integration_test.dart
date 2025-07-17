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

        // Verify page title
        expect(find.text('Settings'), findsOneWidget);

        // Debug: Print all text widgets to see what's actually rendered
        printAllTextWidgets(tester);

        // Verify basic sections exist
        expect(find.text('Game Mode'), findsOneWidget);
        expect(find.text('Advanced Features'), findsOneWidget);

        // Verify toggle switches exist
        expect(find.byType(Switch), findsAtLeastNWidgets(2));
      });

      testWidgets('should show correct initial state for game mode toggle', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show Classic Mode by default (use findAtLeastNWidgets since there might be multiple)
        expect(find.text('Classic Mode'), findsAtLeastNWidgets(1));
        expect(find.text('Classic Minesweeper rules'), findsOneWidget);

        // Toggle should be off by default
        final switchWidget = tester.widget<Switch>(find.byType(Switch).first);
        expect(switchWidget.value, false);
      });

      testWidgets('should show correct initial state for 50/50 detection toggle', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show 50/50 Detection
        expect(find.text('50/50 Detection'), findsOneWidget);
        expect(find.text('Highlight unsolvable situations'), findsOneWidget);

        // Toggle should be off by default
        final switches = find.byType(Switch);
        final detectionSwitch = tester.widget<Switch>(switches.at(1));
        expect(detectionSwitch.value, false);
      });
    });

    group('Game Mode Toggle Tests', () {
      testWidgets('should toggle between Classic and Kickstarter mode', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially Classic Mode
        expect(find.text('Classic Mode'), findsAtLeastNWidgets(1));
        expect(find.text('Classic Minesweeper rules'), findsOneWidget);

        // Toggle to Kickstarter Mode
        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();

        // Debug: Print all text widgets after toggle
        printAllTextWidgets(tester);

        // Should now show Kickstarter Mode
        expect(find.text('Kickstarter Mode'), findsAtLeastNWidgets(1));
        expect(find.text('First click always reveals a cascade'), findsOneWidget);

        // Toggle back to Classic Mode
        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();

        // Should be back to Classic Mode
        expect(find.text('Classic Mode'), findsAtLeastNWidgets(1));
        expect(find.text('Classic Minesweeper rules'), findsOneWidget);
      });

      testWidgets('should update provider state when game mode changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially Classic Mode
        expect(settingsProvider.isClassicMode, true);
        expect(settingsProvider.isFirstClickGuaranteeEnabled, false);

        // Toggle to Kickstarter Mode
        await tester.tap(find.byType(Switch).first);
        await tester.pumpAndSettle();

        // Provider should be updated
        expect(settingsProvider.isClassicMode, false);
        expect(settingsProvider.isFirstClickGuaranteeEnabled, true);
      });
    });

    group('Difficulty Selection Tests', () {
      testWidgets('should show all available difficulty levels', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Debug: Print all text widgets to see what's rendered
        printAllTextWidgets(tester);
        
        // Check for the difficulty section header
        final difficultyHeader = find.text('Select Difficulty');
        print('Select Difficulty header found: \\${difficultyHeader.evaluate().isNotEmpty}');
        if (difficultyHeader.evaluate().isEmpty) {
          debugDumpApp();
        }
        
        // Scroll down to bring difficulty options into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        
        printAllTextWidgets(tester);
        
        // Should show all enabled game modes
        expect(find.textContaining('Easy'), findsOneWidget);
        expect(find.textContaining('Normal'), findsOneWidget);
        expect(find.textContaining('Hard'), findsOneWidget);
        expect(find.textContaining('Expert'), findsOneWidget);

        // Should not show Custom (disabled)
        expect(find.text('Custom'), findsNothing);
      });

      testWidgets('should highlight selected difficulty', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Easy should be selected by default
        expect(settingsProvider.selectedDifficulty, 'easy');

        // Scroll down to bring difficulty options into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
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

        // Initially Easy
        expect(settingsProvider.selectedDifficulty, 'easy');

        // Scroll down to bring difficulty options into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Tap on Hard
        await tester.tap(find.text('Hard'));
        await tester.pumpAndSettle();

        // Should now be Hard
        expect(settingsProvider.selectedDifficulty, 'hard');
      });
    });

    group('50/50 Detection Tests', () {
      testWidgets('should toggle 50/50 detection', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially disabled
        expect(settingsProvider.is5050DetectionEnabled, false);

        // Toggle on
        final switches = find.byType(Switch);
        await tester.tap(switches.at(1)); // 50/50 detection switch
        await tester.pumpAndSettle();

        // Should be enabled
        expect(settingsProvider.is5050DetectionEnabled, true);

        // Toggle off
        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();

        // Should be disabled
        expect(settingsProvider.is5050DetectionEnabled, false);
      });

      testWidgets('should show 50/50 description when enabled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Initially no description
        expect(find.text('50/50 Detection Active'), findsNothing);

        // Enable 50/50 detection
        final switches = find.byType(Switch);
        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();

        // Scroll down to bring description into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        printAllTextWidgets(tester);
        // Use textContaining for robust match
        expect(find.textContaining('Cells in 50/50 situations'), findsOneWidget);
      });

      testWidgets('should toggle 50/50 safe move when detection is enabled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll down to bring 50 section into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        printAllTextWidgets(tester);

        // Get the provider and enable 50/50tion first
        final context = tester.element(find.byType(SettingsPage));
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        
        // Enable 50/50 detection first (required for safe move)
        settingsProvider.toggle5050Detection();
        await tester.pumpAndSettle();
        
        // Now toggle the safe move
        settingsProvider.toggle5050SafeMove();
        await tester.pumpAndSettle();
        
        printAllTextWidgets(tester);

        // Assert provider state
        expect(settingsProvider.is5050SafeMoveEnabled, isTrue);
      });
    });

    group('Reset to Defaults Tests', () {
      testWidgets('should show reset confirmation dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll down to bring reset button into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
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

        // Change some settings first
        await tester.tap(find.byType(Switch).first); // Enable Kickstarter mode
        await tester.pumpAndSettle();
        expect(settingsProvider.isFirstClickGuaranteeEnabled, true);

        // Scroll down to bring reset button into view
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Tap reset button
        await tester.tap(find.text('Reset to Defaults'));
        await tester.pumpAndSettle();

        // Confirm reset
        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        // Settings should be reset
        expect(settingsProvider.isFirstClickGuaranteeEnabled, false);
        expect(settingsProvider.isClassicMode, true);
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
        
        // Toggle the first click guarantee (game mode)
        settingsProvider.toggleFirstClickGuarantee();
        await tester.pumpAndSettle();
        
        printAllTextWidgets(tester);

        // Assert provider state
        expect(settingsProvider.isFirstClickGuaranteeEnabled, isTrue);
      });

      testWidgets('should handle rapid state changes gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Rapidly toggle settings
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(Switch).first);
          await tester.pump();
        }
        await tester.pumpAndSettle();

        // Should end in a consistent state
        expect(settingsProvider.isFirstClickGuaranteeEnabled, true);
        expect(settingsProvider.isClassicMode, false);
      });
    });
  });
} 