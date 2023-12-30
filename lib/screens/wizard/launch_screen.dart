import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/login_screen.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:flutter/material.dart';

class LaunchScreen extends StatelessWidget {
  static final logger = createLogger(LaunchScreen);

  const LaunchScreen({super.key});

  Future<void> _launch(BuildContext context) async {
    final navigator = Navigator.of(context);
    logger.info('Launching browser');

    final holder = BrowserHolder.instance();
    await holder.launch();

    navigator.go(const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Let\'s begin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _launch(context),
              child: const Text('Launch browser to start.'),
            ),
          ],
        ),
      ),
    );
  }
}
