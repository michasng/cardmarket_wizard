import 'dart:convert';

import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/cardmarket_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/cardmarket_token_holder.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:micha_core/micha_core.dart';

class ShoppingCartService {
  static ShoppingCartService? _instance;
  static final _logger = createLogger(ShoppingCartService);

  const ShoppingCartService._internal();

  factory ShoppingCartService.instance() {
    return _instance ??= ShoppingCartService._internal();
  }

  Future<void> addToShoppingCart(Map<String, int> quantityByArticleId) async {
    _logger.info(
      'Adding ${quantityByArticleId.length} different articles (total ${quantityByArticleId.values.sum}) to the shopping cart...',
    );

    final browserHolder = BrowserHolder.instance();
    final page = await browserHolder.currentPage;
    final cookies = await page.cookies(urls: [CardmarketPage.baseUrl]);
    final sessionCookie = cookies
        .where((cookie) => cookie.name == 'PHPSESSID')
        .firstOrNull;

    if (sessionCookie == null) {
      throw Exception('No cardmarket session cookie was found.');
    }

    final tokenHolder = CardmarketTokenHolder.instance();
    final token = tokenHolder.token;

    if (token == null) {
      throw Exception('No cardmarket token was found.');
    }

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(CardmarketPage.baseUrl).replace(
              pathSegments: [
                ...CardmarketPage.basePathSegments,
                'AjaxAction',
                'ShoppingCart_Add_AddArticlesFromProductPage',
              ],
            ),
          )
          ..headers['Content-Type'] = 'multipart/form-data'
          ..headers['Cookie'] = '${sessionCookie.name}=${sessionCookie.value}'
          ..fields[CardmarketTokenHolder.tokenName] = token
          ..fields['idArticle'] = jsonEncode({
            for (final articleId in quantityByArticleId.keys)
              articleId: articleId,
          })
          ..fields['amount'] = jsonEncode(quantityByArticleId);

    final response = await request.send();
    final responseBodyXml = await response.stream.bytesToString();

    final resultsCodePattern = RegExp(
      r'<resultsCode>(?<resultsCode>.*?)<\/resultsCode>',
    );
    final resultsCodeBase64 = resultsCodePattern
        .firstMatch(responseBodyXml)
        ?.namedGroup('resultsCode');
    if (resultsCodeBase64 == null) {
      _logger.warning('Full response body: $responseBodyXml');
      throw Exception('No <resultsCode> tag found in XML response.');
    }

    final resultsCode = utf8.decode(base64.decode(resultsCodeBase64));
    if (resultsCode != 'generalOK') {
      _logger.warning('Full response body: $responseBodyXml');
      throw Exception(
        "The decoded <resultsCode> tag doesn't indicate success. Got: $resultsCode.",
      );
    }

    _logger.info('Articles were added to the shopping cart.');
  }
}
