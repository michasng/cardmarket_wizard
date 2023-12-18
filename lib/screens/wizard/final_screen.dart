import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:flutter/material.dart';

class FinalScreen extends StatelessWidget {
  const FinalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('That\'s all for now.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.go(const LaunchScreen());
              },
              child: const Text('restart'),
            ),
          ],
        ),
      ),
    );
  }
}
