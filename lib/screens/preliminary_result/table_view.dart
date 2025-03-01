import 'package:cardmarket_wizard/components/single_child_scrollable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ColumnDef<TRow> {
  final String label;
  final bool isNumeric;
  final Comparable<dynamic>? Function(TRow row) getValue;
  final Widget Function(TRow row)? cellBuilder;

  const ColumnDef({
    required this.label,
    this.isNumeric = false,
    required this.getValue,
    this.cellBuilder,
  });
}

class TableView<TRow> extends StatefulWidget {
  final List<ColumnDef<TRow>> columnDefs;
  final List<TRow> rows;
  final bool Function(TRow row) isSelected;
  final void Function(TRow row, bool? selected) onSelectChanged;

  const TableView({
    super.key,
    required this.columnDefs,
    required this.rows,
    required this.isSelected,
    required this.onSelectChanged,
  });

  @override
  State<TableView<TRow>> createState() => _TableView();
}

class _TableView<TRow> extends State<TableView<TRow>> {
  late List<TRow> _rows;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();

    _rows = widget.rows;
  }

  void onSort(int columnIndex, bool ascending) {
    final columnDef = widget.columnDefs[columnIndex];

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _rows = _rows.sortedByCompare(
        (value) => columnDef.getValue(value),
        (a, b) {
          if (a == null) return 1;
          if (b == null) return -1;

          return ascending ? a.compareTo(b) : b.compareTo(a);
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(fontWeight: FontWeight.bold);

    return SingleChildScrollable(
      scrollDirection: Axis.horizontal,
      primary: false,
      child: DataTable(
        headingRowHeight: 32,
        dataRowMinHeight: 32,
        dataRowMaxHeight: 32,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          for (final columnDef in widget.columnDefs)
            DataColumn(
              label: Text(
                columnDef.label,
                style: headerStyle,
              ),
              numeric: columnDef.isNumeric,
              onSort: onSort,
            ),
        ],
        rows: [
          for (final row in _rows)
            DataRow(
              key: ValueKey(row),
              selected: widget.isSelected(row),
              onSelectChanged: (selected) =>
                  widget.onSelectChanged(row, selected),
              cells: [
                for (final columnDef in widget.columnDefs)
                  DataCell(
                    columnDef.cellBuilder?.call(row) ??
                        Text(columnDef.getValue(row).toString()),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
