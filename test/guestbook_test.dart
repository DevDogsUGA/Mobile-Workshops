// Widget test for the signed-out guestbook: it should be read-only, with a
// sign-in prompt and no way to post.
//
// We give Supabase a fake HTTP client instead of a real project, so this
// test never touches the network. Signed-in flows (posting, deleting) need
// a real session and are exercised by hand during the workshop instead.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_workshop/guestbook.dart';

/// Keeps gotrue's PKCE bookkeeping in memory instead of on a real device --
/// there's no `shared_preferences` platform channel available in a widget
/// test.
class _InMemoryAsyncStorage extends GotrueAsyncStorage {
  final _values = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _values.remove(key);
  }
}

void main() {
  setUpAll(() async {
    // Every request the guestbook makes while signed out is a GET for the
    // message list -- answer it with one message instead of a real
    // Supabase project. The embedded `profiles` comes back as a single
    // object (never a list) because messages.user_id -> profiles.id is
    // many-to-one -- this is what regresses if the widget ever goes back to
    // treating it as a list.
    final fakeClient = MockClient((request) async {
      return http.Response(
        '[{'
        '"id": "11111111-1111-1111-1111-111111111111",'
        '"user_id": "22222222-2222-2222-2222-222222222222",'
        '"body": "Hello, guestbook!",'
        '"created_at": "2024-01-01T12:00:00.000Z",'
        '"profiles": {"name": "User B"}'
        '}]',
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });

    await Supabase.initialize(
      url: 'https://fake-project.supabase.co',
      publishableKey: 'fake-publishable-key',
      httpClient: fakeClient,
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _InMemoryAsyncStorage(),
      ),
    );
  });

  testWidgets('signed out: read-only, with a sign-in prompt', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Guestbook()));
    await tester.pumpAndSettle();

    expect(find.text('Sign in with DevDogs'), findsOneWidget);
    expect(find.text('Sign the guestbook'), findsNothing);
    expect(find.byType(TextField), findsNothing);

    // The embedded profile's name renders correctly even though it's a
    // single object, not a list.
    expect(find.text('User B'), findsOneWidget);
  });
}
