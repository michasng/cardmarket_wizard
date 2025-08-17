import 'dart:async';

import 'package:cardmarket_wizard/services/cardmarket/wizard/wizard_settings_service.dart';
import 'package:micha_core/micha_core.dart';
import 'package:puppeteer/puppeteer.dart';

class BrowserHolder {
  static final _logger = createLogger(BrowserHolder);
  static BrowserHolder? _instance;

  Browser? _browser;

  BrowserHolder._internal();

  factory BrowserHolder.instance() {
    return _instance ??= BrowserHolder._internal();
  }

  Future<void> launch() async {
    if (_browser != null) await close();
    _browser = await puppeteer.launch(
      headless: false,
      defaultViewport: null,
      args: ['--disable-infobars', '--start-maximized'],
    );
  }

  Future<void> close() async {
    if (_browser?.isConnected ?? false) await _browser?.close();
    _browser = null;
  }

  Future<Page> get currentPage async {
    assert(_browser != null, 'Browser must be running.');
    return (await _browser!.pages).first;
  }

  Future<T> retriedInBrowser<T>(FutureOr<T> Function() operation) {
    return retried(
      shouldRetry: (exception) =>
          !exception.toString().contains('Session closed'),
      strategy: (_) => const Duration(milliseconds: 200),
      operation,
    );
  }

  Future<void> goTo(String url) async {
    final settings = WizardSettingsService.instance();
    final page = await currentPage;

    await settings.rateLimiter.execute(
      () => retriedInBrowser(() async {
        _logger.info('Navigating to $url');
        try {
          await page.goto(
            url,
            timeout: const Duration(seconds: 10),
            wait: Until.domContentLoaded,
          );
        } on TimeoutException {
          // A DOMContentLoaded event was not received in time,
          // but it might have fired before the event listener was created.
          final readyState = await page.evaluate<String>(
            '() => document.readyState',
          );
          if (readyState == 'loading') rethrow;
          // readyState must be 'interactive' or most likely 'complete'
          _logger.fine(
            'Navigation timed out, but the document is already $readyState.',
          );
        }
      }),
    );
  }
}
