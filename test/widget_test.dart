import 'package:car_flashcards/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping the card flips it and scoring works', (tester) async {
    await tester.pumpWidget(const CarFlashcardsApp());
    expect(find.text('What car is this?'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);

    await tester.tap(find.byType(FlipCard));
    await tester.pumpAndSettle();
    expect(find.text('What car is this?'), findsNothing);

    await tester.tap(find.text('Got it right'));
    await tester.pump();
    expect(find.text('Score: 1'), findsOneWidget);
    expect(find.text('Next car'), findsOneWidget);
  });

  testWidgets('next card never shows its name before being flipped', (tester) async {
    await tester.pumpWidget(const CarFlashcardsApp());
    await tester.tap(find.byType(FlipCard));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it right'));
    await tester.pump();
    await tester.tap(find.text('Next car'));

    // Check every frame of what used to be the flip-back animation.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.text('What car is this?'), findsOneWidget);
      for (final car in cars) {
        expect(find.text(car.name), findsNothing);
      }
    }
  });
}
