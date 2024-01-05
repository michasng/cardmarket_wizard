import 'dart:math';

import 'package:cardmarket_wizard/components/get_or_put.dart';
import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:collection/collection.dart';

const int _maxIntWeb = 0x20000000000000;
typedef Purchase<TWant> = ({String sellerName, TWant want});
typedef PurchaseHistory<TWant> = List<Purchase<TWant>>;
typedef WantsPrices<TWant> = Map<TWant, List<int>>;
typedef SellersOffers<TWant> = Map<String, WantsPrices<TWant>>;
typedef Matrix<T> = List<List<T>>;
const _deepEq = DeepCollectionEquality();

class WizardResult<TWant> {
  final int totalPrice;
  final SellersOffers<TWant> sellerOffersToBuy;
  final List<TWant> missingWants;

  const WizardResult({
    required this.totalPrice,
    required this.sellerOffersToBuy,
    this.missingWants = const [],
  });

  @override
  bool operator ==(Object other) =>
      other is WizardResult &&
      other.runtimeType == runtimeType &&
      other.totalPrice == totalPrice &&
      _deepEq.equals(other.sellerOffersToBuy, sellerOffersToBuy) &&
      _deepEq.equals(other.missingWants, missingWants);

  @override
  int get hashCode => Object.hashAll([
        totalPrice,
        sellerOffersToBuy,
        missingWants,
      ]);

  @override
  String toString() {
    return {
      'totalPrice': totalPrice,
      'sellerOffersToBuy': sellerOffersToBuy,
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

  SellersOffers<TWant> _toSellerOffersToBuy<TWant>(
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
    int shippingCost = 0,
  }) {
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
      String sellerName,
      PurchaseHistory<TWant> purchaseHistory,
    ) {
      final isSellerInHistory = purchaseHistory.any(
        (purchase) => purchase.sellerName == sellerName,
      );
      return isSellerInHistory ? 0 : shippingCost;
    }

    /// Finds the index of the seller with the lowest cost for a given want.
    /// Considers additional shipping costs when a [nextSellerName] is given.
    int findBestSellerIndex(int wantIndex, String? nextSellerName) {
      final wantPrices = priceMatrix[wantIndex];
      if (nextSellerName == null) {
        return wantPrices.indexOf(wantPrices.reduce(min));
      }

      final histories = purchaseHistoryMatrix[wantIndex];
      final shippingCosts = [
        for (final history in histories)
          additionalSellerShippingCost(nextSellerName, history),
      ];
      final pricesWithShipping = List.generate(
        wantPrices.length,
        (index) => wantPrices[index] + shippingCosts[index],
      );
      return pricesWithShipping.indexOf(pricesWithShipping.reduce(min));
    }

    /// Finds and returns the best pair of want/seller indexes up to a given [maxInclusiveWantIndex].
    /// The "best" indexes contain as many [wants] as possible and require minimal cost.
    /// Considers additional shipping costs when a [nextSellerName] is given.
    ({int wantIndex, int sellerIndex}) findBaseIndices(
      int maxInclusiveWantIndex,
      String? nextSellerName,
    ) {
      int baseWantIndex = maxInclusiveWantIndex;
      while (true) {
        final baseSellerIndex =
            findBestSellerIndex(baseWantIndex, nextSellerName);
        if (priceMatrix[baseWantIndex][baseSellerIndex] != _maxIntWeb) {
          return (
            wantIndex: baseWantIndex,
            sellerIndex: baseSellerIndex,
          );
        }
        baseWantIndex -= 1;
      }
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

        final (
          wantIndex: baseWantIndex,
          sellerIndex: baseSellerIndex,
        ) = findBaseIndices(prevWantIndex, sellerName);
        final baseWantPrice = priceMatrix[baseWantIndex][baseSellerIndex];
        final basePurchaseHistory =
            purchaseHistoryMatrix[baseWantIndex][baseSellerIndex];

        final purchase = (
          sellerName: sellerName,
          want: want,
        );
        final purchaseCount =
            basePurchaseHistory.where((item) => item == purchase).length;
        if (offers.length <= purchaseCount) {
          // seller does not offer enough of what is wanted
          continue;
        }
        final offer = offers[purchaseCount];

        final additionalShippingCost = additionalSellerShippingCost(
          sellerName,
          basePurchaseHistory,
        );
        final price = baseWantPrice + offer + additionalShippingCost;

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

    final (
      wantIndex: resultWantIndex,
      sellerIndex: resultSellerIndex,
    ) = findBaseIndices(wants.length, null);

    final totalPrice = priceMatrix[resultWantIndex][resultSellerIndex];
    final purchaseHistory =
        purchaseHistoryMatrix[resultWantIndex][resultSellerIndex];
    final sellerOffersToBuy = _toSellerOffersToBuy(
      sellersOffers,
      purchaseHistory,
    );

    _logger.info(
        'Best offers found (${missingWants.length} missing). Total price: ${formatPrice(totalPrice)}');
    return WizardResult(
      totalPrice: totalPrice,
      sellerOffersToBuy: sellerOffersToBuy,
      missingWants: missingWants,
    );
  }
}
