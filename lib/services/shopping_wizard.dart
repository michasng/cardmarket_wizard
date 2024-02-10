import 'package:cardmarket_wizard/services/currency.dart';
import 'package:collection/collection.dart';
import 'package:micha_core/micha_core.dart';

const int _maxIntWeb = 0x20000000000000;
typedef Purchase<TWant> = ({String sellerName, TWant want});
typedef PurchaseHistory<TWant> = List<Purchase<TWant>>;
typedef WantsPrices<TWant> = Map<TWant, List<int>>;
typedef SellersOffers<TWant> = Map<String, WantsPrices<TWant>>;
typedef Matrix<T> = List<List<T>>;
typedef CalculateShippingCost = int Function({
  required String sellerName,
  required int wantCount,
  required int value,
});
const _deepEq = DeepCollectionEquality();

CalculateShippingCost createCalculateShippingCost(int constantCost) =>
    ({required sellerName, required wantCount, required value}) => constantCost;

class WizardResult<TWant> {
  final int totalPrice;
  final SellersOffers<TWant> sellersOffersToBuy;
  final Map<String, int> sellersShippingCost;
  final List<TWant> missingWants;

  int get price => sellersOffersToBuy.values
      .map((offers) => offers.values)
      .fold<List<List<int>>>([], (a, b) => [...a, ...b]).fold<List<int>>(
          [], (a, b) => [...a, ...b]).sum;
  int get shippingCost => sellersShippingCost.values.sum;

  const WizardResult({
    required this.totalPrice,
    required this.sellersOffersToBuy,
    required this.sellersShippingCost,
    this.missingWants = const [],
  });

  @override
  bool operator ==(Object other) =>
      other is WizardResult &&
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

class ShoppingWizard {
  static final _logger = createLogger(ShoppingWizard);
  static ShoppingWizard? _instance;

  ShoppingWizard._internal();

  factory ShoppingWizard.instance() {
    return _instance ??= ShoppingWizard._internal();
  }

  int _determineTotalPrice<TWant>(
    SellersOffers<TWant> sellersOffers,
    PurchaseHistory<TWant> purchaseHistory,
  ) {
    int totalPrice = 0;
    for (final purchase in purchaseHistory.toSet()) {
      final (:sellerName, :want) = purchase;

      final count = purchaseHistory.where((item) => item == purchase).length;
      for (int i = 0; i < count; i++) {
        final price = sellersOffers[sellerName]![want]![i];
        totalPrice += price;
      }
    }
    return totalPrice;
  }

  SellersOffers<TWant> _toSellersOffersToBuy<TWant>(
    SellersOffers<TWant> sellersOffers,
    PurchaseHistory<TWant> purchaseHistory,
  ) {
    final SellersOffers<TWant> sellersOffersToBuy = {};
    for (final purchase in purchaseHistory.toSet()) {
      final (:sellerName, :want) = purchase;
      final sellerOffersToBuy =
          sellersOffersToBuy.getOrPut(sellerName, () => {});
      final sellerWantPrices = sellerOffersToBuy.getOrPut(want, () => []);

      final count = purchaseHistory.where((item) => item == purchase).length;
      for (int i = 0; i < count; i++) {
        final price = sellersOffers[sellerName]![want]![i];
        sellerWantPrices.add(price);
      }
    }
    return sellersOffersToBuy;
  }

  /// Returns (one of) the best combinations of wants to buy from [sellersOffers]
  /// in order to buy all possible [wants].
  /// The [wants] may contain duplicates.
  /// The [sellersOffers] must be sorted ascendingly by price.
  WizardResult<TWant> findBestOffers<TWant>({
    required List<TWant> wants,
    required SellersOffers<TWant> sellersOffers,
    CalculateShippingCost? calculateShippingCost,
  }) {
    final calculateShippingCostNonNull =
        calculateShippingCost ?? createCalculateShippingCost(0);
    _logger.info(
      'Looking for best offers for ${wants.length} wants from ${sellersOffers.length} sellers.',
    );
    final List<TWant> missingWants = [];

    final Matrix<int> priceMatrix = List.generate(
      wants.length + 1, // + 1 to compare rows without checking boundaries
      (_) => List.filled(sellersOffers.length, _maxIntWeb),
    );
    priceMatrix[0][0] = 0; // initial price
    final Matrix<PurchaseHistory<TWant>> purchaseHistoryMatrix = List.generate(
      wants.length + 1, // + 1 to compare rows without checking boundaries
      (_) => List.generate(sellersOffers.length, (_) => []),
    );

    // Calculates the additional cost of including some offer by a given seller.
    int additionalSellerShippingCost(
      PurchaseHistory<TWant> purchaseHistory,
      Purchase<TWant> newPurchase,
    ) {
      final sellerPurchases = purchaseHistory
          .where(
            (purchase) => purchase.sellerName == newPurchase.sellerName,
          )
          .toList();
      final purchaseCount =
          sellerPurchases.where((item) => item == newPurchase).length;
      final offers = sellersOffers[newPurchase.sellerName]![newPurchase.want];
      if (offers == null || offers.length <= purchaseCount) {
        // seller does not offer what is wanted or not enough of what is wanted
        return _maxIntWeb;
      }
      final priceBefore = _determineTotalPrice(
        sellersOffers,
        sellerPurchases,
      );
      final priceAfter = _determineTotalPrice(
        sellersOffers,
        [...sellerPurchases, newPurchase],
      );
      final costBefore = sellerPurchases.isEmpty
          ? 0
          : calculateShippingCostNonNull(
              sellerName: newPurchase.sellerName,
              wantCount: sellerPurchases.length,
              value: priceBefore,
            );
      final costAfter = calculateShippingCostNonNull(
        sellerName: newPurchase.sellerName,
        wantCount: sellerPurchases.length + 1,
        value: priceAfter,
      );
      return costAfter - costBefore;
    }

    for (final (prevWantIndex, want) in wants.indexed) {
      final wantIndex = prevWantIndex + 1;
      bool wantFound = false;

      for (final (sellerIndex, MapEntry(key: sellerName, value: sellerOffers))
          in sellersOffers.entries.indexed) {
        final offers = sellerOffers[want];
        if (offers == null) {
          // seller does not offer what is wanted
          continue;
        }
        final purchase = (
          sellerName: sellerName,
          want: want,
        );

        // Finds the best want/seller indexes to use as a basis,
        // if the next want was bought from the current seller.
        // The "best" indexes cover as many wants as possible for minimal cost.
        int baseWantIndex = prevWantIndex;
        int baseSellerIndex;
        int shippingCost;
        while (true) {
          final wantPrices = priceMatrix[baseWantIndex];
          final histories = purchaseHistoryMatrix[baseWantIndex];

          final sellersShippingCost = [
            for (final history in histories)
              additionalSellerShippingCost(history, purchase),
          ];
          final pricesWithShipping = List.generate(
            wantPrices.length,
            (index) => wantPrices[index] + sellersShippingCost[index],
          );
          baseSellerIndex = pricesWithShipping.indexOf(pricesWithShipping.min);

          if (priceMatrix[baseWantIndex][baseSellerIndex] != _maxIntWeb) {
            shippingCost = sellersShippingCost[baseSellerIndex];
            break;
          }
          baseWantIndex -= 1;
        }

        final baseWantPrice = priceMatrix[baseWantIndex][baseSellerIndex];
        final basePurchaseHistory =
            purchaseHistoryMatrix[baseWantIndex][baseSellerIndex];

        final purchaseCount =
            basePurchaseHistory.where((item) => item == purchase).length;
        if (offers.length <= purchaseCount) {
          // seller does not offer enough of what is wanted
          continue;
        }
        final offer = offers[purchaseCount];

        final price = baseWantPrice + offer + shippingCost;

        priceMatrix[wantIndex][sellerIndex] = price;
        purchaseHistoryMatrix[wantIndex][sellerIndex] = [
          ...basePurchaseHistory,
          purchase,
        ];
        wantFound = true;
      }

      if (!wantFound) {
        missingWants.add(want);
      }
    }

    int resultWantIndex = wants.length;
    int resultSellerIndex;
    while (true) {
      final wantPrices = priceMatrix[resultWantIndex];
      resultSellerIndex = wantPrices.indexOf(wantPrices.min);
      if (priceMatrix[resultWantIndex][resultSellerIndex] != _maxIntWeb) {
        break;
      }
      resultWantIndex -= 1;
    }

    final totalPrice = priceMatrix[resultWantIndex][resultSellerIndex];
    final purchaseHistory =
        purchaseHistoryMatrix[resultWantIndex][resultSellerIndex];
    final sellersOffersToBuy = _toSellersOffersToBuy(
      sellersOffers,
      purchaseHistory,
    );
    final sellersShippingCost = {
      for (final MapEntry(key: sellerName, value: sellerOffers)
          in sellersOffersToBuy.entries)
        sellerName: calculateShippingCostNonNull(
          sellerName: sellerName,
          wantCount: sellerOffers.values
              .fold<List<int>>([], (a, b) => [...a, ...b]).length,
          value: sellerOffers.values
              .fold<List<int>>([], (a, b) => [...a, ...b]).sum,
        ),
    };

    _logger.info(
        'Best offers found (${missingWants.length} missing). Total price: ${formatPrice(totalPrice)}');
    return WizardResult(
      totalPrice: totalPrice,
      sellersOffersToBuy: sellersOffersToBuy,
      sellersShippingCost: sellersShippingCost,
      missingWants: missingWants,
    );
  }
}
