import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/articles_repository.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/models/flat_article.dart';

class ProductLookupService {
  static ProductLookupService? _instance;

  const ProductLookupService._internal();

  factory ProductLookupService.instance() {
    return _instance ??= ProductLookupService._internal();
  }

  Future<Product> findProduct(
    WantsArticle wantsArticle,
  ) async {
    return switch (wantsArticle.wantType) {
      WantType.card => await _findCard(wantsArticle),
      WantType.single => await _findSingle(wantsArticle),
    };
  }

  Future<Card> _findCard(WantsArticle wantsArticle) async {
    final page = await CardPage.goTo(
      wantsArticle.productId,
      languages: wantsArticle.languages?.toList(),
      minCondition: wantsArticle.minCondition,
    );
    final card = await page.parse();

    final articlesRepository = ArticlesRepository.instance();
    for (final article in card.articles) {
      articlesRepository.store(
        sellerName: article.seller.name,
        wantsProductId: wantsArticle.productId,
        article: FlatArticle.fromCard(card, article),
      );
    }

    return card;
  }

  Future<Single> _findSingle(WantsArticle wantsArticle) async {
    final page = await SinglePage.goTo(
      wantsArticle.productId,
      languages: wantsArticle.languages?.toList(),
      minCondition: wantsArticle.minCondition,
    );
    final single = await page.parse();

    final articlesRepository = ArticlesRepository.instance();
    for (final article in single.articles) {
      articlesRepository.store(
        sellerName: article.seller.name,
        wantsProductId: wantsArticle.productId,
        article: FlatArticle.fromSingle(single, article),
      );
    }

    return single;
  }
}
