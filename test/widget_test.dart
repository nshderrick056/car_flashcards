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
}
