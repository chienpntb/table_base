import 'package:flutter/material.dart';
import '../models/table_model.dart';

/// Widget bảng linh hoạt hỗ trợ nhiều tùy chọn hiển thị và tương tác
class FlexibleTable extends StatefulWidget {
  final TableData data; // Dữ liệu cho bảng
  final BoxDecoration? cellDecoration; // Trang trí cho ô dữ liệu thông thường
  final EdgeInsets cellPadding; // Khoảng cách lề bên trong ô
  final bool enableRowHover; // Bật hiệu ứng hover
  final Color? hoverColor; // Màu khi hover
  final Color? selectedRowColor; // Màu khi hover
  final Function(int)? onRowTap; // Callback khi nhấn vào hàng

  const FlexibleTable({
    super.key,
    required this.data,
    this.cellDecoration,
    this.cellPadding = const EdgeInsets.all(8.0),
    this.enableRowHover = false,
    this.hoverColor,
    this.selectedRowColor,
    this.onRowTap,
  });

  @override
  State<FlexibleTable> createState() => _FlexibleTableState();
}

class _FlexibleTableState extends State<FlexibleTable> {
  int? _hoveredRowIndex; // Lưu chỉ mục hàng đang được hover

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: _buildColumnWidths(),
      defaultColumnWidth:
          widget.data.defaultColumnWidth != null
              ? FixedColumnWidth(widget.data.defaultColumnWidth!)
              : const FlexColumnWidth(),
      children: _buildTableRows(),
    );
  }

  /// Tạo độ rộng cho từng cột
  Map<int, TableColumnWidth> _buildColumnWidths() {
    Map<int, TableColumnWidth> columnWidths = {};

    // Nếu có danh sách độ rộng cột
    if (widget.data.columnWidths != null &&
        widget.data.columnWidths!.isNotEmpty) {
      for (int i = 0; i < widget.data.columnWidths!.length; i++) {
        columnWidths[i] = FixedColumnWidth(widget.data.columnWidths![i]);
      }
    }
    // Nếu có độ rộng mặc định
    else if (widget.data.defaultColumnWidth != null) {
      // Tránh lỗi khi không có hàng dữ liệu
      if (widget.data.rows.isEmpty) {
        return columnWidths; // không đặt width cụ thể khi chưa biết số cột
      }
      for (int i = 0; i < widget.data.rows.first.cells.length; i++) {
        columnWidths[i] = FixedColumnWidth(widget.data.defaultColumnWidth!);
      }
    }

    return columnWidths;
  }

  /// Xây dựng các hàng cho bảng
  List<TableRow> _buildTableRows() {
    List<TableRow> tableRows = [];

    for (int rowIndex = 0; rowIndex < widget.data.rows.length; rowIndex++) {
      final rowData = widget.data.rows[rowIndex];
      final bool isHovered =
          _hoveredRowIndex == rowIndex; // Hàng đang được hover

      // Xác định màu nền cho hàng
      Color? rowBackgroundColor = _getRowBackgroundColor(
        rowData,
        rowIndex,
        isHovered,
      );

      List<Widget> rowCells = [];
      for (int colIndex = 0; colIndex < rowData.cells.length; colIndex++) {
        final cellData = rowData.cells[colIndex];

        if (cellData == null) {
          // Ô này đã bị phủ bởi một ô khác (colspan/rowspan), thêm widget trống
          rowCells.add(const SizedBox());
          continue;
        }

        // Tạo ô với decoration và padding
        Widget cellWidget = Container(
          padding: widget.cellPadding,
          height: rowData.height ?? widget.data.defaultRowHeight,
          child: Align(alignment: cellData.alignment, child: cellData.widget),
        );

        // Xử lý colspan và rowspan
        if (cellData.colSpan > 1 || cellData.rowSpan > 1) {
          cellWidget = TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: cellWidget,
          );
        }

        rowCells.add(cellWidget);
      }

      // Tạo decoration cho cell
      BoxDecoration? cellBoxDecoration = _getCellDecoration(
        rowData: rowData,
        backgroundColor: rowBackgroundColor,
      );

      // Tạo hàng với xử lý sự kiện
      TableRow tableRow = TableRow(
        decoration: cellBoxDecoration,
        children: rowCells,
      );

      // Thêm gesture detector nếu có sự kiện onTap hoặc bật hover
      if (widget.onRowTap != null || widget.enableRowHover) {
        tableRow = _wrapRowWithGestureDetector(
          tableRow,
          rowCells,
          rowIndex,
          rowData,
        );
      }

      tableRows.add(tableRow);
    }

    return tableRows;
  }

  /// Xác định màu nền cho hàng dựa trên các điều kiện
  Color? _getRowBackgroundColor(
    TableRowData rowData,
    int rowIndex,
    bool isHovered,
  ) {
    // Màu khi hover
    if (isHovered && widget.enableRowHover && widget.hoverColor != null) {
      return widget.hoverColor;
    }

    // Màu khi chọn hàng
    if (rowData.isSelected) {
      return widget.selectedRowColor;
    }

    // Màu khi xen kẽ
    if (widget.data.showAlternatingRowColors && rowIndex > 0) {
      if (rowIndex % 2 == 1 && widget.data.alternateColor != null) {
        return widget.data.alternateColor;
      }
    }

    return null; // Không có màu nền
  }

  /// Tạo BoxDecoration cho ô dựa trên các điều kiện
  BoxDecoration? _getCellDecoration({
    required TableRowData rowData,
    Color? backgroundColor,
  }) {
    // Nếu không, sử dụng decoration mặc định với màu nền
    BoxDecoration? baseDecoration = widget.cellDecoration;

    if (backgroundColor != null) {
      return BoxDecoration(
        color: backgroundColor,
        borderRadius: baseDecoration?.borderRadius,
        border: baseDecoration?.border,
        boxShadow: baseDecoration?.boxShadow,
        gradient: baseDecoration?.gradient,
      );
    }

    return baseDecoration;
  }

  /// Bọc hàng với các tính năng tương tác (hover và tap)
  TableRow _wrapRowWithGestureDetector(
    TableRow tableRow,
    List<Widget> rowCells,
    int rowIndex,
    TableRowData rowData,
  ) {
    List<Widget> wrappedCells =
        rowCells.map((cell) {
          Widget cellWidget = cell;

          // Thêm MouseRegion nếu cần hiệu ứng hover
          if (widget.enableRowHover) {
            cellWidget = MouseRegion(
              onEnter: (_) {
                setState(() {
                  _hoveredRowIndex = rowIndex;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoveredRowIndex = null;
                });
              },
              child: cellWidget,
            );
          }

          // Thêm GestureDetector nếu có sự kiện onTap
          if (widget.onRowTap != null) {
            cellWidget = GestureDetector(
              onTap: () {
                if (widget.onRowTap != null) {
                  widget.onRowTap!(rowIndex);
                }
              },
              child: cellWidget,
            );
          }

          return cellWidget;
        }).toList();

    return TableRow(decoration: tableRow.decoration, children: wrappedCells);
  }
}