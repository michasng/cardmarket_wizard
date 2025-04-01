import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/services/cardmarket/pages/seller_singles_page.dart';
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
          InkWell(
            onTap: () async {
              await SellerSinglesPage.goTo(
                sellerName,
                wantsId: wants.id,
              );
            },
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Seller '),
                  TextSpan(
                    text: sellerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextSpan(
                    text:
                        ' (+ ${formatPrice(sellersShippingCostEuroCents[sellerName]!)} shipping)',
                  ),
                ],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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
