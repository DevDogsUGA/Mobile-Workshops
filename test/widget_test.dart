// A basic smoke test for the workshop template.
//
// See https://docs.flutter.dev/cookbook/testing/widget/introduction for more
// on widget testing.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_workshop/main.dart';

void main() {
  testWidgets('renders the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello, World!'), findsOneWidget);
  });
}
