import 'package:cardmarket_wizard/models/card/card_article.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/single/single_article.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/services/browser_holder.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
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

  Future<List<CardArticle>> _findCardArticles(WantsArticle want) async {
    final url = CardPage.createUrl(
      want.id,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    final page = await CardPage.fromCurrentPage();
    await page.page.goto(url.toString());
    final card = await page.parse();
    return card.articles;
  }

  Future<List<SingleArticle>> _findSingleArticles(WantsArticle want) async {
    final url = SinglePage.createUrl(
      want.id,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    final page = await SinglePage.fromCurrentPage();
    await page.page.goto(url.toString());
    final single = await page.parse();
    return single.articles;
  }

  Future<List<ArticleWithSeller>> _findWantArticles(
    WantsArticle want,
  ) async {
    return switch (want.wantType) {
      WantType.card => await _findCardArticles(want),
      WantType.single => await _findSingleArticles(want),
    };
  }

  SellersOffers<WantsArticle> _extractOffers(
      WantsArticle want, List<ArticleWithSeller> articles) {
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

  Future<WizardResult<WantsArticle>> run({
    required Wants wants,
    required Location toCountry,
  }) async {
    _logger.info('Running shopping wizard for ${wants.articles.length} wants.');
    final shoppingWizard = ShoppingWizard.instance();
    final shippingCostsService = ShippingCostsService.instance();
    final page = await BrowserHolder.instance().currentPage;
    final initialUrl = page.url;

    SellersOffers<WantsArticle> sellersOffers = {};
    final Map<String, Location> locationBySeller = {};
    for (final want in wants.articles) {
      final articles = await _findWantArticles(want);
      locationBySeller.addEntries(
        articles.map(
          (article) => MapEntry(article.seller.name, article.seller.location),
        ),
      );

      final wantSellerOffers = _extractOffers(want, articles);
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

    if (initialUrl != null) await page.goto(initialUrl);

    final result = shoppingWizard.findBestOffers(
      wants: wants.articles,
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
