import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants.dart';
import 'package:cardmarket_wizard/navigator_state_go.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/async_sellers_wants_table.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/models/seller_row.dart';
import 'package:cardmarket_wizard/screens/wizard_optimize_search/wizard_optimize_search_screen.dart';
import 'package:cardmarket_wizard/services/cardmarket/wizard/sellers_offers_extractor_service.dart';
import 'package:flutter/material.dart';

class ResultOptimizerOption extends StatefulWidget {
  final Wants wants;
  final Set<String> initialSellerNamesToLookup;
  final Map<String, List<ArticleWithSeller>> articlesByProductId;

  const ResultOptimizerOption({
    super.key,
    required this.wants,
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
    final sellers = {
      // using a set to avoid duplicates
      for (final articles in widget.articlesByProductId.values)
        for (final article in articles) article.seller,
    };

    return Column(
      spacing: 16,
      children: [
        FilledButton(
          onPressed: () {
            final navigator = Navigator.of(context);
            navigator.go(
              WizardOptimizeSearchScreen(
                wants: widget.wants,
                sellerNamesToLookup: sellerNamesToLookup,
              ),
            );
          },
          child: Text(
            'Optimize Results (lookup ${sellerNamesToLookup.length}) sellers',
          ),
        ),
        Text(
          'Sellers and Wants',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AsyncSellersWantsTable(
          productIds: widget.articlesByProductId.keys.toList(),
          rows: [
            for (final seller in sellers)
              SellerRow(
                seller: seller,
                pricesByProductId: sellersOffers[seller.name]!,
                selected: sellerNamesToLookup.contains(seller.name),
              ),
          ],
          onToggleRowSelected: (row) {
            final sellerName = row.seller.name;
            if (sellerNamesToLookup.contains(sellerName)) {
              setState(() {
                sellerNamesToLookup.remove(sellerName);
              });
            } else {
              setState(() {
                sellerNamesToLookup.add(sellerName);
              });
            }
          },
        ),
      ],
    );
  }
}
