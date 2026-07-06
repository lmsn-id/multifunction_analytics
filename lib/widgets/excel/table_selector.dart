import 'package:flutter/material.dart';
import 'package:worksheet/worksheet.dart';

class TableSelector extends StatefulWidget {
  final List<List<dynamic>> data;
  final List<String> headers;
  final Function(int startRow, int endRow, int startCol, int endCol)
  onSelectionChanged;

  const TableSelector({
    super.key,
    required this.data,
    required this.headers,
    required this.onSelectionChanged,
  });

  @override
  TableSelectorState createState() => TableSelectorState();
}

class TableSelectorState extends State<TableSelector> {
  late final WorksheetController _controller;
  late final SparseWorksheetData _sheetData;

  late final int _rows;
  late final int _cols;

  static const _headerStyle = CellStyle(
    textAlignment: CellTextAlignment.center,
    verticalAlignment: CellVerticalAlignment.middle,
  );

  @override
  void initState() {
    super.initState();

    _rows = widget.data.length;
    _cols = widget.headers.length;

    _controller = WorksheetController();
    _sheetData = _buildSheetData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.selectionController.addListener(_handleSelectionChanged);
    });
  }

  SparseWorksheetData _buildSheetData() {
    final cells = <(int, int), Cell>{};

    for (var c = 0; c < widget.headers.length; c++) {
      cells[(0, c)] = Cell.text(widget.headers[c], style: _headerStyle);
    }

    // Data cells
    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        if (c >= widget.data[r].length) continue;

        final value = widget.data[r][c];
        if (value != null) {
          cells[(r + 1, c)] = Cell.text(
            value.toString(),
            style: const CellStyle(
              textAlignment: CellTextAlignment.center,
              verticalAlignment: CellVerticalAlignment.middle,
            ),
          );
        }
      }
    }

    return SparseWorksheetData(
      rowCount: _rows + 1,
      columnCount: _cols,
      cells: cells,
    );
  }

  void _handleSelectionChanged() {
    final range = _controller.selectedRange;
    if (range == null) return;

    if (range.endRow < 1) return;

    final startRow = (range.startRow - 1).clamp(0, _rows - 1);
    final endRow = (range.endRow - 1).clamp(0, _rows - 1);

    widget.onSelectionChanged(
      startRow,
      endRow,
      range.startColumn,
      range.endColumn,
    );
  }

  void resetSelection() {
    _controller.clearSelection();
  }

  @override
  void dispose() {
    _controller.selectionController.removeListener(_handleSelectionChanged);
    _sheetData.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final worksheetTheme = isDark
        ? WorksheetThemeData.darkTheme
        : WorksheetThemeData.defaultTheme;

    return SizedBox(
      width: double.infinity,
      height: 500,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        ),
        clipBehavior: Clip.antiAlias,
        child: WorksheetTheme(
          data: worksheetTheme,
          child: Worksheet(
            controller: _controller,
            data: _sheetData,
            rowCount: _rows + 1,
            columnCount: _cols,
          ),
        ),
      ),
    );
  }
}
