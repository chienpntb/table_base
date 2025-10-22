// ignore_for_file: deprecated_member_use

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
  final Color? parentHeaderColor; // Màu header của table cha
  final Color? rowDividerColor;   // Màu đường phân cách giữa các hàng
  final double rowDividerThickness; // Độ dày đường phân cách
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
    this.parentHeaderColor,
    this.rowDividerColor,
    this.rowDividerThickness = 0.5,
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
      // Không đặt left margin để tránh tràn ngang; phần thụt lề (nếu cần)
      // nên xử lý ở cấp cha bằng một cột riêng hoặc padding của cell chứa.
      margin: padding ?? const EdgeInsets.only(top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade50,
        border: Border.all(
          color: borderColor ?? Colors.grey.shade200,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Đảm bảo children chiếm full width
        children: [
          // if (title != null) _buildTitle(),
          _buildChildTable(), // Sử dụng Flexible cho child table
        ],
      ),
    );
  }

  // Widget _buildTitle() {
  //   return Container(
  //     width: double.infinity, // Chiếm toàn bộ width có sẵn
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: _getChildHeaderColor(),
  //       borderRadius: const BorderRadius.only(
  //         topLeft: Radius.circular(6),
  //         topRight: Radius.circular(6),
  //       ),
  //       border: Border(
  //         bottom: BorderSide(
  //           color: rowDividerColor ?? Colors.grey.shade300,
  //           width: rowDividerThickness,
  //         ),
  //       ),
  //     ),
  //     child: Text(
  //       title!,
  //       style: TextStyle(
  //         fontWeight: FontWeight.w600,
  //         fontSize: 13,
  //         color: Colors.grey.shade800,
  //       ),
  //       overflow: TextOverflow.ellipsis, // Cắt text nếu quá dài
  //       maxLines: 1, // Chỉ hiển thị 1 dòng
  //     ),
  //   );
  // }

  Widget _buildChildTable() {
    // Tính toán column alignment
    final alignedColumns = _calculateColumnAlignment();

    // Sử dụng LayoutBuilder để biết được chiều rộng khả dụng của parent,
    // sau đó mở rộng (scale) các độ rộng cột để child table chiếm toàn bộ bề ngang
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Tạo dữ liệu bảng với danh sách width đã được điều chỉnh theo availableWidth
        final adjustedColumnWidths = _computeFittedColumnWidths(availableWidth);
        final childTableData = _createChildTableData(
          alignedColumns,
          overrideColumnWidths: adjustedColumnWidths,
        );

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? 200,
            minHeight: 0,
          ),
          child: SingleChildScrollView(
            child: FlexibleTable(
              data: childTableData,
              cellPadding: cellPadding,
              // Thêm đường kẻ nhỏ giữa các hàng bằng border bottom cho mỗi ô
              cellDecoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: rowDividerColor ?? Colors.grey.shade200,
                    width: rowDividerThickness,
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
  TableData _createChildTableData(
    List<AlignedColumn> alignedColumns, {
    List<double>? overrideColumnWidths,
  }) {
    final rows = <TableRowData>[];
    
    // Tạo header row
    final headerCells = <TableCellData?>[];
    for (final alignedColumn in alignedColumns) {
      headerCells.add(
        TableCellData(
          widget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _getChildHeaderColor(),
              border: Border(
                bottom: BorderSide(color: rowDividerColor ?? Colors.grey.shade200, width: rowDividerThickness),
              ),
            ),
            child: Text(
              alignedColumn.childColumn.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey.shade800,
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
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
    
    // Tính column widths dựa trên parent columns với width tối thiểu,
    // sau đó có thể bị ghi đè bởi danh sách đã được fit theo parent width
    final columnWidths = <double>[];
    if (overrideColumnWidths != null && overrideColumnWidths.length == childColumns.length) {
      columnWidths.addAll(overrideColumnWidths);
    } else {
      for (int i = 0; i < childColumns.length; i++) {
        double columnWidth = 120.0; // Default width
        
        if (i < parentColumns.length) {
          // Sử dụng width từ parent nhưng đảm bảo tối thiểu 120px
          columnWidth = parentColumns[i].width > 0 ? parentColumns[i].width : 120.0;
          columnWidth = columnWidth < 120.0 ? 120.0 : columnWidth;
        }
        
        columnWidths.add(columnWidth);
      }
    }
    
    return TableData(
      rows: rows,
      columnWidths: columnWidths,
      showAlternatingRowColors: false,
    );
  }

  /// Tính danh sách độ rộng cột đã được scale để vừa với chiều rộng khả dụng của parent
  List<double> _computeFittedColumnWidths(double availableWidth) {
    // Tạo danh sách width cơ sở từ parent columns (tối thiểu 120)
    final baseWidths = <double>[];
    for (int i = 0; i < childColumns.length; i++) {
      double columnWidth = 120.0;
      if (i < parentColumns.length) {
        columnWidth = parentColumns[i].width > 0 ? parentColumns[i].width : 120.0;
        if (columnWidth < 120.0) columnWidth = 120.0;
      }
      baseWidths.add(columnWidth);
    }

    // Nếu tổng width đã >= availableWidth thì giữ nguyên
    final totalBaseWidth = baseWidths.fold<double>(0, (sum, w) => sum + w);
    if (availableWidth.isInfinite || availableWidth <= 0 || totalBaseWidth <= 0) {
      return baseWidths;
    }

    if (totalBaseWidth >= availableWidth) {
      return baseWidths;
    }

    // Scale theo tỉ lệ để chiếm hết availableWidth
    final scale = availableWidth / totalBaseWidth;
    return baseWidths.map((w) => w * scale).toList(growable: false);
  }

  /// Tạo màu header cho table con dựa trên màu header của table cha nhưng mờ hơn
  Color _getChildHeaderColor() {
    final base = parentHeaderColor ?? Colors.grey.shade300;
    return base.withOpacity(0.8);
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
