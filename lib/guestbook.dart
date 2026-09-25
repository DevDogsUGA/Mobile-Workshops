import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

/// The guestbook, now backed by Supabase instead of an in-memory list.
class Guestbook extends StatefulWidget {
  const Guestbook({super.key});

  @override
  State<Guestbook> createState() => _GuestbookState();
}

class _GuestbookState extends State<Guestbook> {
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guestbook')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Anyone can read the guestbook below. Sign-in is coming next.'),
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
