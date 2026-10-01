import 'package:flutter/material.dart';

/// One guestbook entry: who left it, what it says, and when.
class GuestbookEntry {
  GuestbookEntry({required this.name, required this.message, required this.time});

  final String name;
  final String message;
  final DateTime time;
}

/// The guestbook we didn't get to during Setup Night: visitors leave their
/// name and a message. Everything lives in memory, so it resets whenever the
/// app restarts, and there's no way to delete an entry once it's posted.
class Guestbook extends StatefulWidget {
  const Guestbook({super.key});

  @override
  State<Guestbook> createState() => _GuestbookState();
}

class _GuestbookState extends State<Guestbook> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  // Newest entries are added to the front of the list, so the list itself is
  // always in "newest first" order.
  final List<GuestbookEntry> _entries = [];

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();

    // Reject the entry if either field is empty once whitespace is trimmed.
    if (name.isEmpty || message.isEmpty) {
      return;
    }

    setState(() {
      _entries.insert(
        0,
        GuestbookEntry(name: name, message: message, time: DateTime.now()),
      );
      _nameController.clear();
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guestbook')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _submit, child: const Text('Sign the guestbook')),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return ListTile(
                    title: Text(entry.name),
                    subtitle: Text(entry.message),
                    trailing: Text(_formatTime(entry.time)),
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

/// Formats a time as HH:MM, zero-padded, for display next to an entry.
String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
