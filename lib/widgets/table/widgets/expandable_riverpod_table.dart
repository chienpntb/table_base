import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/models/expandable_table_model.dart';
import 'package:table_base/widgets/table/widgets/child_table_widget.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';
import 'package:table_base/widgets/table/providers/table_notifier_interface.dart';

/// Widget table có thể expand với table con
class ExpandableRiverpodTable<T, C> extends ConsumerStatefulWidget {
  /// Callback để lấy dữ liệu con từ dữ liệu cha
  final ChildDataGetter<T, C> childDataGetter;
  
  /// Callback để tạo cell cho dữ liệu con
  final ChildCellBuilder<C>? childCellBuilder;
  
  /// Cấu hình columns cho table con
  final List<TableColumnData> childColumns;
  
  /// Provider để quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  > tableProvider;
  
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
  
  /// Cho phép chọn hàng khi nhấp vào
  final bool enableRowSelection;
  
  /// Hiển thị hiệu ứng hover khi di chuột qua hàng
  final bool enableRowHover;
  
  /// Hiển thị màu xen kẽ cho các hàng
  final bool showAlternatingRowColors;
  
  /// Hiển thị cột checkbox để chọn nhiều mục
  final bool showCheckboxColumn;
  
  /// Cho phép điều chỉnh kích thước cột
  final bool enableColumnResize;
  
  /// Padding bên trong mỗi ô
  final EdgeInsets? cellPadding;
  
  /// Trang trí cho mỗi ô
  final BoxDecoration? cellDecoration;
  
  /// Màu cho các hàng xen kẽ
  final Color? alternateColor;
  
  /// Màu khi hover lên hàng
  final Color? hoverColor;
  
  /// Màu khi chọn hàng
  final Color? selectedRowColor;
  
  /// Màu cho header
  final Color? headerColor;
  
  /// Màu text cho header
  final Color textHeaderColor;
  
  /// Widget hiển thị khi có lỗi
  final Widget? errorWidget;
  
  /// Widget hiển thị khi không có dữ liệu
  final Widget? emptyWidget;
  
  final Color borderColor;
  final double borderWidth;
  final int showQuantityColumn;
  final double? maxHeight;
  final int showPageSizeFilter;
  final double rowHeight;
  final double headerHeight;
  
  /// Callback khi một hàng được nhấp vào
  final void Function(T)? onRowTap;
  
  /// Callback khi nhấn nút sửa cho một item
  final void Function(T)? onEdit;
  
  /// Callback khi nhấn nút xóa cho một item
  final void Function(T)? onDelete;
  
  /// Hiển thị cột actions với các nút thêm, sửa, xóa
  final bool showActionsColumn;
  
  /// Chiều rộng của cột actions
  final double actionsColumnWidth;
  
  /// Danh sách các nút hành động tùy chỉnh trong cột actions
  final List<dynamic>? customActions;
  
  /// Màu nền cho table con
  final Color? childTableBackgroundColor;
  
  /// Tiêu đề cho table con
  final String? childTableTitle;
  
  /// Chiều cao tối đa cho table con
  final double? childTableMaxHeight;

  const ExpandableRiverpodTable({
    super.key,
    required this.childDataGetter,
    required this.childColumns,
    required this.valueGetter,
    required this.tableProvider,
    required this.columns,
    this.childCellBuilder,
    this.cellsBuilder,
    this.cellBuilderByKey,
    this.idGetter,
    this.enableRowSelection = true,
    this.enableRowHover = true,
    this.showAlternatingRowColors = false,
    this.showCheckboxColumn = true,
    this.enableColumnResize = true,
    this.cellPadding,
    this.cellDecoration,
    this.alternateColor,
    this.hoverColor,
    this.selectedRowColor,
    this.headerColor,
    this.textHeaderColor = Colors.white,
    this.errorWidget,
    this.emptyWidget,
    this.onRowTap,
    this.onEdit,
    this.onDelete,
    this.showActionsColumn = false,
    this.actionsColumnWidth = 120,
    this.customActions,
    this.showQuantityColumn = 16,
    this.rowHeight = 48,
    this.borderColor = Colors.grey,
    this.borderWidth = 1,
    this.headerHeight = 48,
    this.showPageSizeFilter = 100,
    this.maxHeight,
    this.childTableBackgroundColor,
    this.childTableTitle,
    this.childTableMaxHeight,
  });

  @override
  ConsumerState<ExpandableRiverpodTable<T, C>> createState() => 
      _ExpandableRiverpodTableState<T, C>();
}

class _ExpandableRiverpodTableState<T, C> extends ConsumerState<ExpandableRiverpodTable<T, C>> {
  /// Set các row đang được expand
  final Set<String> _expandedRows = <String>{};
  
  // Map lưu trữ dữ liệu con đã load (có thể sử dụng trong tương lai)
  // final Map<String, List<C>> _cachedChildData = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header table với scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: widget.headerHeight,
            color: widget.headerColor ?? AppColor.greenLight,
            child: Row(
              children: widget.columns.map((column) {
                return Container(
                  width: column.width,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    column.name,
                    style: TextStyle(
                      color: widget.textHeaderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Content table với expandable rows
        Expanded(
          child: _buildExpandableTableContent(),
        ),
      ],
    );
  }

  Widget _buildExpandableTableContent() {
    final tableState = ref.watch(widget.tableProvider);
    
    if (tableState.isLoading && tableState.currentPageData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!tableState.isLoading && tableState.currentPageData.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('Không có dữ liệu'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: tableState.currentPageData.map((item) {
            return _buildExpandableRow(item);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpandableRow(T item) {
    final itemId = _getItemId(item);
    final isExpanded = _expandedRows.contains(itemId);
    final childData = widget.childDataGetter(item);
    final hasChildren = childData != null && childData.isNotEmpty;

    return Column(
      children: [
        // Parent row
        Container(
          height: widget.rowHeight,
          decoration: BoxDecoration(
            color: isExpanded ? Colors.yellow.shade50 : Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              // Expand/collapse button
              if (hasChildren)
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                    onPressed: () => _toggleExpand(itemId),
                  ),
                )
              else
                const SizedBox(width: 40),
              
              // Data cells
              ...widget.columns.map((column) {
                return Container(
                  width: column.width,
                  padding: widget.cellPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: widget.cellDecoration,
                  child: _buildCellContent(item, column),
                );
              }).toList(),
            ],
          ),
        ),
        
        // Child table (nếu đang expand)
        if (isExpanded && hasChildren)
          _buildChildTable(item, childData),
      ],
    );
  }

  Widget _buildCellContent(T item, TableColumnData column) {
    if (widget.cellBuilderByKey != null) {
      final customCell = widget.cellBuilderByKey!(item, column.key);
      if (customCell != null) {
        return customCell.widget;
      }
    }

    if (widget.cellsBuilder != null) {
      final cells = widget.cellsBuilder!(item);
      final columnIndex = widget.columns.indexOf(column);
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

  Widget _buildChildTable(T parentItem, List<C> childData) {
    return ChildTableWidget<C>(
      childData: childData,
      childColumns: widget.childColumns,
      parentColumns: widget.columns,
      title: widget.childTableTitle,
      maxHeight: widget.childTableMaxHeight,
      backgroundColor: widget.childTableBackgroundColor,
      childCellBuilder: widget.childCellBuilder,
    );
  }

  void _toggleExpand(String itemId) {
    setState(() {
      if (_expandedRows.contains(itemId)) {
        _expandedRows.remove(itemId);
      } else {
        _expandedRows.add(itemId);
      }
    });
  }

  String _getItemId(T item) {
    if (widget.idGetter != null) {
      return widget.idGetter!(item)?.toString() ?? '';
    }
    
    try {
      final dynamic itemObj = item;
      return (itemObj as dynamic).id?.toString() ?? '';
    } catch (e) {
      return item.hashCode.toString();
    }
  }
}
