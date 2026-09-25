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
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();

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

  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final body = _bodyController.text.trim();
    final session = _session;

    // Reject the entry if either field is empty once whitespace is trimmed.
    if (session == null || name.isEmpty || body.isEmpty) {
      return;
    }

    // The name is whatever the signed-in user typed into the field below.
    // (The next commit looks this up server-side instead.)
    await _supabase.from('messages').insert({'author_name': name, 'body': body});

    _nameController.clear();
    _bodyController.clear();
    await _loadMessages();
  }

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
            if (session != null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Sign the guestbook'),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Sign in to leave a message. Anyone can read below.'),
              ),
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
