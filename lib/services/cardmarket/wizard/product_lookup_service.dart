import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/articles_repository.dart';

class ProductLookupService {
  static ProductLookupService? _instance;

  const ProductLookupService._internal();

  factory ProductLookupService.instance() {
    return _instance ??= ProductLookupService._internal();
  }

  Future<Product> findProduct(
    WantsArticle wantsArticle,
  ) async {
    final product = switch (wantsArticle.wantType) {
      WantType.card => await _findCard(wantsArticle),
      WantType.single => await _findSingle(wantsArticle),
    };

    final articlesRepository = ArticlesRepository.instance();
    for (final article in product.articles) {
      articlesRepository.store(
        sellerName: article.seller.name,
        wantsProductId: wantsArticle.productId,
        article: article,
      );
    }

    return product;
  }

  Future<Card> _findCard(WantsArticle want) async {
    final page = await CardPage.goTo(
      want.productId,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    return await page.parse();
  }

  Future<Single> _findSingle(WantsArticle want) async {
    final page = await SinglePage.goTo(
      want.productId,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    return await page.parse();
  }
}
