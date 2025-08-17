import 'package:cardmarket_wizard/services/cardmarket/wizard/cardmarket_token_holder.dart';
import 'package:html/dom.dart';
import 'package:micha_core/micha_core.dart';
import 'package:puppeteer/puppeteer.dart';

typedef IsAtCallback = bool Function(Uri uri);

abstract class CardmarketPage {
  static final _logger = createLogger(CardmarketPage);
  static const baseUrl = 'https://www.cardmarket.com';
  static const basePathSegments = ['en', 'YuGiOh'];

  final Page page;
  final String _pathPattern;

  CardmarketPage({required this.page, required String pathPattern})
    : _pathPattern = pathPattern;

  RegExp get uriPattern {
    const baseUrlPattern = r'^https:\/\/www\.cardmarket\.com\/\w+\/\w+';
    const pathEndPattern = r'[^/]*$';
    return RegExp(baseUrlPattern + _pathPattern + pathEndPattern);
  }

  bool isAt(Uri uri) {
    return uriPattern.matchAsPrefix(uri.toString()) != null;
  }

  Future<bool> at() async {
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
    final input = dom.querySelector(
      'form input[name="${CardmarketTokenHolder.tokenName}"]',
    );
    if (input == null) {
      _logger.finest("This page doesn't contain a form with token.");
      return;
    }

    final tokenHolder = CardmarketTokenHolder.instance();
    tokenHolder.token = input.attributes['value'];
  }
}
