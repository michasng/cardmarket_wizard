import 'package:cardmarket_wizard/screens/launch/launch_screen.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

void main() {
  initLogging();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardmarket Wizard',
      home: const LaunchScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
