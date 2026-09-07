import 'package:aesthetic_planner/core/widgets/swipe_to_delete_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SwipeToDeleteTile reveals Sil button on swipe and calls onDelete on tap', (tester) async {
    bool deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              height: 80,
              child: SwipeToDeleteTile(
                onDelete: () {
                  deleted = true;
                },
                child: Container(
                  color: Colors.blue,
                  child: const Text('Item Content'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Item Content'), findsOneWidget);
    expect(find.text('Sil'), findsOneWidget);

    expect(deleted, false);

    // Drag left by 100 pixels to reveal the Sil button
    await tester.drag(find.text('Item Content'), const Offset(-100, 0));
    await tester.pumpAndSettle();

    // Tap the Sil button
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();

    expect(deleted, true);
  });
}
