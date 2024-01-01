import 'package:html/dom.dart';
import 'package:puppeteer/puppeteer.dart';

abstract class CardmarketPage {
  static const baseUrl = 'https://www.cardmarket.com';
  final Page page;
  final RegExp pathPattern;

  CardmarketPage({
    required this.page,
    required this.pathPattern,
  });

  Future<bool> at() async {
    // await unfinished navigation, non-blocking (unlike page.waitForNavigation)
    await page.waitForSelector('html');
    return uri == null ? false : pathPattern.hasMatch(uri!.path);
  }

  RegExpMatch get pathMatch => pathPattern.firstMatch(page.url!)!;

  Uri? get uri => page.url == null ? null : Uri.tryParse(page.url!);
  String get language => uri!.pathSegments[0];
  String get game => uri!.pathSegments[1];

  Future<Element> parseDocument() async {
    final body = await page.$('body');
    final String rawHtml = await body.propertyValue('outerHTML');
    return Element.html(rawHtml);
  }
}
