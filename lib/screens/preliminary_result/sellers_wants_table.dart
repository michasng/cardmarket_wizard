import 'package:cardmarket_wizard/components/single_child_scrollable.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/models/wants/wants_article.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';

class SellersWantsTable extends StatelessWidget {
  final List<WantsArticle> wantsArticles;
  final SellersOffers sellersOffers;
  final Set<String> sellerNamesToLookup;
  final void Function(String sellerName) onSellerTapped;

  const SellersWantsTable({
    super.key,
    required this.wantsArticles,
    required this.sellersOffers,
    required this.sellerNamesToLookup,
    required this.onSellerTapped,
  });

  Widget _tableCell(String content, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(4),
      color: color,
      child: Text(content),
    );
  }

  String _formatPrice(List<int>? sellerOffers) {
    if (sellerOffers == null || sellerOffers.isEmpty) return '';

    final priceCounts = <int, int>{};
    for (var offer in sellerOffers) {
      priceCounts[offer] = (priceCounts[offer] ?? 0) + 1;
    }

    final formattedPrices = priceCounts.entries.map((priceCount) {
      final euroCents = priceCount.key;
      final count = priceCount.value;

      final priceFormatted = formatPrice(euroCents, withEuroSymbol: false);
      return count > 1 ? '$count x $priceFormatted' : priceFormatted;
    }).join(' | ');

    return '$formattedPrices €';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollable(
      scrollDirection: Axis.horizontal,
      primary: false,
      child: Table(
        border: TableBorder.all(),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          TableRow(
            decoration: BoxDecoration(color: theme.colorScheme.surfaceDim),
            children: [
              _tableCell('Seller'),
              _tableCell('lookup?'),
              for (final wantsArticle in wantsArticles)
                _tableCell(wantsArticle.id),
            ],
          ),
          for (final MapEntry(key: sellerName, value: sellerOffers)
              in sellersOffers.entries)
            TableRow(
              children: [
                _tableCell(
                  sellerName,
                  color: theme.colorScheme.surfaceDim,
                ),
                Checkbox(
                  value: sellerNamesToLookup.contains(sellerName),
                  onChanged: (_) => onSellerTapped(sellerName),
                ),
                for (final wantsArticle in wantsArticles)
                  _tableCell(_formatPrice(sellerOffers[wantsArticle.id])),
              ],
            ),
        ],
      ),
    );
  }
}
