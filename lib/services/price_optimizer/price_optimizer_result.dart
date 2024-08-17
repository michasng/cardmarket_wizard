import 'package:collection/collection.dart';

typedef WantsPrices = Map<String, List<int>>;
typedef SellersOffers = Map<String, WantsPrices>;
const _deepEq = DeepCollectionEquality();

class PriceOptimizerResult {
  final int totalPrice;
  final SellersOffers sellersOffersToBuy;
  final Map<String, int> sellersShippingCost;
  final List<String> missingWants;

  int get price => sellersOffersToBuy.values
      .map((offers) => offers.values)
      .fold<List<List<int>>>([], (a, b) => [...a, ...b]).fold<List<int>>(
          [], (a, b) => [...a, ...b]).sum;
  int get shippingCost => sellersShippingCost.values.sum;

  const PriceOptimizerResult({
    required this.totalPrice,
    required this.sellersOffersToBuy,
    required this.sellersShippingCost,
    this.missingWants = const [],
  });

  @override
  bool operator ==(Object other) =>
      other is PriceOptimizerResult &&
      other.runtimeType == runtimeType &&
      other.totalPrice == totalPrice &&
      _deepEq.equals(other.sellersOffersToBuy, sellersOffersToBuy) &&
      _deepEq.equals(other.sellersShippingCost, sellersShippingCost) &&
      _deepEq.equals(other.missingWants, missingWants);

  @override
  int get hashCode => Object.hashAll([
        totalPrice,
        sellersOffersToBuy,
        sellersShippingCost,
        missingWants,
      ]);

  @override
  String toString() {
    return {
      'totalPrice': totalPrice,
      'sellersOffersToBuy': sellersOffersToBuy,
      'sellersShippingCost': sellersShippingCost,
      'missingWants': missingWants,
    }.toString();
  }
}
