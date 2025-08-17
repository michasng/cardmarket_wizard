import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:collection/collection.dart';
import 'package:micha_core/micha_core.dart';

const int _maxIntWeb = 0x20000000000000;
typedef _Purchase = ({String sellerName, String wantId});
typedef _PurchaseHistory = List<_Purchase>;
typedef _Matrix<T> = List<List<T>>;
typedef CalculateShippingCost =
    int Function({
      required String sellerName,
      required int wantCount,
      required int value,
    });

CalculateShippingCost createCalculateShippingCost(int constantCost) =>
    ({required sellerName, required wantCount, required value}) => constantCost;

class PriceOptimizer {
  static final _logger = createLogger(PriceOptimizer);
  static PriceOptimizer? _instance;

  const PriceOptimizer._internal();

  factory PriceOptimizer.instance() {
    return _instance ??= PriceOptimizer._internal();
  }

  int _determineTotalPrice(
    SellersOffers sellersOffers,
    _PurchaseHistory purchaseHistory,
  ) {
    int totalPrice = 0;
    for (final purchase in purchaseHistory.toSet()) {
      final (:sellerName, :wantId) = purchase;

      final count = purchaseHistory.where((item) => item == purchase).length;
      for (int i = 0; i < count; i++) {
        final price = sellersOffers[sellerName]![wantId]![i];
        totalPrice += price;
      }
    }
    return totalPrice;
  }

  SellersOffers _toSellersOffersToBuy(
    SellersOffers sellersOffers,
    _PurchaseHistory purchaseHistory,
  ) {
    final SellersOffers sellersOffersToBuy = {};
    for (final purchase in purchaseHistory.toSet()) {
      final (:sellerName, :wantId) = purchase;
      final sellerOffersToBuy = sellersOffersToBuy.putIfAbsent(
        sellerName,
        () => {},
      );
      final sellerWantPrices = sellerOffersToBuy.putIfAbsent(wantId, () => []);

      final count = purchaseHistory.where((item) => item == purchase).length;
      for (int i = 0; i < count; i++) {
        final price = sellersOffers[sellerName]![wantId]![i];
        sellerWantPrices.add(price);
      }
    }
    return sellersOffersToBuy;
  }

  /// Returns (one of) the best combinations of wants to buy from [sellersOffers]
  /// in order to buy all possible [wants].
  /// The [wants] may contain duplicates.
  /// The [sellersOffers] must be sorted ascendingly by price.
  PriceOptimizerResult findBestOffers({
    required List<String> wants,
    required SellersOffers sellersOffers,
    CalculateShippingCost? calculateShippingCost,
  }) {
    final calculateShippingCostNonNull =
        calculateShippingCost ?? createCalculateShippingCost(0);
    _logger.info(
      'Looking for best offers for ${wants.length} wants from ${sellersOffers.length} sellers.',
    );
    final List<String> missingWants = [];

    final _Matrix<int> priceMatrix = List.generate(
      wants.length + 1, // + 1 to compare rows without checking boundaries
      (_) => List.filled(sellersOffers.length, _maxIntWeb),
    );
    priceMatrix[0][0] = 0; // initial price
    final _Matrix<_PurchaseHistory> purchaseHistoryMatrix = List.generate(
      wants.length + 1, // + 1 to compare rows without checking boundaries
      (_) => List.generate(sellersOffers.length, (_) => []),
    );

    // Calculates the additional cost of including some offer by a given seller.
    int additionalSellerShippingCost(
      _PurchaseHistory purchaseHistory,
      _Purchase newPurchase,
    ) {
      final sellerPurchases = purchaseHistory
          .where((purchase) => purchase.sellerName == newPurchase.sellerName)
          .toList();
      final purchaseCount = sellerPurchases
          .where((item) => item == newPurchase)
          .length;
      final offers = sellersOffers[newPurchase.sellerName]![newPurchase.wantId];
      if (offers == null || offers.length <= purchaseCount) {
        // seller does not offer what is wanted or not enough of what is wanted
        return _maxIntWeb;
      }
      final priceBefore = _determineTotalPrice(sellersOffers, sellerPurchases);
      final priceAfter = _determineTotalPrice(sellersOffers, [
        ...sellerPurchases,
        newPurchase,
      ]);
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

    for (final (prevWantIndex, wantId) in wants.indexed) {
      final wantIndex = prevWantIndex + 1;
      bool wantFound = false;

      for (final (sellerIndex, MapEntry(key: sellerName, value: sellerOffers))
          in sellersOffers.entries.indexed) {
        final offers = sellerOffers[wantId];
        if (offers == null) {
          // seller does not offer what is wanted
          continue;
        }
        final purchase = (sellerName: sellerName, wantId: wantId);

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

        final purchaseCount = basePurchaseHistory
            .where((item) => item == purchase)
            .length;
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
        missingWants.add(wantId);
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
              .fold<List<int>>([], (a, b) => [...a, ...b])
              .length,
          value: sellerOffers.values
              .fold<List<int>>([], (a, b) => [...a, ...b])
              .sum,
        ),
    };

    _logger.info(
      'Best offers found (${missingWants.length} missing). Total price: ${formatPrice(totalPrice)}',
    );
    return PriceOptimizerResult(
      totalPrice: totalPrice,
      sellersOffersToBuy: sellersOffersToBuy,
      sellersShippingCost: sellersShippingCost,
      missingWants: missingWants,
    );
  }
}
