import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_workshop/shell.dart';

Future<void> main() async {
  // Supabase needs plugins (e.g. for secure storage) registered before it
  // can initialize.
  WidgetsFlutterBinding.ensureInitialized();

  // Both values are supplied at build/run time with
  // `--dart-define-from-file=.env.local` -- see the README. Neither is a
  // secret: the publishable key is safe to ship in a client app.
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevDogs Workshop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Shell(),
    );
  }
}
