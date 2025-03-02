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
  final int selectedRowCount;

  const TableView({
    super.key,
    required this.columnDefs,
    required this.rows,
    required this.isSelected,
    required this.onSelectChanged,
    required this.selectedRowCount,
  });

  @override
  State<TableView<TRow>> createState() => TableViewState();
}

class _DataTableListSource<TRow> extends DataTableSource {
  List<TRow> rows;
  final TableView<TRow> widget;

  _DataTableListSource({
    required this.rows,
    required this.widget,
  });

  @override
  DataRow? getRow(int index) {
    final row = rows[index];

    return DataRow.byIndex(
      index: index,
      selected: widget.isSelected(row),
      onSelectChanged: (selected) {
        widget.onSelectChanged(row, selected);
        notifyListeners();
      },
      cells: [
        for (final columnDef in widget.columnDefs)
          DataCell(
            columnDef.cellBuilder?.call(row) ??
                Text(columnDef.getValue(row).toString()),
          ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => widget.selectedRowCount;

  void filter(
    List<TRow> Function(List<TRow> rows) filter,
    int? sortColumnIndex,
    bool sortAscending,
  ) {
    rows = filter(widget.rows);

    if (sortColumnIndex == null) {
      notifyListeners();
      return;
    }

    sort(sortColumnIndex, sortAscending);
  }

  void sort(int columnIndex, bool ascending) {
    final columnDef = widget.columnDefs[columnIndex];

    rows = rows.sortedByCompare(
      (value) => columnDef.getValue(value),
      (a, b) {
        if (a == null) return 1;
        if (b == null) return -1;

        return ascending ? a.compareTo(b) : b.compareTo(a);
      },
    );
    notifyListeners();
  }
}

class TableViewState<TRow> extends State<TableView<TRow>> {
  late _DataTableListSource<TRow> _source;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();

    _source = _DataTableListSource(
      rows: widget.rows,
      widget: widget,
    );
  }

  void onFilter(List<TRow> Function(List<TRow> rows) filter) {
    _source.filter(filter, _sortColumnIndex, _sortAscending);
  }

  void onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _source.sort(columnIndex, ascending);
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(fontWeight: FontWeight.bold);

    return PaginatedDataTable(
      source: _source,
      primary: false,
      headingRowHeight: 32,
      dataRowMinHeight: 32,
      dataRowMaxHeight: 32,
      columnSpacing: 24,
      rowsPerPage: 20,
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
    );
  }
}
