import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/screens/wizard/wizard_screen.dart';
import 'package:flutter/material.dart';

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
      home: SlideScreen(),
    );
  }
}
