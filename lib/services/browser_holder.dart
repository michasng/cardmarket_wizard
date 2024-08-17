import 'dart:async';

import 'package:cardmarket_wizard/components/retry.dart';
import 'package:cardmarket_wizard/services/wizard_settings.dart';
import 'package:micha_core/micha_core.dart';
import 'package:puppeteer/puppeteer.dart';

class BrowserHolder {
  static final _logger = createLogger(BrowserHolder);

  static BrowserHolder? _instance;

  BrowserHolder._internal();

  factory BrowserHolder.instance() {
    return _instance ??= BrowserHolder._internal();
  }

  Browser? _browser;

  Future<void> launch() async {
    if (_browser != null) await close();
    _browser = await puppeteer.launch(
      headless: false,
      defaultViewport: null,
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

  Future<void> goTo(String url) async {
    final settings = WizardSettings.instance();
    final page = await currentPage;

    await settings.rateLimiter.execute(
      () => withRetry(
        () async {
          _logger.info('Navigating to $url');
          try {
            await page.goto(url); // default: wait until "load" is fired
          } on TimeoutException catch (_) {
            // issue: There are cases when the "DOMContentLoaded" and "load" events are missed.
            // In those cases, the readyState must be == "interactive" or "complete" respectively.
            final readyState = await page.evaluate('document.readyState');
            _logger.fine('Navigation timed out. Ready state "$readyState".');
            if (readyState != 'complete') rethrow;
          }
        },
        maxAttemptCount: 5,
        initialDelay: const Duration(seconds: 2),
        maxDelay: const Duration(seconds: 60),
      ),
    );
  }
}
