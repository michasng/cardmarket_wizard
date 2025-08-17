import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class ColumnDef<TRow> {
  final String label;
  final bool isNumeric;
  final Comparable<dynamic>? Function(TRow row) getValue;
  final Widget? Function(TRow row)? cellBuilder;

  const ColumnDef({
    required this.label,
    this.isNumeric = false,
    required this.getValue,
    this.cellBuilder,
  });
}

abstract interface class TableRow {
  bool get selected;
}

class TableView<TRow extends TableRow> extends StatefulWidget {
  final List<ColumnDef<TRow>> columnDefs;
  final List<TRow> rows;
  final bool Function(TRow row)? initialFilter;
  final void Function(TRow row)? onToggleRowSelected;

  const TableView({
    super.key,
    required this.columnDefs,
    required this.rows,
    this.initialFilter,
    this.onToggleRowSelected,
  });

  @override
  State<TableView<TRow>> createState() => TableViewState();
}

typedef ColumnSort = (int columnIndex, bool isAscending);

class _DataTableListSource<TRow extends TableRow> extends DataTableSource {
  TableView<TRow> widget;
  bool Function(TRow row) _filter;
  final List<ColumnSort> _columnSorts = [];
  late List<TRow> computedRows;

  _DataTableListSource({required this.widget})
    : _filter = widget.initialFilter ?? ((row) => true) {
    computeRows();
  }

  @override
  DataRow? getRow(int index) {
    final row = computedRows[index];

    return DataRow.byIndex(
      index: index,
      selected: row.selected,
      onSelectChanged: widget.onToggleRowSelected == null
          ? null
          : (selected) {
              widget.onToggleRowSelected!(row);
            },
      cells: [
        for (final columnDef in widget.columnDefs)
          DataCell(
            columnDef.cellBuilder?.call(row) ??
                (columnDef.getValue(row) == null
                    ? Container()
                    : Text(columnDef.getValue(row).toString())),
          ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => computedRows.length;

  @override
  int get selectedRowCount => computedRows.where((row) => row.selected).length;

  void computeRows() {
    computedRows = widget.rows.where(_filter).toList();

    for (final (columnIndex, isAscending) in _columnSorts) {
      final columnDef = widget.columnDefs[columnIndex];

      computedRows = computedRows.sortedByCompare(
        (row) => columnDef.getValue(row),
        (a, b) {
          if (a == null) return 1;
          if (b == null) return -1;

          return isAscending ? a.compareTo(b) : b.compareTo(a);
        },
      );
    }

    notifyListeners();
  }

  void setFilter(bool Function(TRow row) filter) {
    _filter = filter;
    computeRows();
  }

  void addColumnSort(int columnIndex, bool isAscending) {
    _columnSorts.add((columnIndex, isAscending));
    computeRows();
  }
}

class TableViewState<TRow extends TableRow> extends State<TableView<TRow>> {
  final _paginatedDataTableKey = GlobalKey<PaginatedDataTableState>();
  late _DataTableListSource<TRow> _source;
  int? _sortColumnIndex;
  bool _sortIsAscending = true;

  @override
  void initState() {
    super.initState();

    _source = _DataTableListSource(widget: widget);
  }

  @override
  void didUpdateWidget(covariant TableView<TRow> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rows != widget.rows) {
      _source.widget = widget;
      _source.computeRows();
    }
  }

  void onFilter(bool Function(TRow row) filter) {
    _source.setFilter(filter);
    _paginatedDataTableKey.currentState?.pageTo(0);
  }

  void onSort(int columnIndex, bool isAscending) {
    _source.addColumnSort(columnIndex, isAscending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortIsAscending = isAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(fontWeight: FontWeight.bold);

    return PaginatedDataTable(
      key: _paginatedDataTableKey,
      source: _source,
      primary: false,
      headingRowHeight: 32,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 32,
      columnSpacing: 24,
      rowsPerPage: 20,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortIsAscending,
      columns: [
        for (final columnDef in widget.columnDefs)
          DataColumn(
            label: Text(columnDef.label, style: headerStyle),
            numeric: columnDef.isNumeric,
            onSort: onSort,
          ),
      ],
    );
  }
}
