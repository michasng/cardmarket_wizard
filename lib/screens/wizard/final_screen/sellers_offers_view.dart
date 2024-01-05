import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
import 'package:flutter/material.dart';

class SellersOffersView extends StatelessWidget {
  final SellersOffers<WantsArticle> sellersOffers;

  const SellersOffersView({
    super.key,
    required this.sellersOffers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: sellerName, value: wantsPrices)
            in sellersOffers.entries) ...[
          Text(
            '$sellerName sells',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final MapEntry(key: want, value: prices) in wantsPrices.entries)
            ListTile(
              title: Text(want.name),
              subtitle: Text(prices.map(formatPrice).join(', ')),
            ),
        ]
      ],
    );
  }
}
