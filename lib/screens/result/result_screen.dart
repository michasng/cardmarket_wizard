import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/login/login_screen.dart';
import 'package:cardmarket_wizard/screens/result/sellers_offers_view.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class ResultScreen extends StatelessWidget {
  final Wants wants;
  final PriceOptimizerResult result;

  const ResultScreen({
    super.key,
    required this.wants,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Wizard done',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (result.missingWants.isEmpty)
                  const Text('An ideal combination was found.'),
                if (result.missingWants.isNotEmpty)
                  Text(
                    'Missing in result: ${result.missingWants.map((articleId) => wants.findArticle(articleId).name).join(', ')}',
                  ),
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
                        '${formatPrice(result.price)} + ${formatPrice(result.shippingCost)} shipping',
                      ),
                    ),
                  ],
                ),
                SellersOffersView(
                  wants: wants,
                  sellersOffers: result.sellersOffersToBuy,
                  sellersShippingCostEuroCents: result.sellersShippingCost,
                ),
                FilledButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.go(const LoginScreen());
                  },
                  child: const Text('Try another wants list'),
                ),
              ].separated(const Gap()),
            ),
          ),
        ),
      ),
    );
  }
}
