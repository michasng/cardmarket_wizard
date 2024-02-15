import 'package:cardmarket_wizard/components/map_range.dart';
import 'package:cardmarket_wizard/models/card/card.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/interfaces/product.dart';
import 'package:cardmarket_wizard/models/seller_singles/seller_singles_article.dart';
import 'package:cardmarket_wizard/models/single/single.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
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

  WantsPrices<TWant> _mergeWantsPrices<TWant>(
      WantsPrices<TWant>? a, WantsPrices<TWant>? b) {
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

  SellersOffers<TWant> _mergeSellersOffers<TWant>(
      SellersOffers<TWant> a, SellersOffers<TWant> b) {
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

  SellersOffers<WantsArticle> _extractOffers(
    WantsArticle want,
    Iterable<ArticleWithSeller> articles,
  ) {
    final SellersOffers<WantsArticle> sellersOffers = {};
    for (final article in articles) {
      final sellerOffers =
          sellersOffers.getOrPut(article.seller.name, () => {});
      final offers = sellerOffers.getOrPut(want, () => []);
      offers.addAll(List.filled(
        article.offer.quantity,
        article.offer.priceEuroCents,
      ));
    }
    return sellersOffers;
  }

  List<WantsArticle> _multiplyByAmount(List<WantsArticle> articles) {
    return [
      for (final article in articles)
        ...List.filled(
          article.amount,
          article,
        ),
    ];
  }

  Future<SellersOffers<WantsArticle>> _sellersLookup({
    required Wants wants,
    required Iterable<String> sellerNames,
  }) async {
    SellersOffers<WantsArticle> sellersOffers = {};
    for (final sellerName in sellerNames) {
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
        await sellerSinglesPage.page.goto(url);
        sellerSinglesPage = await SellerSinglesPage.fromCurrentPage();
      }
      final WantsPrices<WantsArticle> sellerOffers = {};
      for (final sellerArticle in sellerArticles) {
        final wantsArticleMatch = extractOne(
          query: sellerArticle.name,
          choices: wants.articles,
          getter: (wantsArticle) => wantsArticle.name,
        );
        sellerOffers
            .putIfAbsent(wantsArticleMatch.choice, () => [])
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
      )
    ];
  }

  Future<WizardResult<WantsArticle>> run({
    required Wants wants,
    required Location toCountry,
    int maxEtaDays = 6,
    SellerRating minSellerRating = SellerRating.good,
    bool includeNewSellers = true,
    int maxSellersToLookup = 10,
  }) async {
    final assumedNewSellerEtaDays =
        includeNewSellers ? maxEtaDays : maxEtaDays + 1;
    final assumedNewSellerRating =
        includeNewSellers ? minSellerRating : SellerRating.bad;

    _logger.info('Running shopping wizard for ${wants.articles.length} wants.');
    final shoppingWizard = ShoppingWizard.instance();
    final shippingCostsService = ShippingCostsService.instance();
    final page = await BrowserHolder.instance().currentPage;
    final initialUrl = page.url;

    SellersOffers<WantsArticle> sellersOffers = {};
    final Map<String, Location> locationBySeller = {};
    final Map<String, List<double>> sellersScores = {};
    for (final want in wants.articles) {
      final product = await _findWantProduct(want);
      final approvedArticles = product.articles.where((article) =>
          (article.seller.etaDays ?? assumedNewSellerEtaDays) <= maxEtaDays &&
          (article.seller.rating ?? assumedNewSellerRating) > minSellerRating);
      final prices =
          approvedArticles.map((article) => article.offer.priceEuroCents);
      final minPrice = prices.min;
      final maxPrice = prices.max;

      for (final article in approvedArticles) {
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

      final wantSellerOffers = _extractOffers(want, approvedArticles);
      sellersOffers = _mergeSellersOffers(sellersOffers, wantSellerOffers);
    }

    final locations = locationBySeller.values.toSet();
    _logger.info('Getting shipping methods to ${locations.length} countries.');
    final shippingMethodsByLocation = {
      for (final location in locations)
        location: await shippingCostsService.findShippingMethods(
          fromCountry: location,
          toCountry: toCountry,
        ),
    };

    if (maxSellersToLookup > 0) {
      _logger.finest('Sellers\' scores: $sellersScores');

      final sellerNamesToLookup = sellersScores
          .map((sellerName, scores) => MapEntry(sellerName, scores.average))
          .entries
          .sorted((a, b) => b.value.compareTo(a.value))
          .take(maxSellersToLookup)
          .map((entry) => entry.key)
          .toSet();

      _logger.info('Lookup of ${sellerNamesToLookup.length} sellers.');
      _logger.fine('Sellers to lookup: $sellerNamesToLookup.');

      final completeSellersOffers = await _sellersLookup(
        wants: wants,
        sellerNames: sellerNamesToLookup,
      );
      for (final MapEntry(key: sellerName, value: completeSellerOffers)
          in completeSellersOffers.entries) {
        // just override the old value, which was likely incomplete
        sellersOffers[sellerName] = completeSellerOffers;
      }
    }

    if (initialUrl != null) await page.goto(initialUrl);

    final result = shoppingWizard.findBestOffers(
      wants: _multiplyByAmount(wants.articles),
      sellersOffers: sellersOffers,
      calculateShippingCost: ({
        required value,
        required wantCount,
        required sellerName,
      }) {
        final location = locationBySeller[sellerName];
        final shippingMethods = shippingMethodsByLocation[location];
        return shippingCostsService.estimateShippingCost(
          cardCount: wantCount,
          valueEuroCents: value,
          shippingMethods: shippingMethods!,
        );
      },
    );

    return result;
  }
}
