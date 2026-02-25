import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sahaayak/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SahaayakApp());

    // Verify that the splash screen text is present.
    expect(find.text('SAHAAYAK'), findsOneWidget);
    expect(find.text('Voice AI for Bharat'), findsOneWidget);
  });
}
