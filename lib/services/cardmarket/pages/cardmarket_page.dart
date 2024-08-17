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
    while (true) {
      try {
        await page.waitForSelector('html'); // navigation finished
        final challengeElement = await page.$OrNull('#challenge-running');
        if (challengeElement != null) {
          _logger.info('Cloudflare protection detected.');
          // wait for cardmarket logo in the header
          await page.waitForSelector('#brand-gamesDD');
          _logger.info('Challenge solved.');
          _logger.info('Taking a break to avoid Cloudflare protection.');
          await Future.delayed(const Duration(minutes: 1));
        }
        return;
      } catch (e, stackTrace) {
        if (e.toString().contains('Session closed')) {
          rethrow;
        }
        // potential for a race-condition when throwing "Node with given id does not belong to the document"
        _logger.warning(
          'Race condition detected. Will retry.',
          e,
          stackTrace,
        );
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
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
    return Element.html(rawHtml);
  }
}
