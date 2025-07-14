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

    // Find the Container that holds the board (with calculated dimensions)
    final containers = find.byType(Container);
    expect(containers, findsWidgets);
    
    // Find the Container that has both width and height set (the board container)
    Container? boardContainer;
    for (final container in containers.evaluate()) {
      final widget = container.widget as Container;
      final constraints = widget.constraints;
      if (constraints != null && 
          constraints.maxWidth.isFinite && constraints.maxHeight.isFinite &&
          constraints.maxWidth > 100 && constraints.maxHeight > 100) {
        boardContainer = widget;
        break;
      }
    }
    
    expect(boardContainer, isNotNull);
    double initialWidth = boardContainer!.constraints!.maxWidth;
    double initialHeight = boardContainer.constraints!.maxHeight;

    // Tap zoom in
    await tester.tap(zoomInButton);
    await tester.pumpAndSettle();
    
    // Find the updated Container
    Container? zoomedInContainer;
    for (final container in containers.evaluate()) {
      final widget = container.widget as Container;
      final constraints = widget.constraints;
      if (constraints != null && 
          constraints.maxWidth.isFinite && constraints.maxHeight.isFinite &&
          constraints.maxWidth > 100 && constraints.maxHeight > 100) {
        zoomedInContainer = widget;
        break;
      }
    }
    
    expect(zoomedInContainer, isNotNull);
    double zoomedInWidth = zoomedInContainer!.constraints!.maxWidth;
    double zoomedInHeight = zoomedInContainer.constraints!.maxHeight;
    expect(zoomedInWidth, greaterThan(initialWidth));
    expect(zoomedInHeight, greaterThan(initialHeight));

    // Tap zoom out
    await tester.tap(zoomOutButton);
    await tester.pumpAndSettle();
    
    // Find the updated Container again
    Container? zoomedOutContainer;
    for (final container in containers.evaluate()) {
      final widget = container.widget as Container;
      final constraints = widget.constraints;
      if (constraints != null && 
          constraints.maxWidth.isFinite && constraints.maxHeight.isFinite &&
          constraints.maxWidth > 100 && constraints.maxHeight > 100) {
        zoomedOutContainer = widget;
        break;
      }
    }
    
    expect(zoomedOutContainer, isNotNull);
    double zoomedOutWidth = zoomedOutContainer!.constraints!.maxWidth;
    double zoomedOutHeight = zoomedOutContainer.constraints!.maxHeight;
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