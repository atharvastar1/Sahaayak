import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sahaayak/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SahaayakApp());

    // Verify that the splash screen text is present.
    expect(find.text('SAHAAYAK AI'), findsOneWidget);
    expect(find.text('VOICE • TRUST • BHARAT'), findsOneWidget);

    // Allow the splash screen timer to finish and navigate to the next screen
    // We use a 5 second pump to ensure the 4 second timer completes.
    // Avoid pumpAndSettle because subsequent screens may have infinite animations.
    await tester.pump(const Duration(seconds: 5));
  });
}
