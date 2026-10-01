import 'package:flutter/material.dart';

import 'package:flutter_workshop/homepage.dart';

/// Wraps HomePage and Guestbook in a bottom NavigationBar so you can switch
/// between the two screens.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _selectedIndex = 0;

  static const _pages = [HomePage(), Center(child: Text('Guestbook'))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Guestbook'),
        ],
      ),
    );
  }
}
