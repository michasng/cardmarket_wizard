import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/final_screen/sellers_offers_view.dart';
import 'package:cardmarket_wizard/screens/wizard/launch_screen.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
import 'package:flutter/material.dart';

class FinalScreen extends StatelessWidget {
  final WizardResult<WantsArticle> result;

  const FinalScreen({
    super.key,
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
                const SizedBox(height: 16),
                if (result.missingWants.isEmpty)
                  const Text('An ideal combination was found.'),
                if (result.missingWants.isNotEmpty)
                  Text(
                    'Missing in result: ${result.missingWants.map((want) => want.name).join(', ')}',
                  ),
                const SizedBox(height: 16),
                Text(
                  'Total price: ${formatPrice(result.totalPrice)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SellersOffersView(sellersOffers: result.sellerOffersToBuy),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.go(const LaunchScreen());
                  },
                  child: const Text('restart'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
