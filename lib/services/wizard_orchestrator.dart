import 'package:cardmarket_wizard/models/card/card.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
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
    required Set<String> sellerNames,
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

  Future<WizardResult<WantsArticle>> run({
    required Wants wants,
    required Location toCountry,
    int maxEtaDays = 6,
    SellerRating minSellerRating = SellerRating.good,
    bool includeNewSellers = true,
    bool doSellerLookup = false,
    int minItemCountForSellerLookup = 2000,
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
    final Set<String> sellerNamesForLookup = {};
    for (final want in wants.articles) {
      final product = await _findWantProduct(want);
      final approvedArticles = product.articles.where((article) =>
          (article.seller.etaDays ?? assumedNewSellerEtaDays) <= maxEtaDays &&
          (article.seller.rating ?? assumedNewSellerRating) > minSellerRating);

      for (final article in approvedArticles) {
        locationBySeller[article.seller.name] = article.seller.location;

        if (article.seller.itemCount >= minItemCountForSellerLookup) {
          sellerNamesForLookup.add(article.seller.name);
        }
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

    if (doSellerLookup) {
      _logger.info('Lookup of ${sellerNamesForLookup.length} sellers.');
      final completeSellersOffers = await _sellersLookup(
        wants: wants,
        sellerNames: sellerNamesForLookup,
      );
      for (final MapEntry(key: sellerName, value: completeSellerOffers)
          in completeSellersOffers.entries) {
        // override the old value, because it was likely incomplete
        sellersOffers[sellerName] = completeSellerOffers;
      }
    }

    /*
    final sellerNamesWithMultipleOffers = sellersOffers.entries.where((entry) {
      final MapEntry(key: sellerName, value: offers) = entry;
      return offers.length > 1;
    });
    */

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
