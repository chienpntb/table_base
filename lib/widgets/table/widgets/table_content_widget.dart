import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';
import 'flexible_table.dart';
import 'loading_state_widget.dart';
import 'empty_state_widget.dart';

/// Widget hiển thị nội dung chính của bảng
class TableContentWidget<T> extends ConsumerWidget {
    /// Màu line giữa các row
    final Color? rowDividerColor;
    /// Độ dày line giữa các row
    final double rowDividerThickness;
  /// Provider quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;

  /// Số lượng hàng tối đa hiển thị
  final int showQuantityColumn;

  final double? maxHeight;

  /// Chiều cao mỗi hàng
  final double rowHeight;

  /// Padding bên trong mỗi ô
  final EdgeInsets? cellPadding;

  /// Trang trí cho mỗi ô
  final BoxDecoration? cellDecoration;

  /// Màu khi hover lên hàng
  final Color? hoverColor;

  /// Màu khi chọn hàng
  final Color? selectedRowColor;

  /// Cho phép hover hàng
  final bool enableRowHover;

  /// Cho phép chọn hàng
  final bool enableRowSelection;

  /// Widget hiển thị khi có lỗi
  final Widget? errorWidget;

  /// Widget hiển thị khi không có dữ liệu
  final Widget? emptyWidget;

  /// Callback khi một hàng được nhấp vào
  final void Function(T)? onRowTap;

  /// Dữ liệu bảng để hiển thị
  final dynamic tableData;

  /// Controller cuộn ngang cho nội dung bảng (để đồng bộ với header)
  final ScrollController bodyController;

  /// Controller cuộn dọc cho nội dung bảng
  final ScrollController verticalScrollController;

  const TableContentWidget({
    super.key,
    required this.tableProvider,
    required this.showQuantityColumn,
    required this.rowHeight,
    required this.enableRowHover,
    required this.enableRowSelection,
    required this.tableData,
    required this.bodyController,
    required this.verticalScrollController,
    this.maxHeight,
    this.cellPadding,
    this.cellDecoration,
    this.hoverColor,
    this.selectedRowColor,
    this.errorWidget,
    this.emptyWidget,
    this.onRowTap,
    this.rowDividerColor,
    this.rowDividerThickness = 1.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);

    // Hiển thị trạng thái lỗi
    if (tableState.errorMessage != null) {
      return errorWidget ?? _buildErrorWidget(tableState.errorMessage!, ref);
    }

    // Hiển thị trạng thái đang tải
    if (tableState.isLoading && tableState.currentPageData.isEmpty) {
      return LoadingStateWidget();
    }

    // Hiển thị trạng thái rỗng
    if (!tableState.isLoading && tableState.currentPageData.isEmpty) {
      return emptyWidget ?? EmptyStateWidget();
    }

    // Hiển thị dữ liệu bảng
    if (!tableState.isLoading && tableState.currentPageData.isNotEmpty) {
      return _buildTableContent(ref);
    }

    return const SizedBox.shrink();
  }

  /// Xây dựng nội dung bảng chính
  Widget _buildTableContent(WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? showQuantityColumn * rowHeight,
        minHeight: 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: verticalScrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: bodyController, // Sử dụng bodyController để đồng bộ với header
          child: FlexibleTable(
            data: tableData,
            cellPadding: cellPadding ?? const EdgeInsets.all(12.0),
            cellDecoration: cellDecoration ?? const BoxDecoration(color: Colors.white),
            enableRowHover: enableRowHover,
            hoverColor: hoverColor ?? Colors.blue.shade50,
            selectedRowColor: selectedRowColor ?? Colors.blue.shade50,
            rowDividerColor: rowDividerColor,
            rowDividerThickness: rowDividerThickness,
            onRowTap: enableRowSelection ? (index) => _handleRowTap(index, ref) : null,
          ),
        ),
      ),
    );
  }

  /// Xử lý khi người dùng click vào một hàng
  void _handleRowTap(int rowIndex, WidgetRef ref) {
    final tableState = ref.read(tableProvider);
    if (onRowTap != null && rowIndex < tableState.currentPageData.length) {
      onRowTap!(tableState.currentPageData[rowIndex]);
    }
  }

  /// Xây dựng widget hiển thị lỗi
  Widget _buildErrorWidget(String errorMessage, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(tableProvider.notifier).loadData([]),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}