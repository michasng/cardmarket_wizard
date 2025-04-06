import 'package:cardmarket_wizard/components/add_to_cart_button.dart';
import 'package:cardmarket_wizard/components/restart_button.dart';
import 'package:cardmarket_wizard/components/wizard_result_view.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/result_optimizer_option.dart';
import 'package:flutter/material.dart';

class PreliminaryResultScreen extends StatelessWidget {
  final Wants wants;
  final PriceOptimizerResult result;
  final Map<String, List<ArticleWithSeller>> articlesByProductId;

  const PreliminaryResultScreen({
    super.key,
    required this.wants,
    required this.result,
    required this.articlesByProductId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              spacing: 16,
              children: [
                Text(
                  'Initial Search Done',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'These results are unoptimized. You can choose to "Optimize Results" below.',
                ),
                const Divider(),
                WizardResultView(
                  wants: wants,
                  result: result,
                ),
                AddToCartButton(
                  quantityByArticleId: result.determineQuantityByArticleId(),
                ),
                RestartButton(),
                const Divider(),
                const Text('Do you want to optimize results?'),
                ResultOptimizerOption(
                  wants: wants,
                  initialSellerNamesToLookup:
                      result.sellersOffersToBuy.keys.toSet(),
                  articlesByProductId: articlesByProductId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
