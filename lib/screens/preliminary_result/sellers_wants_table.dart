import 'package:cardmarket_wizard/components/table_view.dart';
import 'package:cardmarket_wizard/models/enums/location.dart';
import 'package:cardmarket_wizard/screens/preliminary_result/models/seller_row.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:micha_core/micha_core.dart';

class SellersWantsTable extends StatefulWidget {
  final List<String> productIds;
  final List<SellerRow> rows;
  final Map<Location, int> minShippingEuroCentsByLocation;
  final void Function(SellerRow row) onToggleRowSelected;

  const SellersWantsTable({
    super.key,
    required this.productIds,
    required this.rows,
    required this.minShippingEuroCentsByLocation,
    required this.onToggleRowSelected,
  });

  @override
  State<SellersWantsTable> createState() => _SellersWantsTableState();
}

class _SellersWantsTableState extends State<SellersWantsTable> {
  final _tableViewKey = GlobalKey<TableViewState<SellerRow>>();

  Iterable<int> _findPricesEuroCents(String productId) {
    return widget.rows
        .where((row) => row.pricesByProductId.containsKey(productId))
        .map((row) => row.pricesByProductId[productId]!.first);
  }

  String _findMinPrice(String productId) {
    final prices = _findPricesEuroCents(productId);
    return formatPrice(prices.min);
  }

  String _findAveragePrice(String productId) {
    final prices = _findPricesEuroCents(productId);
    return formatPrice(prices.average.floor());
  }

  String _formatPrices(List<int> prices) {
    final priceCounts = <int, int>{};
    for (var price in prices) {
      priceCounts[price] = (priceCounts[price] ?? 0) + 1;
    }

    final formattedPrices = priceCounts.entries
        .map((priceCount) {
          final euroCents = priceCount.key;
          final count = priceCount.value;

          final priceFormatted = formatPrice(euroCents, withEuroSymbol: false);
          return count > 1 ? '$count x $priceFormatted' : priceFormatted;
        })
        .join(' | ');

    return '$formattedPrices €';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(labelText: 'search seller'),
            onChanged: (filterValue) {
              _tableViewKey.currentState?.onFilter(
                (row) => row.seller.name.toLowerCase().contains(
                  filterValue.toLowerCase(),
                ),
              );
            },
          ),
        ),
        TableView<SellerRow>(
          key: _tableViewKey,
          columnDefs: [
            ColumnDef(
              label: 'Seller',
              getValue: (row) => row.seller.name,
              cellBuilder: (row) => Row(
                spacing: 8,
                children: [
                  Text(row.seller.name),
                  if (row.seller.warnings.isNotEmpty)
                    Tooltip(
                      message: row.seller.warnings.join('\n'),
                      child: const Icon(Icons.warning),
                    ),
                ],
              ),
            ),
            ColumnDef(
              label: 'Location',
              getValue: (row) => row.seller.location.label,
            ),
            ColumnDef(
              label: 'Type',
              getValue: (row) => row.seller.sellerType.label,
            ),
            ColumnDef(
              label: 'Rating',
              getValue: (row) => row.seller.rating?.ordinal,
              cellBuilder: (row) => Text(row.seller.rating?.label ?? '-'),
            ),
            ColumnDef(
              label: '# Products',
              isNumeric: true,
              getValue: (row) => row.seller.itemCount,
            ),
            ColumnDef(
              label: '# Sales',
              isNumeric: true,
              getValue: (row) => row.seller.saleCount,
            ),
            ColumnDef(
              label: 'ETA',
              isNumeric: true,
              getValue: (row) =>
                  row.seller.etaDays ?? row.seller.etaLocationDays,
              cellBuilder: (row) => Text(
                '${row.seller.etaDays ?? row.seller.etaLocationDays} days',
              ),
            ),
            ColumnDef(
              label: 'min. wants on offer',
              isNumeric: true,
              getValue: (row) => row.pricesByProductId.length,
              cellBuilder: (row) => Tooltip(
                message: row.pricesByProductId.keys
                    .map(
                      (productId) =>
                          '$productId: ${_formatPrices(row.pricesByProductId[productId]!)}',
                    )
                    .join('\n'),
                child: Text(row.pricesByProductId.length.toString()),
              ),
            ),
            ColumnDef(
              label: 'min. shipping cost',
              isNumeric: true,
              getValue: (row) =>
                  widget.minShippingEuroCentsByLocation[row.seller.location],
              cellBuilder: (row) => Text(
                formatPrice(
                  widget.minShippingEuroCentsByLocation[row.seller.location]!,
                ),
              ),
            ),
            for (final productId in widget.productIds)
              ColumnDef(
                label: productId,
                isNumeric: true,
                getValue: (row) =>
                    row.pricesByProductId[productId]?.firstOrNull,
                cellBuilder: (row) {
                  final cellContent = Text(
                    row.pricesByProductId[productId]?.firstOrNull?.transform(
                          formatPrice,
                        ) ??
                        '-',
                  );

                  final prices = row.pricesByProductId[productId];
                  if (prices == null) return cellContent;

                  final minPrice = _findMinPrice(productId);
                  final avgPrice = _findAveragePrice(productId);

                  return Tooltip(
                    message: [
                      _formatPrices(prices),
                      'vs. min. $minPrice, avg. $avgPrice',
                    ].join('\n'),
                    child: cellContent,
                  );
                },
              ),
          ],
          rows: widget.rows,
          onToggleRowSelected: widget.onToggleRowSelected,
        ),
      ],
    );
  }
}
