import 'package:html/dom.dart';
import 'package:micha_core/micha_core.dart';
import 'package:puppeteer/puppeteer.dart';

typedef IsAtCallback = bool Function(Uri uri);

abstract class CardmarketPage {
  static final _logger = createLogger(CardmarketPage);
  static const baseUrl = 'https://www.cardmarket.com';
  static const basePathSegments = ['en', 'YuGiOh'];

  static IsAtCallback createIsAt(String pathPattern) {
    const baseUrlPattern = r'^https:\/\/www\.cardmarket\.com\/\w+\/\w+';
    const pathEndPattern = r'[^/]*$';
    final regExp = RegExp(baseUrlPattern + pathPattern + pathEndPattern);
    return (Uri uri) => regExp.matchAsPrefix(uri.toString()) != null;
  }

  final Page page;
  final IsAtCallback isAt;

  CardmarketPage({
    required this.page,
    required this.isAt,
  });

  /// Wait for any navigation to finsh without blocking (unlike page.waitForNavigation).
  Future<void> _waitForBrowserIdle() async {
    while (true) {
      try {
        await page.waitForSelector('html');
        return;
      } catch (e) {
        // potential for a race-condition, throwing "Node with given id does not belong to the document"
        _logger.warning(e);
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  Future<bool> at() async {
    await _waitForBrowserIdle();
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
