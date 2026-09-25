// Widget test for the signed-out guestbook: it's read-only, with a sign-in
// prompt, and it lists whatever Supabase returns, newest first.
//
// We give Supabase a fake HTTP client instead of a real project, so this
// test never touches the network.

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
    // Answer every request with one canned message instead of a real
    // Supabase project.
    final fakeClient = MockClient((request) async {
      return http.Response(
        '[{"id": "1", "user_id": "u1", "author_name": "Ada", '
        '"body": "Great workshop!", "created_at": "2026-09-28T12:00:00Z"}]',
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });

    await Supabase.initialize(
      url: 'https://fake-project.supabase.co',
      publishableKey: 'fake-publishable-key',
      httpClient: fakeClient,
      // There's no `shared_preferences` platform channel in a widget test,
      // so keep session storage in memory instead of on a real device.
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _InMemoryAsyncStorage(),
      ),
    );
  });

  testWidgets('signed out: shows a sign-in prompt and lists messages', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Guestbook()));
    await tester.pumpAndSettle();

    expect(find.text('Sign in with DevDogs'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Great workshop!'), findsOneWidget);
  });
}
