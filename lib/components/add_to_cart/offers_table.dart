import 'package:cardmarket_wizard/components/add_to_cart/models/offer_row.dart';
import 'package:cardmarket_wizard/components/count_control.dart';
import 'package:cardmarket_wizard/components/table_view.dart';
import 'package:cardmarket_wizard/services/currency.dart';
import 'package:flutter/material.dart';

class OffersTable extends StatefulWidget {
  static const String _trueValue = 'yes';
  static const String _falseValue = 'no';

  final List<OfferRow> offerRows;
  final Set<String>? sellerNamesFilter;
  final void Function(OfferRow rowToChange, OfferRow changedRow) onChangeRow;

  const OffersTable({
    super.key,
    required this.offerRows,
    required this.sellerNamesFilter,
    required this.onChangeRow,
  });

  @override
  State<OffersTable> createState() => _OffersTableState();
}

class _OffersTableState extends State<OffersTable> {
  final _tableViewKey = GlobalKey<TableViewState<OfferRow>>();

  @override
  void didUpdateWidget(covariant OffersTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sellerNamesFilter != widget.sellerNamesFilter) {
      _tableViewKey.currentState?.onFilter(getFilter());
    }
  }

  bool Function(OfferRow row) getFilter() {
    return widget.sellerNamesFilter == null
        ? (row) => true
        : (row) => widget.sellerNamesFilter!.contains(row.sellerName);
  }

  @override
  Widget build(BuildContext context) {
    return TableView<OfferRow>(
      key: _tableViewKey,
      initialFilter: getFilter(),
      columnDefs: [
        ColumnDef(label: 'Seller', getValue: (row) => row.sellerName),
        ColumnDef(label: 'Product', getValue: (row) => row.productId),
        ColumnDef(label: 'Rarity', getValue: (row) => row.article.rarity),
        ColumnDef(
          label: 'Condition',
          getValue: (row) => row.article.condition.label,
        ),
        ColumnDef(
          label: 'Language',
          getValue: (row) => row.article.language.label,
        ),
        ColumnDef(
          label: 'Price',
          getValue: (row) => formatPrice(row.article.priceEuroCents),
        ),
        ColumnDef(
          label: 'On offer',
          getValue: (row) => row.article.quantity,
          cellBuilder: (row) => CountControl(
            max: row.article.quantity,
            value: row.countToBuy,
            onChange: (countToBuy) {
              widget.onChangeRow(row, row.copyWith(countToBuy: countToBuy));
            },
            iconSize: 10,
          ),
        ),
        ColumnDef(label: 'Comment', getValue: (row) => row.article.comment),
        ColumnDef(
          label: 'Reverse Holo?',
          getValue: (row) => row.article.isReverseHolo
              ? OffersTable._trueValue
              : OffersTable._falseValue,
        ),
        ColumnDef(
          label: 'Signed?',
          getValue: (row) => row.article.isSigned
              ? OffersTable._trueValue
              : OffersTable._falseValue,
        ),
        ColumnDef(
          label: 'First Edition?',
          getValue: (row) => row.article.isFirstEdition
              ? OffersTable._trueValue
              : OffersTable._falseValue,
        ),
        ColumnDef(
          label: 'Altered?',
          getValue: (row) => row.article.isAltered
              ? OffersTable._trueValue
              : OffersTable._falseValue,
        ),
      ],
      rows: widget.offerRows,
    );
  }
}
