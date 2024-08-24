import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wizard/wizard_config.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/sellers_wants_table.dart';
import 'package:cardmarket_wizard/screens/wizard_optimize_search/wizard_optimize_search_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/sellers_offers_extractor_service.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class ResultOptimizerOption extends StatefulWidget {
  final WizardConfig config;
  final Set<String> initialSellerNamesToLookup;
  final Map<String, List<ArticleWithSeller>> articlesByProductId;

  const ResultOptimizerOption({
    super.key,
    required this.config,
    required this.initialSellerNamesToLookup,
    required this.articlesByProductId,
  });

  @override
  State<ResultOptimizerOption> createState() => _ResultOptimizerOptionState();
}

class _ResultOptimizerOptionState extends State<ResultOptimizerOption> {
  late Set<String> sellerNamesToLookup;
  late final SellersOffers sellersOffers;

  @override
  void initState() {
    super.initState();

    sellerNamesToLookup = widget.initialSellerNamesToLookup;

    final sellersOffersExtractor = SellersOffersExtractorService.instance();
    sellersOffers =
        sellersOffersExtractor.extractSellersOffers(widget.articlesByProductId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: () {
            final navigator = Navigator.of(context);
            navigator.go(
              WizardOptimizeSearchScreen(
                config: widget.config,
                sellerNamesToLookup: sellerNamesToLookup,
              ),
            );
          },
          child: const Text('Optimize Results'),
        ),
        Text(
          'Sellers and Wants',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SellersWantsTable(
          articlesByProductId: widget.articlesByProductId,
          sellersOffers: sellersOffers,
          sellerNamesToLookup: sellerNamesToLookup,
          onSellerTapped: (sellerName) {
            setState(() {
              if (sellerNamesToLookup.contains(sellerName)) {
                sellerNamesToLookup.remove(sellerName);
              } else {
                sellerNamesToLookup.add(sellerName);
              }
            });
          },
        ),
      ].separated(const Gap()),
    );
  }
}
