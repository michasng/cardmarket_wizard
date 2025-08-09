import 'package:cardmarket_wizard/components/add_to_cart/models/offer_row.dart';
import 'package:cardmarket_wizard/components/count_control.dart';
import 'package:cardmarket_wizard/components/table_view.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';

class OffersTable extends StatelessWidget {
  final List<OfferRow> offerRows;
  final void Function(OfferRow rowToChange, OfferRow changedRow) onChangeRow;

  const OffersTable({
    super.key,
    required this.offerRows,
    required this.onChangeRow,
  });

  @override
  Widget build(BuildContext context) {
    return TableView<OfferRow>(
      columnDefs: [
        ColumnDef(
          label: 'Seller',
          getValue: (row) => row.sellerName,
        ),
        ColumnDef(
          label: 'Product',
          getValue: (row) => row.productId,
        ),
        ColumnDef(
          label: 'Condition',
          getValue: (row) => row.article.info.condition.label,
        ),
        ColumnDef(
          label: 'Price',
          getValue: (row) => formatPrice(row.article.offer.priceEuroCents),
        ),
        ColumnDef(
          label: 'On offer',
          getValue: (row) => row.article.offer.quantity,
          cellBuilder: (row) => CountControl(
            max: row.article.offer.quantity,
            value: row.countToBuy,
            onChange: (countToBuy) {
              onChangeRow(row, row.copyWith(countToBuy: countToBuy));
            },
            iconSize: 10,
          ),
        ),
      ],
      rows: offerRows,
    );
  }
}
