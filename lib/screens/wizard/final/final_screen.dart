import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/final/sellers_offers_view.dart';
import 'package:cardmarket_wizard/screens/wizard/login_screen.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class FinalScreen extends StatelessWidget {
  final Wants wants;
  final WizardResult<WantsArticle> result;

  const FinalScreen({
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
                    'Missing in result: ${result.missingWants.map((want) => want.name).join(', ')}',
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
                  wantsId: wants.id,
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
