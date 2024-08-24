import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/orchestrator/orchestrator_config.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:cardmarket_wizard/services/wizard_settings.dart';

class ArticlesFilterService {
  static ArticlesFilterService? _instance;

  ArticlesFilterService._internal();

  factory ArticlesFilterService.instance() {
    return _instance ??= ArticlesFilterService._internal();
  }

  Future<Map<String, List<ArticleWithSeller>>> filterArticles({
    required OrchestratorConfig config,
    required Map<String, List<ArticleWithSeller>> articlesById,
  }) async {
    final shippingCostsService = ShippingCostsService.instance();
    final settings = WizardSettings.instance();

    final filteredArticlesById = <String, List<ArticleWithSeller>>{};
    for (final MapEntry(key: id, value: articles) in articlesById.entries) {
      final approvedArticles = articles.where(
        (article) =>
            (article.seller.etaDays ?? config.assumedNewSellerEtaDays) <=
                config.maxEtaDays &&
            (article.seller.rating ?? config.assumedNewSellerRating) >
                config.minSellerRating,
      );
      // articles are already sorted by price (without shipping)
      final minPriceArticle = approvedArticles.first;
      final minPrice = minPriceArticle.offer.priceEuroCents;

      final shippingCostToBestOffer = shippingCostsService.estimateShippingCost(
        cardCount: 1,
        valueEuroCents: minPrice,
        shippingMethods: await shippingCostsService.findShippingMethods(
          fromCountry: minPriceArticle.seller.location,
          toCountry: settings.location,
        ),
      );

      final articlesWorthShipping = approvedArticles.where(
        (article) =>
            article.offer.priceEuroCents <= minPrice + shippingCostToBestOffer,
      );
      filteredArticlesById[id] = articlesWorthShipping.toList();
    }
    return filteredArticlesById;
  }
}
