import 'package:flutter/material.dart';
import 'table_model.dart';

/// Model cho dữ liệu có thể expand
class ExpandableTableData<T, C> {
  final T parentData;
  final List<C>? childData;
  final bool isExpanded;
  final String? childTableTitle;
  final List<TableColumnData>? childColumns;

  const ExpandableTableData({
    required this.parentData,
    this.childData,
    this.isExpanded = false,
    this.childTableTitle,
    this.childColumns,
  });

  ExpandableTableData<T, C> copyWith({
    T? parentData,
    List<C>? childData,
    bool? isExpanded,
    String? childTableTitle,
    List<TableColumnData>? childColumns,
  }) {
    return ExpandableTableData<T, C>(
      parentData: parentData ?? this.parentData,
      childData: childData ?? this.childData,
      isExpanded: isExpanded ?? this.isExpanded,
      childTableTitle: childTableTitle ?? this.childTableTitle,
      childColumns: childColumns ?? this.childColumns,
    );
  }
}

/// Model cho row có thể expand
class ExpandableTableRowData {
  final List<TableCellData?> cells;
  final double? height;
  final bool isSelected;
  final bool isExpanded;
  final bool hasChildren;
  final Widget? childTableWidget;

  const ExpandableTableRowData({
    required this.cells,
    this.height,
    this.isSelected = false,
    this.isExpanded = false,
    this.hasChildren = false,
    this.childTableWidget,
  });

  ExpandableTableRowData copyWith({
    List<TableCellData?>? cells,
    double? height,
    bool? isSelected,
    bool? isExpanded,
    bool? hasChildren,
    Widget? childTableWidget,
  }) {
    return ExpandableTableRowData(
      cells: cells ?? this.cells,
      height: height ?? this.height,
      isSelected: isSelected ?? this.isSelected,
      isExpanded: isExpanded ?? this.isExpanded,
      hasChildren: hasChildren ?? this.hasChildren,
      childTableWidget: childTableWidget ?? this.childTableWidget,
    );
  }
}

/// Model cho dữ liệu table con
class ChildTableData<C> {
  final List<C> data;
  final List<TableColumnData> columns;
  final String? title;
  final double? maxHeight;
  final EdgeInsets? padding;

  const ChildTableData({
    required this.data,
    required this.columns,
    this.title,
    this.maxHeight,
    this.padding,
  });
}

/// Callback để tạo widget cho table con
typedef ChildTableBuilder<C> = Widget Function(
  List<C> childData,
  List<TableColumnData> childColumns,
  String? title,
);

/// Callback để lấy dữ liệu con từ dữ liệu cha
typedef ChildDataGetter<T, C> = List<C>? Function(T parentData);

/// Callback để tạo cell cho dữ liệu con
typedef ChildCellBuilder<C> = TableCellData? Function(C childItem, String columnKey);
