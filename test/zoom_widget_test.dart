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

    // Find the zoom in and zoom out buttons (now positioned at top-right)
    final zoomInButton = find.byIcon(Icons.zoom_in);
    final zoomOutButton = find.byIcon(Icons.zoom_out);
    expect(zoomInButton, findsOneWidget);
    expect(zoomOutButton, findsOneWidget);

    // Find all SizedBox widgets and find the one with calculated dimensions
    final sizedBoxes = find.byType(SizedBox);
    expect(sizedBoxes, findsWidgets);
    
    // Find the SizedBox that has both width and height set (the board container)
    SizedBox? boardSizedBox;
    for (final sizedBox in sizedBoxes.evaluate()) {
      final widget = sizedBox.widget as SizedBox;
      if (widget.width != null && widget.height != null && 
          widget.width! > 100 && widget.height! > 100) {
        boardSizedBox = widget;
        break;
      }
    }
    
    expect(boardSizedBox, isNotNull);
    double initialWidth = boardSizedBox!.width!;
    double initialHeight = boardSizedBox.height!;

    // Tap zoom in
    await tester.tap(zoomInButton);
    await tester.pumpAndSettle();
    
    // Find the updated SizedBox
    SizedBox? zoomedInSizedBox;
    for (final sizedBox in sizedBoxes.evaluate()) {
      final widget = sizedBox.widget as SizedBox;
      if (widget.width != null && widget.height != null && 
          widget.width! > 100 && widget.height! > 100) {
        zoomedInSizedBox = widget;
        break;
      }
    }
    
    expect(zoomedInSizedBox, isNotNull);
    double zoomedInWidth = zoomedInSizedBox!.width!;
    double zoomedInHeight = zoomedInSizedBox.height!;
    expect(zoomedInWidth, greaterThan(initialWidth));
    expect(zoomedInHeight, greaterThan(initialHeight));

    // Tap zoom out
    await tester.tap(zoomOutButton);
    await tester.pumpAndSettle();
    
    // Find the updated SizedBox again
    SizedBox? zoomedOutSizedBox;
    for (final sizedBox in sizedBoxes.evaluate()) {
      final widget = sizedBox.widget as SizedBox;
      if (widget.width != null && widget.height != null && 
          widget.width! > 100 && widget.height! > 100) {
        zoomedOutSizedBox = widget;
        break;
      }
    }
    
    expect(zoomedOutSizedBox, isNotNull);
    double zoomedOutWidth = zoomedOutSizedBox!.width!;
    double zoomedOutHeight = zoomedOutSizedBox.height!;
    expect(zoomedOutWidth, lessThanOrEqualTo(zoomedInWidth));
    expect(zoomedOutHeight, lessThanOrEqualTo(zoomedInHeight));
  });

  testWidgets('Zoom controls remain visible when zoomed in', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const MaterialApp(home: GamePage()),
      ),
    );

    // Wait for the board to load
    await tester.pumpAndSettle();

    // Find zoom controls
    final zoomInButton = find.byIcon(Icons.zoom_in);
    final zoomOutButton = find.byIcon(Icons.zoom_out);
    
    // Zoom in multiple times
    for (int i = 0; i < 5; i++) {
      await tester.tap(zoomInButton);
      await tester.pumpAndSettle();
    }

    // Verify zoom controls are still visible
    expect(find.byIcon(Icons.zoom_in), findsOneWidget);
    expect(find.byIcon(Icons.zoom_out), findsOneWidget);
  });
} 