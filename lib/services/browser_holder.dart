import 'package:cardmarket_wizard/components/retry.dart';
import 'package:cardmarket_wizard/services/wizard_settings.dart';
import 'package:puppeteer/puppeteer.dart';

class BrowserHolder {
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

  Future<Response> goTo(String url) async {
    final settings = WizardSettings.instance();
    final page = await currentPage;

    return await settings.rateLimiter.execute(
      () => withRetry(
        () => page.goto(url),
        maxAttemptCount: 5,
        initialDelay: const Duration(seconds: 2),
        maxDelay: const Duration(seconds: 60),
      ),
    );
  }
}
