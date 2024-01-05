import 'dart:math';

import 'package:cardmarket_wizard/components/get_or_put.dart';
import 'package:cardmarket_wizard/logging.dart';
import 'package:cardmarket_wizard/services/cardmarket/currency.dart';
import 'package:collection/collection.dart';

const int _maxIntWeb = 0x20000000000000;
typedef Purchase<TSellerId, TWant> = ({TSellerId sellerId, TWant want});
typedef PurchaseHistory<TSellerId, TWant> = List<Purchase<TSellerId, TWant>>;
typedef SellersOffers<TSellerId, TWant> = Map<TSellerId, Map<TWant, List<int>>>;
typedef Matrix<T> = List<List<T>>;
const _deepEq = DeepCollectionEquality();

class WizardResult<TSellerId, TWant> {
  final int totalPrice;
  final SellersOffers<TSellerId, TWant> sellerOffersToBuy;
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

  SellersOffers<TSellerId, TWant> _toSellerOffersToBuy<TSellerId, TWant>(
    SellersOffers<TSellerId, TWant> sellersOffers,
    PurchaseHistory<TSellerId, TWant> purchaseHistory,
  ) {
    final SellersOffers<TSellerId, TWant> sellersOffersToBuy = {};
    for (final purchase in purchaseHistory.toSet()) {
      final (:sellerId, :want) = purchase;
      final sellerOffersToBuy = sellersOffersToBuy.getOrPut(sellerId, () => {});
      final sellerWantPrices = sellerOffersToBuy.getOrPut(want, () => []);

      final count = purchaseHistory.where((item) => item == purchase).length;
      for (int i = 0; i < count; i++) {
        final price = sellersOffers[sellerId]![want]![i];
        sellerWantPrices.add(price);
      }
    }
    return sellersOffersToBuy;
  }

  /// Returns (one of) the best combinations of wants to buy from [sellersOffers]
  /// in order to buy all possible [wants].
  /// The [wants] may contain duplicates.
  /// The [sellersOffers] must be sorted ascendingly by price.
  WizardResult<TSellerId, TWant> findBestOffers<TSellerId, TWant>({
    required List<TWant> wants,
    required SellersOffers<TSellerId, TWant> sellersOffers,
    int shippingCost = 0,
  }) {
    final List<TWant> missingWants = [];

    final Matrix<int> priceMatrix = List.generate(
      wants.length + 1, // + 1 to compare rows without checking boundaries
      (_) => List.filled(sellersOffers.length, _maxIntWeb),
    );
    priceMatrix[0][0] = 0; // initial price
    final Matrix<PurchaseHistory<TSellerId, TWant>> purchaseHistoryMatrix =
        List.generate(
      wants.length + 1, // + 1 to compare rows without checking boundaries
      (_) => List.generate(sellersOffers.length, (_) => []),
    );

    // Calculates the additional cost of including some offer by a given seller.
    int additionalSellerShippingCost(
      TSellerId sellerId,
      PurchaseHistory<TSellerId, TWant> purchaseHistory,
    ) {
      final isSellerInHistory = purchaseHistory.any(
        (purchase) => purchase.sellerId == sellerId,
      );
      return isSellerInHistory ? 0 : shippingCost;
    }

    /// Finds the index of the seller with the lowest cost for a given want.
    /// Considers additional shipping costs when a [nextSellerId] is given.
    int findBestSellerIndex(int wantIndex, TSellerId? nextSellerId) {
      final wantPrices = priceMatrix[wantIndex];
      if (nextSellerId == null) {
        return wantPrices.indexOf(wantPrices.reduce(min));
      }

      final histories = purchaseHistoryMatrix[wantIndex];
      final shippingCosts = [
        for (final history in histories)
          additionalSellerShippingCost(nextSellerId, history),
      ];
      final pricesWithShipping = List.generate(
        wantPrices.length,
        (index) => wantPrices[index] + shippingCosts[index],
      );
      return pricesWithShipping.indexOf(pricesWithShipping.reduce(min));
    }

    /// Finds and returns the best pair of want/seller indexes up to a given [maxInclusiveWantIndex].
    /// The "best" indexes contain as many [wants] as possible and require minimal cost.
    /// Considers additional shipping costs when a [nextSellerId] is given.
    ({int wantIndex, int sellerIndex}) findBaseIndices(
      int maxInclusiveWantIndex,
      TSellerId? nextSellerId,
    ) {
      int baseWantIndex = maxInclusiveWantIndex;
      while (true) {
        final baseSellerIndex =
            findBestSellerIndex(baseWantIndex, nextSellerId);
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

      for (final (sellerIndex, MapEntry(key: sellerId, value: sellerOffers))
          in sellersOffers.entries.indexed) {
        final offers = sellerOffers[want];
        if (offers == null) {
          // seller does not offer what is wanted
          continue;
        }

        final (
          wantIndex: baseWantIndex,
          sellerIndex: baseSellerIndex,
        ) = findBaseIndices(prevWantIndex, sellerId);
        final baseWantPrice = priceMatrix[baseWantIndex][baseSellerIndex];
        final basePurchaseHistory =
            purchaseHistoryMatrix[baseWantIndex][baseSellerIndex];

        final purchase = (
          sellerId: sellerId,
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
          sellerId,
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

    _logger.info('best total price: ${formatPrice(totalPrice)}');
    return WizardResult(
      totalPrice: totalPrice,
      sellerOffersToBuy: sellerOffersToBuy,
      missingWants: missingWants,
    );
  }
}
