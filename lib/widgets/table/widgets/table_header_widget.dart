import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import '../models/table_model.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';
import 'table_header_cell_widget.dart';

/// Widget hiển thị header của bảng với các tính năng:
/// - Sắp xếp cột
/// - Lọc dữ liệu
/// - Resize cột
/// - Checkbox chọn tất cả
class TableHeaderWidget<T> extends ConsumerWidget {
  /// Danh sách cấu hình các cột
  final List<TableColumnData> columns;

  /// Map chứa độ rộng đã tính của các cột
  final Map<String, double> computedWidths;

  /// Provider để quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;

  /// Controller cuộn ngang cho header
  final ScrollController headerController;

  /// Chiều cao của header
  final double headerHeight;

  /// Màu nền header
  final Color? headerColor;

  /// Màu text header
  final Color textHeaderColor;

  /// Cho phép resize cột
  final bool enableColumnResize;

  /// Hiển thị cột checkbox
  final bool showCheckboxColumn;

  /// Hiển thị cột actions
  final bool showActionsColumn;

  /// Chiều rộng cột actions
  final double actionsColumnWidth;

  /// Số lượng hiển thị tối đa cho filter
  final int showPageSizeFilter;

  /// Callback khi sắp xếp cột
  final void Function(int) onSort;

  /// Callback hiển thị menu lọc
  final Future<void> Function(String, int, Offset) onShowFilterMenu;

  /// Callback khi hover cột
  final void Function(int) onColumnHover;

  /// Callback khi không hover cột
  final void Function() onColumnHoverExit;

  /// Chỉ số cột đang được hover
  final int hoveredColumnIndex;

  /// Có đang resize cột không
  final bool isResizing;

  /// Callback khi bắt đầu resize
  final void Function(int, double) onStartResizing;

  /// Callback khi cập nhật preview width
  final void Function(double) onUpdatePreviewWidth;

  /// Callback khi kết thúc resize
  final void Function() onFinishResizing;

  const TableHeaderWidget({
    super.key,
    required this.columns,
    required this.computedWidths,
    required this.tableProvider,
    required this.headerController,
    required this.headerHeight,
    required this.textHeaderColor,
    required this.onSort,
    required this.onShowFilterMenu,
    required this.onColumnHover,
    required this.onColumnHoverExit,
    required this.hoveredColumnIndex,
    required this.isResizing,
    required this.onStartResizing,
    required this.onUpdatePreviewWidth,
    required this.onFinishResizing,
    this.headerColor,
    this.enableColumnResize = true,
    this.showCheckboxColumn = true,
    this.showActionsColumn = false,
    this.actionsColumnWidth = 120,
    this.showPageSizeFilter = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: headerController,
      child: Container(
        color: headerColor ?? AppColor.greenLight,
        child: Row(
          children: List.generate(columns.length, (index) {
            final column = columns[index];
            final width = computedWidths[column.key] ?? column.width;
            return TableHeaderCellWidget<T>(
              column: column,
              columnIndex: index,
              width: width,
              isLastColumn: index == columns.length - 1,
              tableProvider: tableProvider,
              headerHeight: headerHeight,
              textHeaderColor: textHeaderColor,
              enableColumnResize: enableColumnResize,
              showCheckboxColumn: showCheckboxColumn,
              showActionsColumn: showActionsColumn,
              actionsColumnWidth: actionsColumnWidth,
              showPageSizeFilter: showPageSizeFilter,
              onSort: onSort,
              onShowFilterMenu: onShowFilterMenu,
              onColumnHover: onColumnHover,
              onColumnHoverExit: onColumnHoverExit,
              hoveredColumnIndex: hoveredColumnIndex,
              isResizing: isResizing,
              onStartResizing: onStartResizing,
              onUpdatePreviewWidth: onUpdatePreviewWidth,
              onFinishResizing: onFinishResizing,
            );
          }),
        ),
      ),
    );
  }
}
