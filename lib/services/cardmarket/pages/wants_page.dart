import 'dart:async';

import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:puppeteer/puppeteer.dart';

class WantsPage extends CardmarketPage {
  WantsPage({required super.page})
      : super(pathPattern: RegExp(r'^\/\w+\/\w+\/Wants\/(?<wantsId>\w+)$'));

  Future<dynamic> get title async {
    final titleElement = await page.$('.page-title-container h1');
    return await titleElement.propertyValue('innerText');
  }

  Future<List<ElementHandle>> get wantedRows async {
    return page.$$('#WantsListTable table tbody tr');
  }

  static Future<WantsPage> fromCurrentPage() async {
    final holder = BrowserHolder.instance();
    return WantsPage(page: await holder.currentPage);
  }
}
