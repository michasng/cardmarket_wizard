import 'package:cardmarket_wizard/models/interfaces/article.dart';
import 'package:cardmarket_wizard/models/interfaces/article_seller.dart';
import 'package:cardmarket_wizard/models/price_optimizer/price_optimizer_result.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/table_view.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

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

  int? _getBestPriceEuroCents(ArticleSeller seller, String productId) {
    final offers = sellersOffers[seller.name]![productId];

    if (offers == null || offers.isEmpty) return null;

    return offers.first;
  }

  String? _getFormattedPrices(ArticleSeller seller, String productId) {
    final offers = sellersOffers[seller.name]![productId];

    if (offers == null || offers.isEmpty) return null;

    final priceCounts = <int, int>{};
    for (var offer in offers) {
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
    return TableView<ArticleSeller>(
      columnDefs: [
        ColumnDef<ArticleSeller>(
          label: 'Seller',
          getValue: (seller) => seller.name,
          cellBuilder: (seller) => Row(
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
        ColumnDef<ArticleSeller>(
          label: 'Location',
          getValue: (seller) => seller.location.label,
        ),
        ColumnDef<ArticleSeller>(
          label: 'Type',
          getValue: (seller) => seller.sellerType.label,
        ),
        ColumnDef<ArticleSeller>(
          label: 'Rating',
          getValue: (seller) => seller.rating?.ordinal,
          cellBuilder: (seller) => Text(seller.rating?.label ?? '-'),
        ),
        ColumnDef<ArticleSeller>(
          label: '# Products',
          isNumeric: true,
          getValue: (seller) => seller.itemCount,
        ),
        ColumnDef<ArticleSeller>(
          label: '# Sales',
          isNumeric: true,
          getValue: (seller) => seller.saleCount,
        ),
        ColumnDef<ArticleSeller>(
          label: 'ETA',
          isNumeric: true,
          getValue: (seller) => seller.etaDays ?? seller.etaLocationDays,
          cellBuilder: (seller) =>
              Text('${seller.etaDays ?? seller.etaLocationDays} days'),
        ),
        ColumnDef<ArticleSeller>(
          label: 'min. wants on offer',
          isNumeric: true,
          getValue: (seller) => sellersOffers[seller.name]!.length,
          cellBuilder: (seller) => Tooltip(
            message: sellersOffers[seller.name]!
                .keys
                .map(
                  (productId) => '$productId: ${_getFormattedPrices(
                    seller,
                    productId,
                  )}',
                )
                .join('\n'),
            child: Text(
              sellersOffers[seller.name]!.length.toString(),
            ),
          ),
        ),
        for (final productId in articlesByProductId.keys)
          ColumnDef<ArticleSeller>(
            label: productId,
            isNumeric: true,
            getValue: (seller) => _getBestPriceEuroCents(seller, productId),
            cellBuilder: (seller) => Tooltip(
              message: _getFormattedPrices(
                    seller,
                    productId,
                  ) ??
                  '',
              child: Text(
                _getBestPriceEuroCents(seller, productId)
                        ?.transform((euroCents) => formatPrice(euroCents)) ??
                    '-',
              ),
            ),
          ),
      ],
      rows: {
        // using a set to remove duplicates
        for (final articles in articlesByProductId.values)
          for (final article in articles) article.seller,
      }.toList(),
      isSelected: (seller) => sellerNamesToLookup.contains(seller.name),
      onSelectChanged: (seller, _) => onSellerTapped(seller.name),
    );
  }
}
