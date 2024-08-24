import 'package:cardmarket_wizard/components/wizard_result_view.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wizard/wizard_config.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/login/login_screen.dart';
import 'package:cardmarket_wizard/screens/wizard_optimize_search/wizard_optimize_search_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/seller_score_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class PreliminaryResultScreen extends StatelessWidget {
  final WizardConfig config;
  final PriceOptimizerResult result;
  final Map<String, List<ArticleWithSeller>> articlesByProductId;

  const PreliminaryResultScreen({
    super.key,
    required this.config,
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
              children: [
                Text(
                  'Initial search done',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('Do you want to optimize results?'),
                AsyncBuilder(
                  createFuture: (_) => SellerScoreService.instance()
                      .determineSellerNamesToLookup(
                    config,
                    articlesByProductId: articlesByProductId,
                    sellerNamesToInclude:
                        result.sellersOffersToBuy.keys.toSet(),
                  ),
                  builder: (context, sellerNamesToLookup) => FilledButton(
                    onPressed: () {
                      final navigator = Navigator.of(context);
                      navigator.go(
                        WizardOptimizeSearchScreen(
                          config: config,
                          sellerNamesToLookup: sellerNamesToLookup,
                        ),
                      );
                    },
                    child: const Text('Optimize results'),
                  ),
                ),
                WizardResultView(
                  wants: config.wants,
                  result: result,
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
