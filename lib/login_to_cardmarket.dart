import 'package:cardmarket_wizard/logging.dart';
import 'package:flutter/material.dart';
import 'package:puppeteer/puppeteer.dart';

enum LoginToCardmarketState { idle, waitingForLogin, success, error }

class LoginToCardmarket extends StatefulWidget {
  const LoginToCardmarket({super.key});

  @override
  State<LoginToCardmarket> createState() => _LoginToCardmarketState();
}

class _LoginToCardmarketState extends State<LoginToCardmarket> {
  static final logger = createLogger(LoginToCardmarket);

  bool _inputBlocked = false;
  LoginToCardmarketState _state = LoginToCardmarketState.idle;
  String? _username;

  String get _stateMessage {
    switch (_state) {
      case LoginToCardmarketState.idle:
        return 'Press "Login" to open a browser window.';
      case LoginToCardmarketState.waitingForLogin:
        return 'Waiting for login in opened browser window.';
      case LoginToCardmarketState.success:
        return 'Logged in successfully as $_username.';
      case LoginToCardmarketState.error:
        return 'Browser was closed too soon. Press login to restart the process.';
    }
  }

  Future<void> _login() async {
    setState(() {
      _inputBlocked = true;
      _state = LoginToCardmarketState.waitingForLogin;
    });
    logger.fine('Starting the login process.');

    final browser = await puppeteer.launch(headless: false);
    try {
      final page = (await browser.pages).first;
      page.defaultTimeout = Duration.zero;

      await page.goto(
        'https://www.cardmarket.com/en/YuGiOh',
        wait: Until.domContentLoaded,
      );

      logger.info('Waiting for user to login.');
      final usernameElement =
          await page.waitForSelector('#account-dropdown .d-lg-block');
      final username = await usernameElement?.propertyValue('innerText');

      setState(() {
        _username = username;
        _state = LoginToCardmarketState.success;
      });
      logger.info('Logged in successfully as $username.');
    } on TargetClosedException catch (e) {
      logger.severe(e);
      setState(() => _state = LoginToCardmarketState.error);
    } finally {
      await browser.close();
      setState(() => _inputBlocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _inputBlocked ? null : _login,
          child: const Text('Login'),
        ),
        const SizedBox(height: 16),
        Text(_stateMessage),
      ],
    );
  }
}
