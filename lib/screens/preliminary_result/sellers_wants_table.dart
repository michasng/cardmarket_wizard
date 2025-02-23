import 'package:cardmarket_wizard/components/single_child_scrollable.dart';
import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';

class SellersWantsTable extends StatelessWidget {
  final Map<String, List<ArticleWithSeller>> articlesByProductId;
  final SellersOffers sellersOffers;
  final Set<String> sellerNamesToLookup;
  final void Function(String sellerName) onSellerTapped;

  const SellersWantsTable({
    super.key,
    required this.articlesByProductId,
    required this.sellersOffers,
    required this.sellerNamesToLookup,
    required this.onSellerTapped,
  });

  String _formatPriceCount(List<int>? sellerOffers) {
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

  Set<ArticleSeller> get _sellers {
    return {
      for (final articles in articlesByProductId.values)
        for (final article in articles) article.seller,
    };
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
            children: const [
              _TableCell(child: Text('Seller')),
              _TableCell(child: Text('Location')),
              _TableCell(child: Text('Type')),
              _TableCell(child: Text('Rating')),
              _TableCell(child: Text('# Products')),
              _TableCell(child: Text('# Sales')),
              _TableCell(child: Text('ETA')),
              _TableCell(child: Text('lookup?')),
              _TableCell(child: Text('min. wants on offer')),
            ],
          ),
          for (final seller in _sellers)
            TableRow(
              children: [
                _TableCell(
                  color: theme.colorScheme.surfaceDim,
                  child: Row(
                    children: [
                      Text(seller.name),
                      if (seller.warnings.isNotEmpty)
                        Tooltip(
                          message: seller.warnings.join('\n'),
                          child: const Icon(Icons.warning),
                        ),
                    ],
                  ),
                ),
                _TableCell(
                  child: Text(seller.location.label),
                ),
                _TableCell(
                  child: Text(seller.sellerType.label),
                ),
                _TableCell(
                  child: Text(seller.rating?.label ?? ''),
                ),
                _TableCell(
                  alignment: Alignment.topRight,
                  child: Text(seller.itemCount.toString()),
                ),
                _TableCell(
                  alignment: Alignment.topRight,
                  child: Text(seller.saleCount.toString()),
                ),
                _TableCell(
                  alignment: Alignment.topRight,
                  child:
                      Text('${seller.etaDays ?? seller.etaLocationDays} days'),
                ),
                _TableCell(
                  color: theme.colorScheme.surfaceDim,
                  alignment: Alignment.topCenter,
                  child: Checkbox(
                    value: sellerNamesToLookup.contains(seller.name),
                    onChanged: (_) => onSellerTapped(seller.name),
                  ),
                ),
                _TableCell(
                  child: Text(
                    sellersOffers[seller.name]!
                        .keys
                        .map(
                          (productId) => '$productId: ${_formatPriceCount(
                            sellersOffers[seller.name]![productId],
                          )}',
                        )
                        .join('\n'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Alignment? alignment;

  const _TableCell({
    required this.child,
    this.color,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: color == null ? null : TableCellVerticalAlignment.fill,
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.all(4),
        color: color,
        child: child,
      ),
    );
  }
}
