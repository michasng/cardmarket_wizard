import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_product_visited_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_result_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_seller_prioritized_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_seller_visited_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/orchestrator_config.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/articles_filter_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/product_lookup_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/seller_lookup_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/seller_score_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/sellers_offers_extractor.dart';
import 'package:cardmarket_wizard/services/price_optimizer.dart';
import 'package:cardmarket_wizard/services/wizard_settings.dart';
import 'package:collection/collection.dart';
import 'package:micha_core/micha_core.dart';

class WizardOrchestrator {
  static final _logger = createLogger(WizardOrchestrator);
  static WizardOrchestrator? _instance;

  WizardOrchestrator._internal();

  factory WizardOrchestrator.instance() {
    return _instance ??= WizardOrchestrator._internal();
  }

  List<String> _prepareWants(List<WantsArticle> articles) {
    return [
      for (final article in articles)
        ...List.filled(
          article.amount,
          article.id,
        ),
    ];
  }

  Stream<OrchestratorEvent> run(OrchestratorConfig config) async* {
    _logger.info(
      'Running shopping wizard for ${config.wants.articles.length} wants.',
    );
    final shippingCostsService = ShippingCostsService.instance();
    final settings = WizardSettings.instance();

    final priceOptimizer = PriceOptimizer.instance();
    final browserHolder = BrowserHolder.instance();
    final initialUrl = (await browserHolder.currentPage).url;

    final productLookupService = ProductLookupService.instance();
    final articlesById = <String, List<ArticleWithSeller>>{};
    for (final (index, wantsArticle) in config.wants.articles.indexed) {
      _logger.fine('${index + 1}/${config.wants.articles.length}');
      final product = await productLookupService.findProduct(wantsArticle);
      articlesById[wantsArticle.id] = product.articles;
      yield OrchestratorProductVisitedEvent(
        wantsArticle: wantsArticle,
        product: product,
      );
    }

    final articlesFilterService = ArticlesFilterService.instance();
    final filteredArticlesById = await articlesFilterService.filterArticles(
      config: config,
      articlesById: articlesById,
    );

    final locationBySellerName = {
      for (final articles in filteredArticlesById.values)
        for (final article in articles)
          article.seller.name: article.seller.location,
    };

    final sellersOffersExtractor = SellersOffersExtractor.instance();
    var sellersOffers =
        sellersOffersExtractor.extractSellersOffers(filteredArticlesById);

    final locations = locationBySellerName.values.toSet();
    _logger.info(
      'Getting shipping methods to ${locations.length - 1} other countries.',
    );
    final shippingMethodsByLocation = {
      for (final location in locations)
        location: await shippingCostsService.findShippingMethods(
          fromCountry: location,
          toCountry: settings.location,
        ),
    };

    int calculateShippingCost({
      required int value,
      required int wantCount,
      required String sellerName,
    }) {
      final location = locationBySellerName[sellerName];
      final shippingMethods = shippingMethodsByLocation[location];
      return shippingCostsService.estimateShippingCost(
        cardCount: wantCount,
        valueEuroCents: value,
        shippingMethods: shippingMethods!,
      );
    }

    if (config.maxSellersToLookup > 0) {
      final preliminaryResult = priceOptimizer.findBestOffers(
        wants: _prepareWants(config.wants.articles),
        sellersOffers: sellersOffers,
        calculateShippingCost: calculateShippingCost,
      );
      _logger.info(
        'Preliminary result: ${preliminaryResult.price} + ${preliminaryResult.shippingCost} shipping from ${preliminaryResult.sellersOffersToBuy.keys.length} sellers.',
      );
      yield OrchestratorResultEvent(
        priceOptimizerResult: preliminaryResult,
        isPreliminary: true,
      );

      final sellerScoreService = SellerScoreService.instance();
      final sellersScores = sellerScoreService.determineSellerScores(
        articlesByProductId: filteredArticlesById,
      );

      final sellerNamesToLookup = sellersScores
          .map((sellerName, scores) => MapEntry(sellerName, scores.average))
          .entries
          .sorted((a, b) => b.value.compareTo(a.value))
          .indexed
          .takeWhile(
            (indexedEntry) =>
                indexedEntry.$2.value >= 1 ||
                indexedEntry.$1 <= config.minSellersToLookup,
          )
          .map((indexedEntry) => indexedEntry.$2.key)
          .transform(
            (sellerNames) => {
              // Preliminary result seller names at the front,
              // so they are more likely to be looked up.
              ...preliminaryResult.sellersOffersToBuy.keys,
              ...sellerNames,
            },
          )
          .take(config.maxSellersToLookup)
          .toSet();

      _logger.info('Lookup of ${sellerNamesToLookup.length} sellers.');
      _logger.fine('Sellers to lookup: $sellerNamesToLookup.');
      yield OrchestratorSellerPrioritizedEvent(
        sellerNamesToLookup: sellerNamesToLookup,
      );

      // just override the old value,
      // because preliminary result sellers are looked up anyway
      sellersOffers = {};
      final sellerLookupService = SellerLookupService.instance();
      for (final (index, sellerName) in sellerNamesToLookup.indexed) {
        _logger.fine('${index + 1}/${sellerNamesToLookup.length}');
        final sellerOffers = await sellerLookupService.findSellerOffers(
          wants: config.wants,
          sellerName: sellerName,
        );
        sellersOffers[sellerName] = sellerOffers;
        yield OrchestratorSellerVisitedEvent(sellerOffers: sellerOffers);
      }
    }

    if (initialUrl != null) await browserHolder.goTo(initialUrl);

    final result = priceOptimizer.findBestOffers(
      wants: _prepareWants(config.wants.articles),
      sellersOffers: sellersOffers,
      calculateShippingCost: calculateShippingCost,
    );
    _logger.info(
      'Result: ${result.price} + ${result.shippingCost} shipping from ${result.sellersOffersToBuy.keys.length} sellers.',
    );

    yield OrchestratorResultEvent(
      priceOptimizerResult: result,
      isPreliminary: false,
    );
  }
}
