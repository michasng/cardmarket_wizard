import 'package:cardmarket_wizard/components/seller_link.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';

class SellersOffersView extends StatelessWidget {
  final Wants wants;
  final SellersOffers sellersOffers;
  final Map<String, int> sellersShippingCostEuroCents;

  const SellersOffersView({
    super.key,
    required this.wants,
    required this.sellersOffers,
    required this.sellersShippingCostEuroCents,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: sellerName, value: wantsPrices)
            in sellersOffers.entries) ...[
          SellerLink(
            wantsId: wants.id,
            sellerName: sellerName,
            shippingCostEuroCents:
                sellersShippingCostEuroCents[sellerName] ?? 0,
          ),
          for (final MapEntry(key: productId, value: prices)
              in wantsPrices.entries)
            ListTile(
              title: Text(wants.findArticleByProductId(productId).name),
              subtitle: Text(prices.map(formatPrice).join(', ')),
            ),
        ],
      ],
    );
  }
}
