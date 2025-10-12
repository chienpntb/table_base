import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/dashed_line.dart';
import '../models/table_model.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';
import 'sortable_header_widget.dart';
import 'actions_header_widget.dart';
import 'column_resize_widget.dart';

/// Widget hiển thị một ô header với các tính năng:
/// - Checkbox chọn tất cả
/// - Sắp xếp và lọc
/// - Actions header
/// - Resize cột
class TableHeaderCellWidget<T> extends ConsumerWidget {
  /// Cấu hình cột
  final TableColumnData column;

  /// Chỉ số cột
  final int columnIndex;

  /// Độ rộng cột
  final double width;

  /// Có phải cột cuối cùng không
  final bool isLastColumn;

  /// Provider quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;

  /// Chiều cao header
  final double headerHeight;

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

  /// Callback khi sắp xếp
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

  const TableHeaderCellWidget({
    super.key,
    required this.column,
    required this.columnIndex,
    required this.width,
    required this.isLastColumn,
    required this.tableProvider,
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
    this.enableColumnResize = true,
    this.showCheckboxColumn = true,
    this.showActionsColumn = false,
    this.actionsColumnWidth = 120,
    this.showPageSizeFilter = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final isActionsColumn = column.key == 'actions';

    // Kiểm tra trạng thái hover của cột hiện tại và các cột lân cận
    final bool isCurrentColumnHovered =
        !isResizing && hoveredColumnIndex == columnIndex;
    final bool isPreviousColumnHovered =
        !isResizing && hoveredColumnIndex == columnIndex - 1;
    final bool isNextColumnHovered =
        !isResizing && hoveredColumnIndex == columnIndex + 1;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Vùng chính của ô header
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            if (!isResizing && !isActionsColumn) {
              onColumnHover(columnIndex);
            }
          },
          onExit: (_) {
            if (!isResizing && !isActionsColumn) {
              onColumnHoverExit();
            }
          },
          child: InkWell(
            onTap: isActionsColumn ? null : () => onSort(columnIndex),
            child: SizedBox(
              width: width,
              height: headerHeight,
              child: Row(
                children: [
                  // Đường kẻ đứt nét bên trái khi hover
                  if (columnIndex != 0)
                    (isCurrentColumnHovered || isPreviousColumnHovered)
                        ? DashedLine(
                          axis: Axis.vertical,
                          color: Colors.white,
                          dashWidth: 6,
                          dashSpace: 6,
                          thickness: 2,
                          width: 0.2,
                        )
                        : const SizedBox.shrink(),

                  // Nội dung chính của ô
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildCellContent(tableState, ref),
                    ),
                  ),

                  // Đường kẻ đứt nét bên phải khi hover
                  if (!isLastColumn)
                    (isCurrentColumnHovered || isNextColumnHovered)
                        ? DashedLine(
                          axis: Axis.vertical,
                          color: Colors.white,
                          dashWidth: 6,
                          dashSpace: 6,
                          thickness: 2,
                          width: 0.2,
                        )
                        : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),

        // Handle resize cột (nếu được phép)
        if (enableColumnResize && !isActionsColumn && column.isResizable)
          Positioned(
            top: 0,
            bottom: 0,
            right: -10,
            width: 20,
            child: ColumnResizeWidget(
              columnIndex: columnIndex,
              onColumnHover: onColumnHover,
              onColumnHoverExit: onColumnHoverExit,
              hoveredColumnIndex: hoveredColumnIndex,
              isResizing: isResizing,
              onStartResizing: onStartResizing,
              onUpdatePreviewWidth: onUpdatePreviewWidth,
              onFinishResizing: onFinishResizing,
            ),
          ),
      ],
    );
  }

  /// Xây dựng nội dung của ô header dựa trên loại cột
  Widget _buildCellContent(GenericTableState<T> tableState, WidgetRef ref) {
    // Cột checkbox
    if (showCheckboxColumn && column.key == 'checkbox') {
      return Checkbox(
        activeColor: Colors.white,
        checkColor: AppColor.greenLight,
        side: const BorderSide(color: Colors.white, width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        overlayColor: WidgetStatePropertyAll<Color>(
          Colors.white.withValues(alpha: .2),
        ),
        value: tableState.selectionState.selectAll,
        onChanged: (_) => ref.read(tableProvider.notifier).toggleSelectAll(),
      );
    }

    // Cột actions
    if (showActionsColumn && column.key == 'actions') {
      return ActionsHeaderWidget(textHeaderColor: textHeaderColor);
    }

    // Cột thông thường với sắp xếp và lọc
    return SortableHeaderWidget<T>(
      title: column.name,
      columnIndex: columnIndex,
      tableProvider: tableProvider,
      textHeaderColor: textHeaderColor,
      showPageSizeFilter: showPageSizeFilter,
      onShowFilterMenu: onShowFilterMenu,
    );
  }
}