import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/models/expandable_table_model.dart';
import 'package:table_base/widgets/table/widgets/child_table_widget.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';
import 'package:table_base/widgets/table/providers/table_notifier_interface.dart';

/// Widget hiển thị nội dung expandable table
class ExpandableTableContentWidget<T, C> extends ConsumerWidget {
  /// Provider quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  > tableProvider;

  /// Callback để lấy dữ liệu con từ dữ liệu cha
  final ChildDataGetter<T, C> childDataGetter;
  
  /// Callback để tạo cell cho dữ liệu con
  final ChildCellBuilder<C>? childCellBuilder;
  
  /// Cấu hình columns cho table con
  final List<TableColumnData> childColumns;
  
  /// Callback để tạo các ô cho một hàng từ một mục dữ liệu
  final List<TableCellData?> Function(T item)? cellsBuilder;
  
  /// Callback để lấy giá trị từ một mục theo cột
  final dynamic Function(T item, int columnIndex) valueGetter;
  
  /// Callback tạo TableCell theo key cột
  final TableCellData? Function(T item, String key)? cellBuilderByKey;
  
  /// Callback lấy id từ item để chọn/bỏ chọn
  final dynamic Function(T item)? idGetter;
  
  /// Danh sách cấu hình các cột
  final List<TableColumnData> columns;
  
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
  
  /// Controller cuộn ngang cho nội dung bảng
  final ScrollController bodyController;
  
  /// Controller cuộn dọc cho nội dung bảng
  final ScrollController verticalScrollController;
  
  /// Màu nền cho table con
  final Color? childTableBackgroundColor;
  
  /// Tiêu đề cho table con
  final String? childTableTitle;
  
  /// Chiều cao tối đa cho table con
  final double? childTableMaxHeight;

  const ExpandableTableContentWidget({
    super.key,
    required this.tableProvider,
    required this.childDataGetter,
    required this.childColumns,
    required this.columns,
    required this.valueGetter,
    required this.bodyController,
    required this.verticalScrollController,
    this.childCellBuilder,
    this.cellsBuilder,
    this.cellBuilderByKey,
    this.idGetter,
    this.showQuantityColumn = 16,
    this.rowHeight = 48,
    this.enableRowHover = true,
    this.enableRowSelection = true,
    this.maxHeight,
    this.cellPadding,
    this.cellDecoration,
    this.hoverColor,
    this.selectedRowColor,
    this.errorWidget,
    this.emptyWidget,
    this.onRowTap,
    this.childTableBackgroundColor,
    this.childTableTitle,
    this.childTableMaxHeight,
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
      return const Center(child: CircularProgressIndicator());
    }

    // Hiển thị trạng thái rỗng
    if (!tableState.isLoading && tableState.currentPageData.isEmpty) {
      return emptyWidget ?? const Center(child: Text('Không có dữ liệu'));
    }

    // Hiển thị dữ liệu bảng
    if (!tableState.isLoading && tableState.currentPageData.isNotEmpty) {
      return _buildExpandableTableContent(ref);
    }

    return const SizedBox.shrink();
  }

  /// Xây dựng nội dung expandable table
  Widget _buildExpandableTableContent(WidgetRef ref) {
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
          controller: bodyController,
          child: _buildExpandableRows(ref),
        ),
      ),
    );
  }

  /// Xây dựng các expandable rows
  Widget _buildExpandableRows(WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final expandedRows = ref.watch(_expandedRowsProvider);
    
    return Column(
      children: tableState.currentPageData.map((item) {
        return _buildExpandableRow(item, expandedRows, ref);
      }).toList(),
    );
  }

  /// Xây dựng một expandable row
  Widget _buildExpandableRow(T item, Set<String> expandedRows, WidgetRef ref) {
    final itemId = _getItemId(item);
    final isExpanded = expandedRows.contains(itemId);
    final childData = childDataGetter(item);
    final hasChildren = childData != null && childData.isNotEmpty;

    return Column(
      children: [
        // Parent row
        Container(
          height: rowHeight,
          decoration: BoxDecoration(
            color: isExpanded ? Colors.yellow.shade50 : Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: _buildRowCells(item, itemId, isExpanded, hasChildren, ref),
          ),
        ),
        
        // Child table (nếu đang expand)
        if (isExpanded && hasChildren)
          _buildChildTable(item, childData),
      ],
    );
  }

  /// Tạo các cells cho row
  List<Widget> _buildRowCells(T item, String itemId, bool isExpanded, bool hasChildren, WidgetRef ref) {
    final cells = <Widget>[];
    
    // Expand cell
    cells.add(
      Container(
        width: 40,
        padding: cellPadding ?? const EdgeInsets.all(8),
        decoration: cellDecoration,
        child: hasChildren
            ? IconButton(
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                ),
                onPressed: () => _toggleExpand(itemId, ref),
              )
            : const SizedBox(),
      ),
    );
    
    // Data cells
    for (final column in columns) {
      cells.add(
        Container(
          width: column.width,
          padding: cellPadding ?? const EdgeInsets.all(8),
          decoration: cellDecoration,
          child: _buildCellContent(item, column),
        ),
      );
    }
    
    return cells;
  }

  /// Tạo cell content
  Widget _buildCellContent(T item, TableColumnData column) {
    if (cellBuilderByKey != null) {
      final customCell = cellBuilderByKey!(item, column.key);
      if (customCell != null) {
        return customCell.widget;
      }
    }

    if (cellsBuilder != null) {
      final cells = cellsBuilder!(item);
      final columnIndex = columns.indexOf(column);
      if (columnIndex < cells.length && cells[columnIndex] != null) {
        return cells[columnIndex]!.widget;
      }
    }

    // Fallback: hiển thị giá trị mặc định
    try {
      final dynamic itemObj = item;
      final dynamic value = (itemObj as dynamic)[column.key];
      return Text(
        value?.toString() ?? '',
        style: const TextStyle(fontSize: 14),
      );
    } catch (e) {
      return const Text('', style: TextStyle(fontSize: 14));
    }
  }

  /// Tạo child table
  Widget _buildChildTable(T parentItem, List<C> childData) {
    return ChildTableWidget<C>(
      childData: childData,
      childColumns: childColumns,
      parentColumns: columns,
      title: childTableTitle,
      maxHeight: childTableMaxHeight,
      backgroundColor: childTableBackgroundColor,
      childCellBuilder: childCellBuilder,
    );
  }

  /// Toggle expand state
  void _toggleExpand(String itemId, WidgetRef ref) {
    final currentExpanded = ref.read(_expandedRowsProvider);
    final newExpanded = Set<String>.from(currentExpanded);
    if (newExpanded.contains(itemId)) {
      newExpanded.remove(itemId);
    } else {
      newExpanded.add(itemId);
    }
    ref.read(_expandedRowsProvider.notifier).state = newExpanded;
  }

  /// Lấy item ID
  String _getItemId(T item) {
    if (idGetter != null) {
      return idGetter!(item)?.toString() ?? '';
    }
    
    try {
      final dynamic itemObj = item;
      return (itemObj as dynamic).id?.toString() ?? '';
    } catch (e) {
      return item.hashCode.toString();
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

/// Provider cho expanded rows state
final _expandedRowsProvider = StateProvider<Set<String>>((ref) => <String>{});
