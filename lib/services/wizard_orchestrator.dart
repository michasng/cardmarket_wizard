import 'package:cardmarket_wizard/components/get_or_put.dart';
import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/models/enums/want_type.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/card_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/single_page.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';

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

  Future<SellersOffers<WantsArticle>> _findCardOffers(WantsArticle want) async {
    final SellersOffers<WantsArticle> sellersOffers = {};
    final url = CardPage.createUrl(
      want.id,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    final page = await CardPage.fromCurrentPage();
    await page.page.goto(url.toString());
    final card = await page.parse();
    for (final article in card.articles) {
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

  Future<SellersOffers<WantsArticle>> _findSingleOffers(
      WantsArticle want) async {
    final SellersOffers<WantsArticle> sellersOffers = {};
    final url = SinglePage.createUrl(
      want.id,
      languages: want.languages?.toList(),
      minCondition: want.minCondition,
    );
    final page = await SinglePage.fromCurrentPage();
    await page.page.goto(url.toString());
    final single = await page.parse();
    for (final article in single.articles) {
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

  Future<SellersOffers<WantsArticle>> _findWantOffers(
      List<WantsArticle> wants) async {
    SellersOffers<WantsArticle> sellersOffers = {};

    for (final want in wants) {
      switch (want.wantType) {
        case WantType.card:
          final cardSellersOffers = await _findCardOffers(want);
          sellersOffers = _mergeSellersOffers(sellersOffers, cardSellersOffers);
        case WantType.single:
          final cardSellersOffers = await _findSingleOffers(want);
          sellersOffers = _mergeSellersOffers(sellersOffers, cardSellersOffers);
      }
    }

    return sellersOffers;
  }

  Future<WizardResult<WantsArticle>> run(Wants wants) async {
    final shoppingWizard = ShoppingWizard.instance();
    _logger.info('Running shopping wizard for ${wants.articles.length} wants.');

    final sellersOffers = await _findWantOffers(wants.articles);

    final result = shoppingWizard.findBestOffers(
        wants: wants.articles, sellersOffers: sellersOffers);

    return result;
  }
}
