import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_product_visited_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_result_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_seller_prioritized_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/events/orchestrator_seller_visited_event.dart';
import 'package:cardmarket_wizard/models/orchestrator/orchestrator_config.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
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

  Stream<OrchestratorEvent> runIntialSearch(OrchestratorConfig config) async* {
    _logger.info(
      'Running shopping wizard for ${config.wants.articles.length} wants.',
    );

    final productLookupService = ProductLookupService.instance();
    final articlesByProductId = <String, List<ArticleWithSeller>>{};
    for (final (index, wantsArticle) in config.wants.articles.indexed) {
      _logger.fine('${index + 1}/${config.wants.articles.length}');
      final product = await productLookupService.findProduct(wantsArticle);
      articlesByProductId[wantsArticle.id] = product.articles;
      yield OrchestratorProductVisitedEvent(
        wantsArticle: wantsArticle,
        product: product,
      );
    }

    final locationBySellerName = {
      for (final articles in articlesByProductId.values)
        for (final article in articles)
          article.seller.name: article.seller.location,
    };

    final sellersOffersExtractor = SellersOffersExtractor.instance();
    var sellersOffers =
        sellersOffersExtractor.extractSellersOffers(articlesByProductId);

    final preliminaryResult = await _findBestOffers(
      wantsArticles: config.wants.articles,
      sellersOffers: sellersOffers,
      locationBySellerName: locationBySellerName,
    );
    _logger.info('Preliminary result: ${preliminaryResult.label}.');
    yield OrchestratorResultEvent(
      priceOptimizerResult: preliminaryResult,
      isPreliminary: true,
    );
  }

  Stream<OrchestratorEvent> runToOptimize(
    OrchestratorConfig config, {
    required Map<String, List<ArticleWithSeller>> articlesByProductId,
    required List<String> sellersToInclude,
  }) async* {
    final articlesFilterService = ArticlesFilterService.instance();
    final filteredArticlesByProductId =
        await articlesFilterService.filterArticles(
      config: config,
      articlesById: articlesByProductId,
    );

    final sellerScoreService = SellerScoreService.instance();
    final sellersScores = sellerScoreService.determineSellerScores(
      articlesByProductId: filteredArticlesByProductId,
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
            // sellers to include at the front, so they are most likely to be looked up.
            ...sellersToInclude,
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
    final SellersOffers sellersOffers = {};
    final Map<String, Location> locationBySellerName = {};
    final sellerLookupService = SellerLookupService.instance();
    for (final (index, sellerName) in sellerNamesToLookup.indexed) {
      _logger.fine('${index + 1}/${sellerNamesToLookup.length}');
      final (location, sellerOffers) = await sellerLookupService.lookupSeller(
        wants: config.wants,
        sellerName: sellerName,
      );
      sellersOffers[sellerName] = sellerOffers;
      locationBySellerName[sellerName] = location;
      yield OrchestratorSellerVisitedEvent(sellerOffers: sellerOffers);
    }

    await WantsPage.goTo(config.wants.id);

    final result = await _findBestOffers(
      wantsArticles: config.wants.articles,
      sellersOffers: sellersOffers,
      locationBySellerName: locationBySellerName,
    );
    _logger.info('Result: ${result.label}.');

    yield OrchestratorResultEvent(
      priceOptimizerResult: result,
      isPreliminary: false,
    );
  }

  Future<PriceOptimizerResult> _findBestOffers({
    required List<WantsArticle> wantsArticles,
    required SellersOffers sellersOffers,
    required Map<String, Location> locationBySellerName,
  }) async {
    final settings = WizardSettings.instance();
    final shippingCostsService = ShippingCostsService.instance();
    final priceOptimizer = PriceOptimizer.instance();

    final shippingMethodsByLocation = {
      for (final location in locationBySellerName.values.toSet())
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

    return priceOptimizer.findBestOffers(
      wants: _prepareWants(wantsArticles),
      sellersOffers: sellersOffers,
      calculateShippingCost: calculateShippingCost,
    );
  }

  Stream<OrchestratorEvent> run(OrchestratorConfig config) async* {
    final articlesByProductId = <String, List<ArticleWithSeller>>{};
    PriceOptimizerResult? preliminaryResult;

    final initialSearch = runIntialSearch(config);
    await for (final event in initialSearch) {
      switch (event) {
        case OrchestratorProductVisitedEvent():
          articlesByProductId[event.wantsArticle.id] = event.product.articles;
        case OrchestratorResultEvent():
          preliminaryResult = event.priceOptimizerResult;
      }
      yield event;
    }

    final optimizedSearch = runToOptimize(
      config,
      articlesByProductId: articlesByProductId,
      sellersToInclude: preliminaryResult!.sellersOffersToBuy.keys.toList(),
    );
    await for (final event in optimizedSearch) {
      yield event;
    }
  }
}
