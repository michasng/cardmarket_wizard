import 'package:html/dom.dart';
import 'package:puppeteer/puppeteer.dart';

typedef IsAtCallback = bool Function(Uri uri);

abstract class CardmarketPage {
  static const baseUrl = 'https://www.cardmarket.com';

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

  Future<bool> at() async {
    // await unfinished navigation, non-blocking (unlike page.waitForNavigation)
    await page.waitForSelector('html');
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
