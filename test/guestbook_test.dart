// Widget tests for the guestbook: posting a valid entry, and rejecting one
// that's missing a name or a message.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_workshop/guestbook.dart';

void main() {
  testWidgets('posts an entry when both fields are filled in', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Guestbook()));

    await tester.enterText(find.byType(TextField).at(0), 'Ada');
    await tester.enterText(find.byType(TextField).at(1), 'Great workshop!');
    await tester.tap(find.text('Sign the guestbook'));
    await tester.pump();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Great workshop!'), findsOneWidget);
  });

  testWidgets('rejects an entry when the name or message is empty', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Guestbook()));

    // Message left blank. No entry should be added to the list below.
    await tester.enterText(find.byType(TextField).at(0), 'Ada');
    await tester.tap(find.text('Sign the guestbook'));
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);

    // Whitespace-only name should also be rejected.
    await tester.enterText(find.byType(TextField).at(0), '   ');
    await tester.enterText(find.byType(TextField).at(1), 'Hello!');
    await tester.tap(find.text('Sign the guestbook'));
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);
  });
}
