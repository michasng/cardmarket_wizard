import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_product_visited_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_result_event.dart';
import 'package:cardmarket_wizard/models/wizard/events/wizard_seller_visited_event.dart';
import 'package:cardmarket_wizard/models/wizard/wizard_config.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/wants_page.dart';
import 'package:cardmarket_wizard/services/cardmarket/shipping_costs_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/product_lookup_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/seller_lookup_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/sellers_offers_extractor_service.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/wizard_settings_service.dart';
import 'package:cardmarket_wizard/services/price_optimizer.dart';
import 'package:micha_core/micha_core.dart';

class WizardService {
  static final _logger = createLogger(WizardService);
  static WizardService? _instance;

  WizardService._internal();

  factory WizardService.instance() {
    return _instance ??= WizardService._internal();
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

  Stream<WizardEvent> runIntialSearch(WizardConfig config) async* {
    _logger.info(
      'Running shopping wizard for ${config.wants.articles.length} wants.',
    );

    final productLookupService = ProductLookupService.instance();
    final articlesByProductId = <String, List<ArticleWithSeller>>{};
    for (final (index, wantsArticle) in config.wants.articles.indexed) {
      _logger.fine('${index + 1}/${config.wants.articles.length}');
      final product = await productLookupService.findProduct(wantsArticle);
      articlesByProductId[wantsArticle.id] = product.articles;
      yield WizardProductVisitedEvent(
        wantsArticle: wantsArticle,
        product: product,
      );
    }

    final locationBySellerName = {
      for (final articles in articlesByProductId.values)
        for (final article in articles)
          article.seller.name: article.seller.location,
    };

    final sellersOffersExtractor = SellersOffersExtractorService.instance();
    var sellersOffers =
        sellersOffersExtractor.extractSellersOffers(articlesByProductId);

    final preliminaryResult = await _findBestOffers(
      wantsArticles: config.wants.articles,
      sellersOffers: sellersOffers,
      locationBySellerName: locationBySellerName,
    );
    _logger.info('Preliminary result: ${preliminaryResult.label}.');
    yield WizardResultEvent(priceOptimizerResult: preliminaryResult);
  }

  Stream<WizardEvent> runToOptimize(
    WizardConfig config, {
    required Set<String> sellerNamesToLookup,
  }) async* {
    _logger.info('Lookup of ${sellerNamesToLookup.length} sellers.');
    _logger.fine('Sellers to lookup: $sellerNamesToLookup.');

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
      yield WizardSellerVisitedEvent(sellerOffers: sellerOffers);
    }

    await WantsPage.goTo(config.wants.id);

    final result = await _findBestOffers(
      wantsArticles: config.wants.articles,
      sellersOffers: sellersOffers,
      locationBySellerName: locationBySellerName,
    );
    _logger.info('Result: ${result.label}.');

    yield WizardResultEvent(priceOptimizerResult: result);
  }

  Future<PriceOptimizerResult> _findBestOffers({
    required List<WantsArticle> wantsArticles,
    required SellersOffers sellersOffers,
    required Map<String, Location> locationBySellerName,
  }) async {
    final settings = WizardSettingsService.instance();
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
}
