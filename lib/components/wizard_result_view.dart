import 'package:cardmarket_wizard/components/sellers_offers_view.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class WizardResultView extends StatelessWidget {
  final Wants wants;
  final PriceOptimizerResult result;

  const WizardResultView({
    super.key,
    required this.wants,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            const Gap(),
            Text(
              'Total price: ${formatPrice(result.totalPrice)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(),
            Expanded(
              child: Text(
                '${formatPrice(result.price)} + ${formatPrice(result.shippingCost)} shipping for ${result.sellersOffersToBuy.length} orders',
              ),
            ),
          ],
        ),
        Text(
          result.missingWants.isEmpty
              ? 'All wanted products have been found.'
              : 'Missing in result: ${result.missingWants.map((articleId) => wants.findArticle(articleId).name).join(', ')}',
        ),
        SellersOffersView(
          wants: wants,
          sellersOffers: result.sellersOffersToBuy,
          sellersShippingCostEuroCents: result.sellersShippingCost,
        ),
      ].separated(const Gap()),
    );
  }
}
