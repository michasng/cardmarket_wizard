import 'package:cardmarket_wizard/components/map_range.dart';
import 'package:cardmarket_wizard/models/card/card.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/orchestrator/orchestrator_config.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';
import 'package:cardmarket_wizard/models/single/single.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:cardmarket_wizard/services/price_optimizer.dart';
import 'package:cardmarket_wizard/services/wizard_settings.dart';
import 'package:collection/collection.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:micha_core/micha_core.dart';

class WizardOrchestrator {
  static final _logger = createLogger(WizardOrchestrator);
  static WizardOrchestrator? _instance;

  WizardOrchestrator._internal();

  factory WizardOrchestrator.instance() {
    return _instance ??= WizardOrchestrator._internal();
  }

  WantsPrices _mergeWantsPrices(WantsPrices? a, WantsPrices? b) {
    if (a == null) {
      if (b == null) return {};
      return b;
    }
    if (b == null) return a;

    return {
      for (final want in [...a.keys, ...b.keys])
        want: [
          if (a.containsKey(want)) ...a[want]!,
          if (b.containsKey(want)) ...b[want]!,
        ]..sort(),
    };
  }

  SellersOffers _mergeSellersOffers(SellersOffers a, SellersOffers b) {
    return {
      for (final sellerName in [...a.keys, ...b.keys])
        sellerName: _mergeWantsPrices(a[sellerName], b[sellerName]),
    };
  }

  Future<Card> _findCard(WantsArticle want) async {
    final page = await CardPage.goTo(
      want.id,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    return await page.parse();
  }

  Future<Single> _findSingle(WantsArticle want) async {
    final page = await SinglePage.goTo(
      want.id,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    return await page.parse();
  }

  Future<Product> _findWantProduct(
    WantsArticle want,
  ) async {
    return switch (want.wantType) {
      WantType.card => await _findCard(want),
      WantType.single => await _findSingle(want),
    };
  }

  SellersOffers _extractOffers(
    WantsArticle want,
    Iterable<ArticleWithSeller> articles,
  ) {
    final SellersOffers sellersOffers = {};
    for (final article in articles) {
      final sellerOffers =
          sellersOffers.getOrPut(article.seller.name, () => {});
      final offers = sellerOffers.getOrPut(want.id, () => []);
      offers.addAll(
        List.filled(
          article.offer.quantity,
          article.offer.priceEuroCents,
        ),
      );
    }
    return sellersOffers;
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

  Future<SellersOffers> _sellersLookup({
    required Wants wants,
    required Iterable<String> sellerNames,
  }) async {
    final browserHolder = BrowserHolder.instance();
    SellersOffers sellersOffers = {};
    for (final (index, sellerName) in sellerNames.indexed) {
      _logger.fine('${index + 1}/${sellerNames.length}');
      List<SellerSinglesArticle> sellerArticles = [];
      var sellerSinglesPage = await SellerSinglesPage.goTo(
        sellerName,
        wantsId: wants.id,
      );
      while (true) {
        final sellerSingles = await sellerSinglesPage.parse();
        sellerArticles.addAll(sellerSingles.articles);
        final url = sellerSingles.pagination.nextPageUrl;
        if (url == null) break;
        await browserHolder.goTo(url);
        sellerSinglesPage = await SellerSinglesPage.fromCurrentPage();
      }
      final WantsPrices sellerOffers = {};
      final singlesWantsArticles = wants.articles
          .where((article) => article.wantType == WantType.single);
      for (final sellerArticle in sellerArticles) {
        final exactIdMatch = singlesWantsArticles
            .where((article) => article.id == sellerArticle.id)
            .firstOrNull;
        final fuzzyNameMatch = extractOne(
          query: sellerArticle.name,
          choices: wants.articles,
          getter: (wantsArticle) => wantsArticle.name,
        );
        sellerOffers
            .putIfAbsent((exactIdMatch ?? fuzzyNameMatch.choice).id, () => [])
            .add(sellerArticle.offer.priceEuroCents);
      }
      sellersOffers[sellerName] = sellerOffers;
    }
    return sellersOffers;
  }

  static const Range<int> _normRange = (lower: 0, upper: 1);

  List<double> _calculateSellerScores(ArticleSeller seller) {
    return [
      if (seller.etaDays != null)
        seller.etaDays!.mapRange(
          from: (lower: 7, upper: 2),
          to: _normRange,
        ),
      seller.etaLocationDays.mapRange(
        from: (lower: 7, upper: 2),
        to: _normRange,
      ),
      seller.itemCount.mapRange(
        from: (lower: 0, upper: 10000),
        to: _normRange,
      ),
    ];
  }

  Future<PriceOptimizerResult> run(OrchestratorConfig config) async {
    _logger.info(
      'Running shopping wizard for ${config.wants.articles.length} wants.',
    );
    final shippingCostsService = ShippingCostsService.instance();
    final settings = WizardSettings.instance();
    _logger.info('Getting local shipping methods.');
    final localShippingMethods = await shippingCostsService.findShippingMethods(
      fromCountry: settings.location,
      toCountry: settings.location,
    );

    final shoppingWizard = PriceOptimizer.instance();
    final browserHolder = BrowserHolder.instance();
    final initialUrl = (await browserHolder.currentPage).url;

    SellersOffers sellersOffers = {};
    final Map<String, Location> locationBySeller = {};
    final Map<String, List<double>> sellersScores = {};
    for (final (index, want) in config.wants.articles.indexed) {
      _logger.fine('${index + 1}/${config.wants.articles.length}');
      final product = await _findWantProduct(want);
      final approvedArticles = product.articles.where(
        (article) =>
            (article.seller.etaDays ?? config.assumedNewSellerEtaDays) <=
                config.maxEtaDays &&
            (article.seller.rating ?? config.assumedNewSellerRating) >
                config.minSellerRating,
      );
      final prices =
          approvedArticles.map((article) => article.offer.priceEuroCents);
      final minPrice = prices.min;
      final maxPrice = prices.max;

      // simplification: the cheapest offer may not be sent with local shipping
      final localShippingCost = shippingCostsService.estimateShippingCost(
        cardCount: 1,
        valueEuroCents: minPrice,
        shippingMethods: localShippingMethods,
      );
      final articlesWorthShipping = approvedArticles.where(
        (article) =>
            article.offer.priceEuroCents <= minPrice + localShippingCost,
      );

      for (final article in articlesWorthShipping) {
        locationBySeller[article.seller.name] = article.seller.location;

        if (!sellersScores.containsKey(article.seller.name)) {
          sellersScores[article.seller.name] =
              _calculateSellerScores(article.seller);
        }
        final score = minPrice == maxPrice
            ? 1.0
            : article.offer.priceEuroCents.mapRange(
                from: (lower: minPrice, upper: maxPrice),
                to: _normRange,
              );
        sellersScores[article.seller.name]!.add(score);
      }

      final wantSellerOffers = _extractOffers(want, articlesWorthShipping);
      sellersOffers = _mergeSellersOffers(sellersOffers, wantSellerOffers);
    }

    final locations = locationBySeller.values.toSet();
    _logger.info(
      'Getting shipping methods to ${locations.length - 1} other countries.',
    );
    final shippingMethodsByLocation = {
      for (final location in locations)
        location: location == settings.location
            ? localShippingMethods
            : await shippingCostsService.findShippingMethods(
                fromCountry: location,
                toCountry: settings.location,
              ),
    };

    int calculateShippingCost({
      required int value,
      required int wantCount,
      required String sellerName,
    }) {
      final location = locationBySeller[sellerName];
      final shippingMethods = shippingMethodsByLocation[location];
      return shippingCostsService.estimateShippingCost(
        cardCount: wantCount,
        valueEuroCents: value,
        shippingMethods: shippingMethods!,
      );
    }

    if (config.maxSellersToLookup > 0) {
      final preliminaryResult = shoppingWizard.findBestOffers(
        wants: _prepareWants(config.wants.articles),
        sellersOffers: sellersOffers,
        calculateShippingCost: calculateShippingCost,
      );
      _logger.info(
        'Preliminary result: ${preliminaryResult.price} + ${preliminaryResult.shippingCost} shipping from ${preliminaryResult.sellersOffersToBuy.keys.length} sellers.',
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

      final completeSellersOffers = await _sellersLookup(
        wants: config.wants,
        sellerNames: sellerNamesToLookup,
      );
      for (final MapEntry(key: sellerName, value: completeSellerOffers)
          in completeSellersOffers.entries) {
        // just override the old value, which was likely incomplete
        sellersOffers[sellerName] = completeSellerOffers;
      }
    }

    if (initialUrl != null) await browserHolder.goTo(initialUrl);

    final result = shoppingWizard.findBestOffers(
      wants: _prepareWants(config.wants.articles),
      sellersOffers: sellersOffers,
      calculateShippingCost: calculateShippingCost,
    );
    _logger.info(
      'Result: ${result.price} + ${result.shippingCost} shipping from ${result.sellersOffersToBuy.keys.length} sellers.',
    );
    return result;
  }
}
