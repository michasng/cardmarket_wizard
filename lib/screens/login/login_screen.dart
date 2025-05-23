import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/debug/debug_screen.dart';
import 'package:cardmarket_wizard/screens/launch/launch_screen.dart';
import 'package:cardmarket_wizard/screens/select_wants/select_wants_screen.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

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
      _logger.info('Navigating to cardmarket.');
      final page = await HomePage.goTo();
      await _disableOptionalCookies();

      _logger.info('Waiting for user to login.');
      final username = await page.waitForUsername();

      _logger.info('Logged in successfully as $username.');
      navigator.go(
        SelectWantsScreen(
          username: username,
        ),
      );
    } on Exception catch (exception, stackTrace) {
      _logger.severe(exception, stackTrace);
      navigator.go(const LaunchScreen());
    }
  }

  Future<void> _disableOptionalCookies() async {
    final holder = BrowserHolder.instance();
    final page = await holder.currentPage;

    final cookieSettingsLink =
        await page.$OrNull("[data-modal='/en/YuGiOh/Modal/CookiesSettings']");
    if (cookieSettingsLink == null) {
      _logger.warning('Cookie banner not found.');
      return;
    }
    await cookieSettingsLink.click();

    try {
      final savePreferencesButton = await page
          .waitForSelector("[type='submit'][form='SavePreferencesForm']");
      await savePreferencesButton?.click();
    } catch (e) {
      _logger.warning('Failed to submit form to decline optional cookies.', e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              'Login',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text('Login to cardmarket using the browser window.'),
            const Text('Keep the browser open.'),
          ],
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: () {
          final navigator = Navigator.of(context);
          navigator.go(const DebugScreen());
        },
        child: const Text('debugging options'),
      ),
    );
  }
}
