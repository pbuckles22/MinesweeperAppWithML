import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_minesweeper/presentation/pages/game_page.dart';
import 'package:flutter_minesweeper/presentation/providers/game_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Zoom controls change board scale', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const MaterialApp(home: GamePage()),
      ),
    );

    // Wait for the board to load
    await tester.pumpAndSettle();

    // Find the zoom in and zoom out buttons
    final zoomInButton = find.byIcon(Icons.zoom_in);
    final zoomOutButton = find.byIcon(Icons.zoom_out);
    expect(zoomInButton, findsOneWidget);
    expect(zoomOutButton, findsOneWidget);

    // Find the Transform.scale widget
    Transform scaleWidget = tester.widget(find.byType(Transform).first);
    double initialScale = (scaleWidget.transform as Matrix4).storage[0];

    // Tap zoom in
    await tester.tap(zoomInButton);
    await tester.pumpAndSettle();
    scaleWidget = tester.widget(find.byType(Transform).first);
    double zoomedInScale = (scaleWidget.transform as Matrix4).storage[0];
    expect(zoomedInScale, greaterThan(initialScale));

    // Tap zoom out
    await tester.tap(zoomOutButton);
    await tester.pumpAndSettle();
    scaleWidget = tester.widget(find.byType(Transform).first);
    double zoomedOutScale = (scaleWidget.transform as Matrix4).storage[0];
    expect(zoomedOutScale, lessThanOrEqualTo(zoomedInScale));
  });
} 