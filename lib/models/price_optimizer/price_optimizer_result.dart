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

  factory PriceOptimizerResult.fromJson(Map<String, Object?> json) =>
      _$PriceOptimizerResultFromJson(json);
}
