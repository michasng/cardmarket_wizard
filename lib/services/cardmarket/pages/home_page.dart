import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:puppeteer/puppeteer.dart';

class HomePage extends CardmarketPage {
  HomePage({required super.page})
      : super(
          isAt: CardmarketPage.createIsAt(r''),
        );

  Future<void> to({
    String language = 'en',
    String game = 'YuGiOh',
  }) async {
    await page.goto(
      '${CardmarketPage.baseUrl}/$language/$game',
      wait: Until.domContentLoaded,
    );
  }

  Future<String> waitForUsername() async {
    final usernameElement = await page.waitForSelector(
      '#account-dropdown .d-lg-block',
      timeout: Duration.zero,
    );
    return await usernameElement!.propertyValue('innerText');
  }

  static Future<HomePage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    return HomePage(page: await holder.currentPage);
  }
}
