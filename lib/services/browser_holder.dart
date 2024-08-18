import 'dart:async';

import 'package:cardmarket_wizard/services/wizard_settings.dart';
import 'package:micha_core/micha_core.dart';
import 'package:puppeteer/protocol/network.dart';
import 'package:puppeteer/puppeteer.dart';

class BrowserHolder {
  static final _logger = createLogger(BrowserHolder);

  static BrowserHolder? _instance;

  BrowserHolder._internal();

  factory BrowserHolder.instance() {
    return _instance ??= BrowserHolder._internal();
  }

  Browser? _browser;
  MonotonicTime? _domContentLoadedEventTime;

  Future<void> launch() async {
    if (_browser != null) await close();
    _browser = await puppeteer.launch(
      headless: false,
      defaultViewport: null,
    );
    final page = await currentPage;
    page.defaultNavigationTimeout = const Duration(seconds: 3);
    page.onDomContentLoaded
        .listen(((time) => _domContentLoadedEventTime = time));
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
    final settings = WizardSettings.instance();
    final page = await currentPage;

    await settings.rateLimiter.execute(
      () => retriedInBrowser(
        () async {
          _logger.info('Navigating to $url');
          // Issue: page.goto(url) sometimes fails to wait for "load" or "DOMContentLoaded" events.
          // Workaround: Navigate in JavaScript and manually wait for events.
          final previousEventTime = _domContentLoadedEventTime;
          await page.evaluate<String>('window.location.href = "$url";');
          await waitFor(
            () => _domContentLoadedEventTime != previousEventTime,
            timeout: const Duration(seconds: 10),
          );
        },
      ),
    );
  }
}
