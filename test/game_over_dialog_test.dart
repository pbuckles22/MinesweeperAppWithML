import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/presentation/widgets/game_over_dialog.dart';
import 'package:flutter_minesweeper/services/timer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameOverDialog', () {
    testWidgets('displays win dialog with correct content', (WidgetTester tester) async {
      bool newGameCalled = false;
      bool closeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GameOverDialog(
            isWin: true,
            gameDuration: const Duration(minutes: 2, seconds: 15),
            onNewGame: () => newGameCalled = true,
            onClose: () => closeCalled = true,
          ),
        ),
      );

      // Check title and icon
      expect(find.text('Congratulations!'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsNWidgets(2)); // One in title, one in stats
      expect(find.text('You successfully cleared all mines!'), findsOneWidget);
      expect(find.text('Great job! Try a harder difficulty next time.'), findsOneWidget);
      expect(find.text('Game Statistics'), findsOneWidget);
      expect(find.text('Time: 02:15'), findsOneWidget);
      expect(find.text('Result: Victory!'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget);

      // Tap New Game
      await tester.tap(find.text('New Game'));
      await tester.pump();
      expect(newGameCalled, isTrue);

      // Tap Close
      await tester.tap(find.text('Close'));
      await tester.pump();
      expect(closeCalled, isTrue);
    });

    testWidgets('displays loss dialog with correct content', (WidgetTester tester) async {
      bool newGameCalled = false;
      bool closeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GameOverDialog(
            isWin: false,
            gameDuration: const Duration(minutes: 0, seconds: 45),
            onNewGame: () => newGameCalled = true,
            onClose: () => closeCalled = true,
          ),
        ),
      );

      // Check title and icon
      expect(find.text('Game Over'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsNWidgets(2)); // One in title, one in stats
      expect(find.text('You stepped on a mine!'), findsOneWidget);
      expect(find.text("Don't give up! Try again to improve your skills."), findsOneWidget);
      expect(find.text('Game Statistics'), findsOneWidget);
      expect(find.text('Time: 00:45'), findsOneWidget);
      expect(find.text('Result: Defeat'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget);

      // Tap New Game
      await tester.tap(find.text('New Game'));
      await tester.pump();
      expect(newGameCalled, isTrue);

      // Tap Close
      await tester.tap(find.text('Close'));
      await tester.pump();
      expect(closeCalled, isTrue);
    });
  });
} 