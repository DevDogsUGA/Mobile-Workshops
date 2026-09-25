import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

/// Where the OAuth provider should send the browser (web) or the app
/// (mobile) back to once sign-in finishes. The scheme below is already
/// registered in the Android/iOS deep-link setup from `01-flutter-intro`.
String get _redirectTo =>
    kIsWeb ? Uri.base.origin : 'org.devdogsuga.mobileworkshops://login-callback';

/// The guestbook, now backed by Supabase instead of an in-memory list.
class Guestbook extends StatefulWidget {
  const Guestbook({super.key});

  @override
  State<Guestbook> createState() => _GuestbookState();
}

class _GuestbookState extends State<Guestbook> {
  Session? _session;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();

    // Keep track of whether anyone is signed in, and react to sign-in/out.
    _session = _supabase.auth.currentSession;
    _supabase.auth.onAuthStateChange.listen((data) {
      setState(() => _session = data.session);
    });

    _loadMessages();
  }

  // Load the guestbook, newest first.
  Future<void> _loadMessages() async {
    try {
      final rows = await _supabase
          .from('messages')
          .select('id, user_id, author_name, body, created_at')
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() => _messages = List<Map<String, dynamic>>.from(rows));
      }
    } catch (error) {
      // The workshop's dev server might not be running yet -- don't crash
      // the whole screen over it.
      debugPrint('Could not load the guestbook: $error');
    }
  }

  Future<void> _signIn() {
    return _supabase.auth.signInWithOAuth(
      OAuthProvider('custom:devdogsuga'),
      redirectTo: _redirectTo,
    );
  }

  Future<void> _signOut() => _supabase.auth.signOut();

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return Scaffold(
      appBar: AppBar(title: const Text('Guestbook')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: session == null
                  ? ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Sign in with DevDogs'),
                    )
                  : OutlinedButton(
                      onPressed: _signOut,
                      child: const Text('Sign out'),
                    ),
            ),
            const SizedBox(height: 8),
            const Text('Anyone can read the guestbook below. Posting is coming next.'),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ListTile(
                    title: Text(message['author_name'] as String),
                    subtitle: Text(message['body'] as String),
                    trailing: Text(_formatTime(message['created_at'] as String)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats an ISO timestamp as HH:MM, zero-padded, for display next to a
/// message.
String _formatTime(String isoTimestamp) {
  final time = DateTime.parse(isoTimestamp).toLocal();
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
