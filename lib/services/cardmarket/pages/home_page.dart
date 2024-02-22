import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';

class HomePage extends CardmarketPage {
  HomePage._({required super.page})
      : super(
          pathPattern: r'',
        );

  Future<String> waitForUsername() async {
    final usernameElement = await page.waitForSelector(
      '#account-dropdown .d-lg-block',
      timeout: Duration.zero,
    );
    return await usernameElement!.propertyValue('innerText');
  }

  static Future<HomePage> goTo() async {
    final url = _createUrl();
    final browserHolder = BrowserHolder.instance();
    await browserHolder.goTo(url.toString());
    final page = await browserHolder.currentPage;
    final instance = HomePage._(page: page);
    await instance.waitForBrowserIdle();
    return instance;
  }

  static Uri _createUrl() {
    final url = Uri.parse(CardmarketPage.baseUrl).replace(
      pathSegments: CardmarketPage.basePathSegments,
    );
    return url;
  }

  static Future<HomePage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    final instance = HomePage._(page: await holder.currentPage);
    await instance.waitForBrowserIdle();
    return instance;
  }
}
