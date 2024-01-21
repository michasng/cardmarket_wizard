import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/models/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/wizard/final/sellers_offers_view.dart';
import 'package:cardmarket_wizard/screens/wizard/login_screen.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:cardmarket_wizard/services/shopping_wizard.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class FinalScreen extends StatelessWidget {
  final Location location;
  final WizardResult<WantsArticle> result;

  const FinalScreen({
    super.key,
    required this.location,
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
                Text(
                  'Total price: ${formatPrice(result.totalPrice)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SellersOffersView(sellersOffers: result.sellerOffersToBuy),
                FilledButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.go(LoginScreen(location: location));
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
