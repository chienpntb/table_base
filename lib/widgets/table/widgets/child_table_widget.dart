import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/expandable_table_model.dart';
import 'flexible_table.dart';

/// Widget hiển thị table con với column alignment
class ChildTableWidget<C> extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    if (childData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity, // Đảm bảo container chiếm full width
      margin: padding ?? const EdgeInsets.only(left: 20, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.yellow.shade50,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade300,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Đảm bảo children chiếm full width
        children: [
          if (title != null) _buildTitle(),
          _buildChildTable(), // Sử dụng Flexible cho child table
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity, // Chiếm toàn bộ width có sẵn
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Text(
        title!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis, // Cắt text nếu quá dài
        maxLines: 1, // Chỉ hiển thị 1 dòng
      ),
    );
  }

  Widget _buildChildTable() {
    // Tính toán column alignment
    final alignedColumns = _calculateColumnAlignment();
    
    // Tạo table data cho child table
    final childTableData = _createChildTableData(alignedColumns);
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? 200,
        minHeight: 0,
      ),
      child: SingleChildScrollView(
        child: FlexibleTable(
          data: childTableData,
          cellPadding: cellPadding,
          cellDecoration: BoxDecoration(
            color: Colors.yellow.shade50,
            border: Border.all(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  /// Tính tổng width của child table
  double _calculateTotalWidth(List<AlignedColumn> alignedColumns) {
    double totalWidth = 0;
    for (int i = 0; i < childColumns.length; i++) {
      double columnWidth = 120.0; // Default width
      
      if (i < parentColumns.length) {
        // Sử dụng width từ parent nhưng đảm bảo tối thiểu
        columnWidth = parentColumns[i].width > 0 ? parentColumns[i].width : 120.0;
      }
      
      totalWidth += columnWidth;
    }
    
    // Đảm bảo width tối thiểu 300px
    return totalWidth < 300 ? 300 : totalWidth;
  }

  /// Tính toán alignment của columns giữa parent và child table
  List<AlignedColumn> _calculateColumnAlignment() {
    final alignedColumns = <AlignedColumn>[];
    
    for (int i = 0; i < childColumns.length; i++) {
      final childColumn = childColumns[i];
      
      // Tìm parent column tương ứng dựa trên vị trí
      TableColumnData? parentColumn;
      if (i < parentColumns.length) {
        parentColumn = parentColumns[i];
      }
      
      alignedColumns.add(AlignedColumn(
        childColumn: childColumn,
        parentColumn: parentColumn,
        alignment: parentColumn != null ? ColumnAlignment.aligned : ColumnAlignment.standalone,
      ));
    }
    
    return alignedColumns;
  }

  /// Tạo TableData cho child table
  TableData _createChildTableData(List<AlignedColumn> alignedColumns) {
    final rows = <TableRowData>[];
    
    // Tạo header row
    final headerCells = <TableCellData?>[];
    for (final alignedColumn in alignedColumns) {
      headerCells.add(
        TableCellData(
          widget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              alignedColumn.childColumn.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }
    rows.add(TableRowData(cells: headerCells));
    
    // Tạo data rows
    for (final childItem in childData) {
      final rowCells = <TableCellData?>[];
      
      for (int i = 0; i < childColumns.length; i++) {
        final column = childColumns[i];
        
        TableCellData? cellData;
        if (childCellBuilder != null) {
          cellData = childCellBuilder!(childItem, column.key);
        }
        
        if (cellData == null) {
          // Fallback: hiển thị giá trị mặc định
          cellData = TableCellData(
            widget: Text(
              _getDefaultValue(childItem, column.key),
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
        
        rowCells.add(cellData);
      }
      
      rows.add(TableRowData(
        cells: rowCells,
        height: rowHeight,
      ));
    }
    
    // Tính column widths dựa trên parent columns với width tối thiểu
    final columnWidths = <double>[];
    for (int i = 0; i < childColumns.length; i++) {
      double columnWidth = 120.0; // Default width
      
      if (i < parentColumns.length) {
        // Sử dụng width từ parent nhưng đảm bảo tối thiểu 120px
        columnWidth = parentColumns[i].width > 0 ? parentColumns[i].width : 120.0;
        columnWidth = columnWidth < 120.0 ? 120.0 : columnWidth;
      }
      
      columnWidths.add(columnWidth);
    }
    
    return TableData(
      rows: rows,
      columnWidths: columnWidths,
      showAlternatingRowColors: false,
    );
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
      return value?.toString() ?? '';
    } catch (e) {
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
