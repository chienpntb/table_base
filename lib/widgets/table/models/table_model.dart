import 'package:flutter/material.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';

class TableCellData {
  final Widget widget;
  final int rowSpan;
  final int colSpan;
  final Alignment alignment;

  TableCellData({
    required this.widget,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.alignment = Alignment.center,
  });
}

class TableRowData {
  final List<TableCellData?> cells;
  final double? height;
  final bool isSelected;
  final bool isNestedTable;

  TableRowData({
    required this.cells, 
    this.height, 
    this.isSelected = false,
    this.isNestedTable = false,
  });
}

class TableData {
  final List<TableRowData> rows;
  final List<double>? columnWidths;
  final double? defaultColumnWidth;
  final double? defaultRowHeight;
  final bool showAlternatingRowColors;
  final bool isConfigured;
  final Color? alternateColor;

  TableData({
    required this.rows,
    this.columnWidths,
    this.defaultColumnWidth,
    this.defaultRowHeight,
    this.showAlternatingRowColors = false,
    this.isConfigured = false,
    this.alternateColor,
  });
}

class TableColumnData {
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

  TableColumnData({
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
  });

  TableColumnData copyWith({
    String? name,
    String? key,
    double? width,
    FilterType? filterType,
    double? flex,
    List<dynamic>? customSelectValues,
    bool? isResizable,
    bool? isSortable,
    bool? isFilterable,
    bool? isConfigured,
    bool? isFixed,
    bool? isVisible,
  }) {
    return TableColumnData(
      name: name ?? this.name,
      key: key ?? this.key,
      width: width ?? this.width,
      filterType: filterType ?? this.filterType,
      flex: flex ?? this.flex,
      isResizable: isResizable ?? this.isResizable,
      isSortable: isSortable ?? this.isSortable,
      isFilterable: isFilterable ?? this.isFilterable,
      isConfigured: isConfigured ?? this.isConfigured,
      isFixed: isFixed ?? this.isFixed,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  /// Tạo TableColumnData đơn giản chỉ với tên và chiều rộng
  factory TableColumnData.simple({
    required String name,
    required String key,
    required double width,
    double flex = 0,
    bool isConfigured = true,
    bool isFixed = true,
    bool isVisible = true,
  }) {
    return TableColumnData(
      name: name,
      key: key,
      width: width,
      flex: flex,
      isConfigured: isConfigured,
      isFixed: isFixed,
      isVisible: isVisible,
    );
  }

  /// Tạo TableColumnData với FilterType.select và customSelectValues
  factory TableColumnData.select({
    required String name,
    required String key,
    required double width,
    double flex = 0,
    bool isResizable = true,
    bool isSortable = true,
    bool isFilterable = true,
    bool isConfigured = true,
    bool isFixed = true,
    bool isVisible = true,
  }) {
    return TableColumnData(
      name: name,
      key: key,
      width: width,
      filterType: FilterType.select,
      flex: flex,
      isResizable: isResizable,
      isSortable: isSortable,
      isFilterable: isFilterable,
      isConfigured: isConfigured,
      isFixed: isFixed,
      isVisible: isVisible,
    );
  }

  /// Tạo TableColumnData với FilterType cụ thể
  factory TableColumnData.withFilter({
    required String name,
    required String key,
    required double width,
    required FilterType filterType,
    double flex = 0,
    bool isResizable = true,
    bool isSortable = true,
    bool isFilterable = true,
    bool isConfigured = true,
    bool isFixed = true,
    bool isVisible = true,
  }) {
    return TableColumnData(
      name: name,
      key: key,
      width: width,
      filterType: filterType,
      flex: flex,
      isResizable: isResizable,
      isSortable: isSortable,
      isFilterable: isFilterable,
      isConfigured: isConfigured,
      isFixed: isFixed,
      isVisible: isVisible,
    );
  }
}
