import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/cardmarket_token_holder.dart';
import 'package:html/dom.dart';
import 'package:meta/meta.dart';
import 'package:micha_core/micha_core.dart';
import 'package:puppeteer/puppeteer.dart';

typedef IsAtCallback = bool Function(Uri uri);

abstract class CardmarketPage {
  static final _logger = createLogger(CardmarketPage);
  static const baseUrl = 'https://www.cardmarket.com';
  static const basePathSegments = ['en', 'YuGiOh'];

  final Page page;
  final String _pathPattern;

  CardmarketPage({
    required this.page,
    required String pathPattern,
  }) : _pathPattern = pathPattern;

  RegExp get uriPattern {
    const baseUrlPattern = r'^https:\/\/www\.cardmarket\.com\/\w+\/\w+';
    const pathEndPattern = r'[^/]*$';
    return RegExp(baseUrlPattern + _pathPattern + pathEndPattern);
  }

  bool isAt(Uri uri) {
    return uriPattern.matchAsPrefix(uri.toString()) != null;
  }

  /// Wait for any navigation to finish without blocking (unlike page.waitForNavigation).
  /// Also wait for any captcha or cloudflare protection to be bypassed by user intervention or time.
  @protected
  Future<void> waitForBrowserIdle() async {
    // potential for a race-condition when throwing "Node with given id does not belong to the document"
    BrowserHolder.instance().retriedInBrowser(() async {
      await page.waitForSelector('html'); // navigation finished
      final challengeElement = await page.$OrNull('#challenge-running');
      if (challengeElement != null) {
        _logger.info('Cloudflare protection detected.');
        // wait for cardmarket logo in the header
        await page.waitForSelector('#brand-gamesDD');
        _logger.info('Challenge solved.');
        _logger.info('Taking a break to avoid Cloudflare protection.');
        await Future<void>.delayed(const Duration(minutes: 1));
      }
    });
  }

  Future<bool> at() async {
    await waitForBrowserIdle();
    return uri == null ? false : isAt(uri!);
  }

  Uri? get uri => page.url == null ? null : Uri.tryParse(page.url!);
  String get language => uri!.pathSegments[0];
  String get game => uri!.pathSegments[1];

  Future<Element> parseDocument() async {
    final body = await page.$('body');
    final String rawHtml = await body.propertyValue('outerHTML');
    final dom = Element.html(rawHtml);
    _updateCardmarketToken(dom); // side-effect
    return dom;
  }

  void _updateCardmarketToken(Element dom) async {
    final input = dom
        .querySelector('form input[name="${CardmarketTokenHolder.tokenName}"]');
    if (input == null) {
      _logger.finest("This page doesn't contain a form with token.");
      return;
    }

    final tokenHolder = CardmarketTokenHolder.instance();
    tokenHolder.token = input.attributes['value'];
  }
}
