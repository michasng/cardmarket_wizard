import 'package:cardmarket_wizard/models/enums/seller_rating.dart';
import 'package:cardmarket_wizard/models/wants.dart';

class OrchestratorConfig {
  final Wants wants;
  final int maxEtaDays;
  final SellerRating minSellerRating;
  final bool includeNewSellers;
  final int minSellersToLookup;
  final int maxSellersToLookup;

  const OrchestratorConfig({
    required this.wants,
    this.maxEtaDays = 6,
    this.minSellerRating = SellerRating.good,
    this.includeNewSellers = true,
    this.minSellersToLookup = 10,
    this.maxSellersToLookup = 100,
  }) : assert(minSellersToLookup <= maxSellersToLookup);
}
