import 'package:cardmarket_wizard/services/cardmarket/wizard/articles_repository.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_optimizer_result.freezed.dart';
part 'price_optimizer_result.g.dart';

typedef WantsPrices = Map<String, List<int>>;
typedef SellersOffers = Map<String, WantsPrices>;

@freezed
class PriceOptimizerResult with _$PriceOptimizerResult {
  const PriceOptimizerResult._();

  const factory PriceOptimizerResult({
    required int totalPrice,
    required SellersOffers sellersOffersToBuy,
    required Map<String, int> sellersShippingCost,
    @Default([]) List<String> missingWants,
  }) = _PriceOptimizerResult;

  int get price => sellersOffersToBuy.values
          .map((offers) => offers.values)
          .fold<List<List<int>>>([], (a, b) => [...a, ...b]).fold<List<int>>(
        [],
        (a, b) => [...a, ...b],
      ).sum;
  int get shippingCost => sellersShippingCost.values.sum;

  String get label =>
      '$price + $shippingCost shipping from ${sellersOffersToBuy.keys.length} sellers';

  Map<String, int> determineQuantityByArticleId() {
    final articlesRepository = ArticlesRepository.instance();

    final quantityByArticleId = <String, int>{};
    sellersOffersToBuy.forEach((sellerName, pricesByProductId) {
      pricesByProductId.forEach((productId, prices) {
        final sortedArticles = articlesRepository
            .retrieve(sellerName: sellerName, wantsProductId: productId)
            .sorted((a, b) => a.offer.priceEuroCents - b.offer.priceEuroCents);

        var remainingCount = prices.length;
        for (final article in sortedArticles) {
          if (remainingCount == 0) break;
          final toBuyCount = remainingCount.clamp(0, article.offer.quantity);
          quantityByArticleId.update(
            article.id,
            (q) => q + toBuyCount,
            ifAbsent: () => toBuyCount,
          );
          remainingCount -= toBuyCount;
        }
      });
    });

    return quantityByArticleId;
  }

  factory PriceOptimizerResult.fromJson(Map<String, Object?> json) =>
      _$PriceOptimizerResultFromJson(json);
}
