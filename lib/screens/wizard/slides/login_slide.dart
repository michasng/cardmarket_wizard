import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/home_page.dart';
import 'package:flutter/material.dart';

class LoginSlide extends StatefulWidget {
  final void Function(String username) onSuccess;
  final VoidCallback onError;

  const LoginSlide({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<LoginSlide> createState() => _LoginSlideState();
}

class _LoginSlideState extends State<LoginSlide> {
  static final logger = createLogger(LoginSlide);

  @override
  void initState() {
    super.initState();
    _waitForLogin();
  }

  Future<void> _waitForLogin() async {
    try {
      final page = await HomePage.fromCurrentPage();
      logger.info('Navigating to cardmarket.');
      await page.to();

      logger.info('Waiting for user to login.');
      final username = await page.waitForUsername();

      logger.info('Logged in successfully as $username.');
      widget.onSuccess(username);
    } on Exception catch (e) {
      logger.severe(e);
      widget.onError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Login to cardmarket using the browser window.'),
        SizedBox(height: 16),
        Text('Keep the browser open.'),
      ],
    );
  }
}
