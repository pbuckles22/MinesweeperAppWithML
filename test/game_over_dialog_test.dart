import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/presentation/widgets/game_over_dialog.dart';
import 'package:flutter_minesweeper/services/timer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameOverDialog', () {
    testWidgets('GameOverDialog shows win content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => GameOverDialog(
              isWin: true,
              gameDuration: const Duration(seconds: 75),
              onNewGame: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Congratulations!'), findsOneWidget);
      expect(find.textContaining('Victory!'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsWidgets);
      expect(find.text('Time: 01:15'), findsOneWidget);
    });

    testWidgets('GameOverDialog shows loss content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => GameOverDialog(
              isWin: false,
              gameDuration: const Duration(seconds: 42),
              onNewGame: () {},
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Game Over'), findsOneWidget);
      expect(find.textContaining('Defeat'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsWidgets);
      expect(find.text('Time: 00:42'), findsOneWidget);
    });
  });
} 