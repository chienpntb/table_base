import 'package:flutter/material.dart';
import 'table_model.dart';
import '../providers/table_state.dart';

/// Dữ liệu cột phân cấp - hỗ trợ cột cha và các cột con
class HierarchicalTableColumnData {
  final String name;
  final String key;
  final double width;
  final double flex;
  final FilterType? filterType;
  final bool isResizable;
  final bool isSortable;
  final bool isFilterable;
  final bool isConfigured;
  final bool isFixed;
  final bool isVisible;
  
  /// Danh sách các cột con
  final List<HierarchicalTableColumnData>? childColumns;
  
  /// Có thể collapse/expand không
  final bool isCollapsible;
  
  /// Trạng thái collapse mặc định
  final bool isCollapsedByDefault;

  HierarchicalTableColumnData({
    required this.name,
    required this.key,
    required this.width,
    this.flex = 0,
    this.filterType,
    this.isResizable = true,
    this.isSortable = true,
    this.isFilterable = true,
    this.isConfigured = true,
    this.isFixed = true,
    this.isVisible = true,
    this.childColumns,
    this.isCollapsible = false,
    this.isCollapsedByDefault = true,
  });

  /// Chuyển đổi thành TableColumnData thông thường
  TableColumnData toTableColumnData() {
    return TableColumnData(
      name: name,
      key: key,
      width: width,
      flex: flex,
      filterType: filterType,
      isResizable: isResizable,
      isSortable: isSortable,
      isFilterable: isFilterable,
      isConfigured: isConfigured,
      isFixed: isFixed,
      isVisible: isVisible,
    );
  }

  /// Tạo cột phân cấp với các cột con
  factory HierarchicalTableColumnData.withChildren({
    required String name,
    required String key,
    required double width,
    required List<HierarchicalTableColumnData> childColumns,
    double flex = 0,
    FilterType? filterType,
    bool isResizable = true,
    bool isSortable = true,
    bool isFilterable = true,
    bool isConfigured = true,
    bool isFixed = true,
    bool isVisible = true,
    bool isCollapsible = true,
    bool isCollapsedByDefault = true,
  }) {
    return HierarchicalTableColumnData(
      name: name,
      key: key,
      width: width,
      flex: flex,
      filterType: filterType,
      isResizable: isResizable,
      isSortable: isSortable,
      isFilterable: isFilterable,
      isConfigured: isConfigured,
      isFixed: isFixed,
      isVisible: isVisible,
      childColumns: childColumns,
      isCollapsible: isCollapsible,
      isCollapsedByDefault: isCollapsedByDefault,
    );
  }

  /// Tạo cột đơn giản (không có con)
  factory HierarchicalTableColumnData.simple({
    required String name,
    required String key,
    required double width,
    double flex = 0,
    FilterType? filterType,
    bool isResizable = true,
    bool isSortable = true,
    bool isFilterable = true,
    bool isConfigured = true,
    bool isFixed = true,
    bool isVisible = true,
  }) {
    return HierarchicalTableColumnData(
      name: name,
      key: key,
      width: width,
      flex: flex,
      filterType: filterType,
      isResizable: isResizable,
      isSortable: isSortable,
      isFilterable: isFilterable,
      isConfigured: isConfigured,
      isFixed: isFixed,
      isVisible: isVisible,
      isCollapsible: false,
    );
  }

  HierarchicalTableColumnData copyWith({
    String? name,
    String? key,
    double? width,
    double? flex,
    FilterType? filterType,
    bool? isResizable,
    bool? isSortable,
    bool? isFilterable,
    bool? isConfigured,
    bool? isFixed,
    bool? isVisible,
    List<HierarchicalTableColumnData>? childColumns,
    bool? isCollapsible,
    bool? isCollapsedByDefault,
  }) {
    return HierarchicalTableColumnData(
      name: name ?? this.name,
      key: key ?? this.key,
      width: width ?? this.width,
      flex: flex ?? this.flex,
      filterType: filterType ?? this.filterType,
      isResizable: isResizable ?? this.isResizable,
      isSortable: isSortable ?? this.isSortable,
      isFilterable: isFilterable ?? this.isFilterable,
      isConfigured: isConfigured ?? this.isConfigured,
      isFixed: isFixed ?? this.isFixed,
      isVisible: isVisible ?? this.isVisible,
      childColumns: childColumns ?? this.childColumns,
      isCollapsible: isCollapsible ?? this.isCollapsible,
      isCollapsedByDefault: isCollapsedByDefault ?? this.isCollapsedByDefault,
    );
  }
}

/// Dữ liệu hàng phân cấp - hỗ trợ hàng cha và các hàng con
class HierarchicalTableRowData {
  final List<TableCellData?> cells;
  final double? height;
  final bool isSelected;
  
  /// Có phải hàng cha không
  final bool isParentRow;
  
  /// Có thể collapse/expand không
  final bool isCollapsible;
  
  /// Trạng thái collapse hiện tại
  final bool isCollapsed;
  
  /// Danh sách các hàng con
  final List<HierarchicalTableRowData>? childRows;
  
  /// Mức độ phân cấp (0 = hàng cha, 1 = hàng con cấp 1, 2 = hàng con cấp 2, ...)
  final int hierarchyLevel;
  
  /// ID duy nhất của hàng để quản lý collapse/expand
  final String rowId;

  HierarchicalTableRowData({
    required this.cells,
    this.height,
    this.isSelected = false,
    this.isParentRow = false,
    this.isCollapsible = false,
    this.isCollapsed = true,
    this.childRows,
    this.hierarchyLevel = 0,
    required this.rowId,
  });

  /// Chuyển đổi thành TableRowData thông thường
  TableRowData toTableRowData() {
    return TableRowData(
      cells: cells,
      height: height,
      isSelected: isSelected,
    );
  }

  /// Tạo hàng cha với các hàng con
  factory HierarchicalTableRowData.parent({
    required List<TableCellData?> cells,
    required String rowId,
    required List<HierarchicalTableRowData> childRows,
    double? height,
    bool isSelected = false,
    bool isCollapsible = true,
    bool isCollapsedByDefault = true,
  }) {
    return HierarchicalTableRowData(
      cells: cells,
      height: height,
      isSelected: isSelected,
      isParentRow: true,
      isCollapsible: isCollapsible,
      isCollapsed: isCollapsedByDefault,
      childRows: childRows,
      hierarchyLevel: 0,
      rowId: rowId,
    );
  }

  /// Tạo hàng con
  factory HierarchicalTableRowData.child({
    required List<TableCellData?> cells,
    required String rowId,
    required int hierarchyLevel,
    double? height,
    bool isSelected = false,
  }) {
    return HierarchicalTableRowData(
      cells: cells,
      height: height,
      isSelected: isSelected,
      isParentRow: false,
      isCollapsible: false,
      isCollapsed: false,
      hierarchyLevel: hierarchyLevel,
      rowId: rowId,
    );
  }

  HierarchicalTableRowData copyWith({
    List<TableCellData?>? cells,
    double? height,
    bool? isSelected,
    bool? isParentRow,
    bool? isCollapsible,
    bool? isCollapsed,
    List<HierarchicalTableRowData>? childRows,
    int? hierarchyLevel,
    String? rowId,
  }) {
    return HierarchicalTableRowData(
      cells: cells ?? this.cells,
      height: height ?? this.height,
      isSelected: isSelected ?? this.isSelected,
      isParentRow: isParentRow ?? this.isParentRow,
      isCollapsible: isCollapsible ?? this.isCollapsible,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      childRows: childRows ?? this.childRows,
      hierarchyLevel: hierarchyLevel ?? this.hierarchyLevel,
      rowId: rowId ?? this.rowId,
    );
  }
}

/// Dữ liệu bảng phân cấp
class HierarchicalTableData {
  final List<HierarchicalTableRowData> rows;
  final List<double>? columnWidths;
  final double? defaultColumnWidth;
  final double? defaultRowHeight;
  final bool showAlternatingRowColors;
  final bool isConfigured;
  final Color? alternateColor;
  
  /// Map trạng thái collapse của các hàng cha
  final Map<String, bool> collapsedRows;

  HierarchicalTableData({
    required this.rows,
    this.columnWidths,
    this.defaultColumnWidth,
    this.defaultRowHeight,
    this.showAlternatingRowColors = false,
    this.isConfigured = false,
    this.alternateColor,
    this.collapsedRows = const {},
  });

  /// Chuyển đổi thành TableData thông thường với các hàng đã được flatten
  TableData toTableData() {
    final flattenedRows = <TableRowData>[];
    
    for (final row in rows) {
      _flattenRows(row, flattenedRows, collapsedRows);
    }
    
    return TableData(
      rows: flattenedRows,
      columnWidths: columnWidths,
      defaultColumnWidth: defaultColumnWidth,
      defaultRowHeight: defaultRowHeight,
      showAlternatingRowColors: showAlternatingRowColors,
      isConfigured: isConfigured,
      alternateColor: alternateColor,
    );
  }

  /// Đệ quy flatten các hàng để hiển thị
  void _flattenRows(
    HierarchicalTableRowData row,
    List<TableRowData> flattenedRows,
    Map<String, bool> collapsedRows,
  ) {
    // Thêm hàng hiện tại
    flattenedRows.add(row.toTableRowData());
    
    // Nếu là hàng cha và không bị collapse, thêm các hàng con
    if (row.isParentRow && 
        row.childRows != null && 
        !collapsedRows[row.rowId]!) {
      for (final childRow in row.childRows!) {
        _flattenRows(childRow, flattenedRows, collapsedRows);
      }
    }
  }

  HierarchicalTableData copyWith({
    List<HierarchicalTableRowData>? rows,
    List<double>? columnWidths,
    double? defaultColumnWidth,
    double? defaultRowHeight,
    bool? showAlternatingRowColors,
    bool? isConfigured,
    Color? alternateColor,
    Map<String, bool>? collapsedRows,
  }) {
    return HierarchicalTableData(
      rows: rows ?? this.rows,
      columnWidths: columnWidths ?? this.columnWidths,
      defaultColumnWidth: defaultColumnWidth ?? this.defaultColumnWidth,
      defaultRowHeight: defaultRowHeight ?? this.defaultRowHeight,
      showAlternatingRowColors: showAlternatingRowColors ?? this.showAlternatingRowColors,
      isConfigured: isConfigured ?? this.isConfigured,
      alternateColor: alternateColor ?? this.alternateColor,
      collapsedRows: collapsedRows ?? this.collapsedRows,
    );
  }
}
