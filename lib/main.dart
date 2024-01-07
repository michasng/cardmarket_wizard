import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
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
    return const MaterialApp(
      title: 'Cardmarket Wizard',
      home: LaunchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
