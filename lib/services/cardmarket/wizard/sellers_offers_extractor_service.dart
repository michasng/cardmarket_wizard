import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';

class SellersOffersExtractorService {
  static SellersOffersExtractorService? _instance;

  SellersOffersExtractorService._internal();

  factory SellersOffersExtractorService.instance() {
    return _instance ??= SellersOffersExtractorService._internal();
  }

  /// Transforms wanted articles to be used in price optimization.
  ///
  /// Takes [articlesByProductId], which maps IDs of wanted products to the articles (offers) for that item.
  /// Returns a [Map] with seller names as keys and the list of their offers as value.
  /// The offers map IDs of wanted products to prices in cents.
  SellersOffers extractSellersOffers(
    Map<String, List<ArticleWithSeller>> articlesByProductId,
  ) {
    SellersOffers sellersOffers = {};
    for (final MapEntry(key: id, value: productArticles)
        in articlesByProductId.entries) {
      final wantSellerOffers = _extractOffers(id, productArticles);
      sellersOffers = _mergeSellersOffers(sellersOffers, wantSellerOffers);
    }
    return sellersOffers;
  }

  SellersOffers _extractOffers(
    String productId,
    List<ArticleWithSeller> productArticles,
  ) {
    final SellersOffers sellersOffers = {};
    for (final article in productArticles) {
      final sellerOffers =
          sellersOffers.putIfAbsent(article.seller.name, () => {});
      final offers = sellerOffers.putIfAbsent(productId, () => []);
      offers.addAll(
        List.filled(
          article.offer.quantity, // spread offers with multiple quantities
          article.offer.priceEuroCents,
        ),
      );
    }
    return sellersOffers;
  }

  SellersOffers _mergeSellersOffers(SellersOffers a, SellersOffers b) {
    return {
      for (final sellerName in [...a.keys, ...b.keys])
        sellerName: _mergeWantsPrices(a[sellerName], b[sellerName]),
    };
  }

  WantsPrices _mergeWantsPrices(WantsPrices? a, WantsPrices? b) {
    if (a == null) {
      if (b == null) return {};
      return b;
    }
    if (b == null) return a;

    return {
      for (final productId in {...a.keys, ...b.keys})
        productId: [
          if (a.containsKey(productId)) ...a[productId]!,
          if (b.containsKey(productId)) ...b[productId]!,
        ]..sort(), // sorted ascending by price
    };
  }
}
