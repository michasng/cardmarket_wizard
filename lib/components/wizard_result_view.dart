import 'package:cardmarket_wizard/components/add_to_cart_button.dart';
import 'package:cardmarket_wizard/components/sellers_offers_view.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';

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
      spacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Spacer(),
            Text(
              'Total price: ${formatPrice(result.totalPrice)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
              : 'Missing in result: ${result.missingWants.map((productId) => wants.findArticleByProductId(productId).name).join(', ')}',
        ),
        AddToCartButton(
          quantityByArticleId: result.determineQuantityByArticleId(),
        ),
        SellersOffersView(
          wants: wants,
          sellersOffers: result.sellersOffersToBuy,
          sellersShippingCostEuroCents: result.sellersShippingCost,
        ),
      ],
    );
  }
}
