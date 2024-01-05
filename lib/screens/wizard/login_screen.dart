import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/screens/wizard/select_wants_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/home_page.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _logger = createLogger(LoginScreen);

  @override
  void initState() {
    super.initState();
    _waitForLogin();
  }

  Future<void> _waitForLogin() async {
    final navigator = Navigator.of(context);

    try {
      final page = await HomePage.fromCurrentPage();
      _logger.info('Navigating to cardmarket.');
      await page.to();

      _logger.info('Waiting for user to login.');
      final username = await page.waitForUsername();

      _logger.info('Logged in successfully as $username.');
      navigator.go(SelectWantsScreen(
        username: username,
      ));
    } on Exception catch (e) {
      _logger.severe(e);
      navigator.go(const LaunchScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Login',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Login to cardmarket using the browser window.'),
            const SizedBox(height: 16),
            const Text('Keep the browser open.'),
          ],
        ),
      ),
    );
  }
}
