import 'package:puppeteer/puppeteer.dart';

abstract class CardmarketPage {
  final Page page;
  final RegExp pathPattern;

  CardmarketPage({
    required this.page,
    required this.pathPattern,
  });

  bool at() => uri == null ? false : pathPattern.hasMatch(uri!.path);

  RegExpMatch get pathMatch => pathPattern.firstMatch(page.url!)!;

  Uri? get uri => page.url == null ? null : Uri.tryParse(page.url!);
  String get language => uri!.pathSegments[0];
  String get game => uri!.pathSegments[1];
}
