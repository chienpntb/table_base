import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/expandable_table_model.dart';

/// Widget hiển thị table con với column alignment và resize capability
class ChildTableWidget<C> extends StatefulWidget {
  final List<C> childData;
  final List<TableColumnData> childColumns;
  final List<TableColumnData> parentColumns;
  final String? title;
  final double? maxHeight;
  final EdgeInsets? padding;
  final ChildCellBuilder<C>? childCellBuilder;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double rowHeight;
  final EdgeInsets cellPadding;
  final Map<String, double>? parentColumnWidths;

  const ChildTableWidget({
    super.key,
    required this.childData,
    required this.childColumns,
    required this.parentColumns,
    this.title,
    this.maxHeight,
    this.padding,
    this.childCellBuilder,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.rowHeight = 40.0,
    this.cellPadding = const EdgeInsets.all(8.0),
    this.parentColumnWidths,
  });

  @override
  State<ChildTableWidget<C>> createState() => _ChildTableWidgetState<C>();
}

class _ChildTableWidgetState<C> extends State<ChildTableWidget<C>> {
  Map<String, double> columnWidths = {};

  @override
  void initState() {
    super.initState();
    _initializeColumnWidths();
  }

  @override
  void didUpdateWidget(ChildTableWidget<C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.parentColumnWidths != oldWidget.parentColumnWidths) {
      _initializeColumnWidths();
    }
  }

  void _initializeColumnWidths() {
    columnWidths.clear();
    
    for (int i = 0; i < widget.childColumns.length; i++) {
      final column = widget.childColumns[i];
      
      // Ưu tiên sử dụng width từ column definition trước
      // Chỉ fallback về parent column width nếu column.width không được set
      if (column.width > 0) {
        // Sử dụng width từ column definition
        columnWidths[column.key] = column.width;
      } else if (widget.parentColumnWidths != null && i < widget.parentColumns.length) {
        // Fallback về parent column width nếu column.width = 0
        final parentColumn = widget.parentColumns[i];
        if (widget.parentColumnWidths!.containsKey(parentColumn.key)) {
          columnWidths[column.key] = widget.parentColumnWidths![parentColumn.key]!;
        } else {
          columnWidths[column.key] = column.width;
        }
      } else {
        columnWidths[column.key] = column.width;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.childData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.padding ?? const EdgeInsets.only(left: 20, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.yellow.shade50,
        border: Border.all(
          color: widget.borderColor ?? Colors.grey.shade300,
          width: widget.borderWidth,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) _buildTitle(),
          _buildChildTable(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Text(
        widget.title!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildChildTable() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? 200,
        minHeight: 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          columnWidths: _buildColumnWidths(),
          children: _buildTableRows(),
        ),
      ),
    );
  }

  /// Tạo column widths cho child table
  Map<int, TableColumnWidth> _buildColumnWidths() {
    final columnWidths = <int, TableColumnWidth>{};
    
    for (int i = 0; i < widget.childColumns.length; i++) {
      final column = widget.childColumns[i];
      final width = this.columnWidths[column.key] ?? column.width;
      columnWidths[i] = FixedColumnWidth(width);
    }
    
    return columnWidths;
  }

  /// Tạo table rows cho child table
  List<TableRow> _buildTableRows() {
    final rows = <TableRow>[];
    
    // Header row
    final headerCells = <Widget>[];
    for (final column in widget.childColumns) {
      headerCells.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            column.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    rows.add(TableRow(children: headerCells));
    
    // Data rows
    for (final childItem in widget.childData) {
      final rowCells = <Widget>[];
      
      for (final column in widget.childColumns) {
        TableCellData? cellData;
        if (widget.childCellBuilder != null) {
          cellData = widget.childCellBuilder!(childItem, column.key);
        }
        
        if (cellData == null) {
          final defaultValue = _getDefaultValue(childItem, column.key);
          cellData = TableCellData(
            widget: Text(
              defaultValue,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
        
        rowCells.add(
          Container(
            padding: widget.cellPadding,
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 0.5,
              ),
            ),
            child: cellData.widget,
          ),
        );
      }
      
      rows.add(TableRow(children: rowCells));
    }
    
    return rows;
  }


  /// Lấy giá trị mặc định cho cell
  String _getDefaultValue(C childItem, String columnKey) {
    try {
      // Thử lấy giá trị từ object bằng reflection
      final dynamic item = childItem;
      if (item is Map) {
        return item[columnKey]?.toString() ?? '';
      }
      
      // Thử sử dụng dynamic access
      final dynamic value = (item as dynamic)[columnKey];
      print('_getDefaultValue for $columnKey: $value');
      return value?.toString() ?? '';
    } catch (e) {
      print('_getDefaultValue error for $columnKey: $e');
      return '';
    }
  }
}

/// Model cho column alignment
class AlignedColumn {
  final TableColumnData childColumn;
  final TableColumnData? parentColumn;
  final ColumnAlignment alignment;

  const AlignedColumn({
    required this.childColumn,
    this.parentColumn,
    required this.alignment,
  });
}

/// Enum cho column alignment
enum ColumnAlignment {
  aligned,    // Cột con align với cột cha
  standalone, // Cột con độc lập
}
