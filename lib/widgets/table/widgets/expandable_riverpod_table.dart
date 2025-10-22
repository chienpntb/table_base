import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/models/expandable_table_model.dart';
import 'package:table_base/widgets/table/widgets/child_table_widget.dart';
import 'package:table_base/widgets/table/widgets/pagination_bar.dart';
import 'package:table_base/widgets/table/widgets/table_actions_widget.dart';
import 'package:table_base/widgets/table/widgets/table_header_widget.dart';
import 'package:table_base/widgets/table/widgets/flexible_table.dart';
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
  final List<CustomAction<T>>? customActions;
  
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

class _ExpandableRiverpodTableState<T, C> extends ConsumerState<ExpandableRiverpodTable<T, C>> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  /// Set các row đang được expand
  final Set<String> _expandedRows = <String>{};
  
  /// Key để preserve FlexibleTable state
  final GlobalKey _flexibleTableKey = GlobalKey();
  
  final ScrollController _headerController = ScrollController();
  final ScrollController _bodyController = ScrollController();
  final ScrollController _scrollbarController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  /// Danh sách cấu hình các cột (bao gồm cả cột checkbox nếu có)
  List<TableColumnData> _columns = [];

  /// Biến quản lý resize cột
  int _resizingColumnIndex = -1;
  double _startDragX = 0;
  double _initialColumnWidth = 0;
  String? _resizingColumnKey;

  /// Biến quản lý hover giữa các cột
  int _hoveredColumnIndex = -1;

  /// Biến theo dõi trạng thái đang resize cột
  bool _isResizing = false;

  /// Biến lưu trữ độ rộng preview trong quá trình resize
  double _previewWidth = 0;

  bool _syncing = false;

  double _maxWidth = 0;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Widget đã được render
    });
    _onInitListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Có thể cần tính toán lại khi dependencies thay đổi
  }

  @override
  void didUpdateWidget(covariant ExpandableRiverpodTable<T, C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKeys = oldWidget.columns.map((c) => c.key).toList(growable: false);
    final newKeys = widget.columns.map((c) => c.key).toList(growable: false);
    final columnsChanged = oldKeys.length != newKeys.length ||
        oldKeys.asMap().entries.any((e) => e.value != newKeys[e.key]);
    final checkboxChanged = oldWidget.showCheckboxColumn != widget.showCheckboxColumn;
    final actionsChanged = oldWidget.showActionsColumn != widget.showActionsColumn;

    if (columnsChanged || checkboxChanged || actionsChanged) {
      _initializeColumns();
    }
  }

  /// Khởi tạo danh sách cột theo cấu hình và thêm các cột đặc biệt
  void _initializeColumns() {
    _columns = [];

    // Thêm cột expand/collapse đầu tiên
    _columns.add(TableColumnData(
      name: '',
      key: 'expand',
      width: 40,
      isResizable: false,
      isSortable: false,
      isFilterable: false,
    ));

    // Thêm cột checkbox nếu cần
    if (widget.showCheckboxColumn) {
      _columns.add(TableColumnData(
        name: '',
        key: 'checkbox',
        width: 50,
        isResizable: false,
        isSortable: false,
        isFilterable: false,
      ));
    }

    // Thêm các cột từ widget.columns
    _columns.addAll(widget.columns);

    // Thêm cột actions nếu cần
    if (widget.showActionsColumn) {
      _columns.add(TableColumnData(
        name: 'Actions',
        key: 'actions',
        width: widget.actionsColumnWidth,
        isResizable: false,
        isSortable: false,
        isFilterable: false,
      ));
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _scrollbarController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  void _syncControllers(ScrollController source, List<ScrollController> targets) {
    source.addListener(() {
      if (_syncing) return;
      _syncing = true;
      for (final target in targets) {
        if (target.hasClients && target.offset != source.offset) {
          target.jumpTo(source.offset);
        }
      }
      _syncing = false;
    });
  }

  /// Thiết lập các listener để đồng bộ hóa scroll ngang giữa header và nội dung
  void _onInitListener() {
    _syncControllers(_headerController, [_bodyController, _scrollbarController]);
    _syncControllers(_bodyController, [_headerController, _scrollbarController]);
    _syncControllers(_scrollbarController, [_headerController, _bodyController]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final tableState = ref.watch(widget.tableProvider);
    final providerWidths = tableState.columnsState.widths;

    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        final computedWidths = _computeColumnWidths(_maxWidth, providerWidths);
        
        return Column(
          children: [
            // Header
            _buildTableHeader(computedWidths),
            // Content
            Expanded(child: _buildTableContent(computedWidths)),
            // Pagination (if needed)
            if (tableState.paginationState.totalPages > 1)
              PaginationBar<T>(tableProvider: widget.tableProvider),
            // Preview line for column resize
            if (_isResizing) _buildPreviewLine(),
          ],
        );
      },
    );
  }

  /// Xây dựng header cho table
  Widget _buildTableHeader(Map<String, double> computedWidths) {
    return TableHeaderWidget<T>(
      columns: _columns,
      computedWidths: computedWidths,
      tableProvider: widget.tableProvider,
      headerController: _headerController,
      headerHeight: widget.headerHeight,
      headerColor: widget.headerColor,
      textHeaderColor: widget.textHeaderColor,
      enableColumnResize: widget.enableColumnResize,
      showCheckboxColumn: widget.showCheckboxColumn,
      showActionsColumn: widget.showActionsColumn,
      actionsColumnWidth: widget.actionsColumnWidth,
      showPageSizeFilter: widget.showPageSizeFilter,
      onSort: _handleSort,
      onShowFilterMenu: _showFilterMenu,
      onColumnHover: (index) => setState(() => _hoveredColumnIndex = index),
      onColumnHoverExit: () => setState(() => _hoveredColumnIndex = -1),
      hoveredColumnIndex: _hoveredColumnIndex,
      isResizing: _isResizing,
      onStartResizing: _startResizing,
      onUpdatePreviewWidth: _updatePreviewWidth,
      onFinishResizing: _finishResizing,
    );
  }

  /// Xây dựng nội dung table với expandable rows
  Widget _buildTableContent(Map<String, double> computedWidths) {
    final tableState = ref.watch(widget.tableProvider);
    
    if (tableState.isLoading && tableState.currentPageData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!tableState.isLoading && tableState.currentPageData.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('Không có dữ liệu'));
    }

    // Tạo dữ liệu expandable table
    final expandableTableData = _createExpandableTableData(computedWidths);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? widget.showQuantityColumn * widget.rowHeight,
        minHeight: 0,
      ),
      child: SingleChildScrollView(
        key: const PageStorageKey('expandable_table_vertical_scroll'),
        scrollDirection: Axis.vertical,
        controller: verticalScrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _bodyController,
          child: RepaintBoundary(
            child: FlexibleTable(
              key: _flexibleTableKey,
              data: expandableTableData,
              cellPadding: widget.cellPadding ?? const EdgeInsets.all(12.0),
              cellDecoration: widget.cellDecoration ?? const BoxDecoration(color: Colors.white),
              enableRowHover: widget.enableRowHover,
              hoverColor: widget.hoverColor ?? Colors.blue.shade50,
              selectedRowColor: widget.selectedRowColor ?? Colors.blue.shade50,
              onRowTap: widget.enableRowSelection ? (index) => _handleRowTap(index) : null,
            ),
          ),
        ),
      ),
    );
  }

  /// Tạo dữ liệu cho expandable table
  TableData _createExpandableTableData(Map<String, double> computedWidths) {
    final tableState = ref.watch(widget.tableProvider);
    final rows = <TableRowData>[];

    for (int itemIndex = 0; itemIndex < tableState.currentPageData.length; itemIndex++) {
      final item = tableState.currentPageData[itemIndex];
      final itemId = _getItemId(item);
      final isExpanded = _expandedRows.contains(itemId);
      final childData = widget.childDataGetter(item);
      final hasChildren = childData != null && childData.isNotEmpty;

      // Tạo parent row
      final parentRowCells = <TableCellData?>[];

      for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
        final column = _columns[colIndex];
        
        if (column.key == 'expand') {
          // Cột expand/collapse
          parentRowCells.add(TableCellData(
            widget: hasChildren 
              ? IconButton(
                  icon: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                  onPressed: () => _toggleExpand(itemId),
                )
              : const SizedBox(width: 40),
          ));
        } else if (column.key == 'checkbox' && widget.showCheckboxColumn) {
          // Cột checkbox
          final isSelected = tableState.selectionState.selectedIds.contains(itemId);
          parentRowCells.add(TableCellData(
            widget: Checkbox(
              value: isSelected,
              onChanged: (_) => ref.read(widget.tableProvider.notifier).toggleItemSelection(itemId),
            ),
          ));
        } else if (column.key == 'actions' && widget.showActionsColumn) {
          // Cột actions
          parentRowCells.add(TableCellData(
            widget: TableActionsWidget<T>(
              item: item,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
              customActions: widget.customActions,
            ),
          ));
        } else {
          // Cột dữ liệu thông thường
          final cellData = _buildCellContent(item, column);
          parentRowCells.add(cellData);
        }
      }

      // Thêm parent row
      rows.add(TableRowData(
        cells: parentRowCells,
        height: widget.rowHeight,
        isSelected: tableState.selectionState.selectedIds.contains(itemId),
      ));

      // Thêm child table nếu đang expand
      if (isExpanded && hasChildren) {
        final childTableWidget = Container(
          key: ValueKey('child_$itemId'), // Key để preserve state
          child: _buildChildTable(item, childData),
        );
        final childRowCells = <TableCellData?>[];
        
        // Tạo cell colspan cho toàn bộ row
        childRowCells.add(TableCellData(
          widget: childTableWidget,
          colSpan: _columns.length,
        ));
        
        // Thêm các cell null cho các cột còn lại (cần đủ số cột)
        for (int i = 1; i < _columns.length; i++) {
          childRowCells.add(null);
        }

        rows.add(TableRowData(
          cells: childRowCells,
          height: null, // Để child table tự xác định chiều cao
        ));
      }
    }

    // Tính column widths
    final columnWidths = <double>[];
    for (final column in _columns) {
      columnWidths.add(computedWidths[column.key] ?? column.width);
    }

    return TableData(
      rows: rows,
      columnWidths: columnWidths,
      showAlternatingRowColors: widget.showAlternatingRowColors,
      alternateColor: widget.alternateColor,
    );
  }

  /// Tạo nội dung cell cho một column
  TableCellData? _buildCellContent(T item, TableColumnData column) {
    if (widget.cellBuilderByKey != null) {
      final customCell = widget.cellBuilderByKey!(item, column.key);
      if (customCell != null) {
        return customCell;
      }
    }

    if (widget.cellsBuilder != null) {
      final cells = widget.cellsBuilder!(item);
      final originalColumnIndex = widget.columns.indexWhere((c) => c.key == column.key);
      if (originalColumnIndex >= 0 && originalColumnIndex < cells.length && cells[originalColumnIndex] != null) {
        return cells[originalColumnIndex];
      }
    }

    // Fallback: hiển thị giá trị mặc định
    try {
      final dynamic itemObj = item;
      final dynamic value = (itemObj as dynamic)[column.key];
      return TableCellData(
        widget: Text(
          value?.toString() ?? '',
          style: const TextStyle(fontSize: 14),
        ),
      );
    } catch (e) {
      return TableCellData(
        widget: const Text('', style: TextStyle(fontSize: 14)),
      );
    }
  }

  /// Xây dựng child table
  Widget _buildChildTable(T parentItem, List<C> childData) {
    return ChildTableWidget<C>(
      childData: childData,
      childColumns: widget.childColumns,
      parentColumns: widget.columns,
      title: widget.childTableTitle,
      maxHeight: widget.childTableMaxHeight,
      backgroundColor: widget.childTableBackgroundColor,
      childCellBuilder: widget.childCellBuilder,
      borderColor: widget.borderColor,
      borderWidth: widget.borderWidth,
      rowHeight: widget.rowHeight * 0.8, // Slightly smaller for child table
      cellPadding: widget.cellPadding ?? const EdgeInsets.all(8),
    );
  }

  /// Tính toán độ rộng cột
  Map<String, double> _computeColumnWidths(double maxWidth, Map<String, double> providerWidths) {
    final computedWidths = <String, double>{};
    
    // Nếu có widths từ provider và không có resize, sử dụng chúng
    if (providerWidths.isNotEmpty && !_isResizing) {
      for (final column in _columns) {
        computedWidths[column.key] = providerWidths[column.key] ?? column.width;
      }
      return computedWidths;
    }

    // Tính toán width cho từng cột
    double totalFixedWidth = 0;
    double totalFlex = 0;
    
    for (final column in _columns) {
      if (column.flex > 0) {
        totalFlex += column.flex;
      } else {
        totalFixedWidth += column.width;
        computedWidths[column.key] = column.width;
      }
    }

    // Phân phối không gian cho các cột flex
    if (totalFlex > 0) {
      final remainingWidth = maxWidth - totalFixedWidth;
      if (remainingWidth > 0) {
        for (final column in _columns) {
          if (column.flex > 0) {
            computedWidths[column.key] = (remainingWidth * column.flex / totalFlex);
          }
        }
      }
    }

    return computedWidths;
  }

  /// Đường kẻ preview thể hiện vị trí resize cột
  Widget _buildPreviewLine() {
    double lineX = 0;
    for (int i = 0; i < _resizingColumnIndex; i++) {
      final column = _columns[i];
      final tableState = ref.watch(widget.tableProvider);
      lineX += tableState.columnsState.widths[column.key] ?? column.width;
    }
    lineX += _previewWidth;

    return Positioned(
      left: lineX,
      top: 0,
      bottom: 0,
      width: 2,
      child: Container(
        color: Colors.blue.shade300,
      ),
    );
  }

  /// Xử lý sự kiện sắp xếp
  void _handleSort(int columnIndex) {
    if (columnIndex < _columns.length && _columns[columnIndex].isSortable) {
      ref.read(widget.tableProvider.notifier).sort(columnIndex);
    }
  }

  /// Hiển thị menu lọc
  Future<void> _showFilterMenu(String columnName, int columnIndex, Offset tapPosition) async {
    // Implementation tương tự như trong RiverpodTable
    // Có thể implement sau nếu cần
  }

  /// Toggle expand/collapse row với smooth animation
  void _toggleExpand(String itemId) {
    // Lưu scroll position trước khi thay đổi
    final scrollOffset = verticalScrollController.hasClients ? verticalScrollController.offset : 0.0;
    
    // Sử dụng debounce để tránh multiple calls
    setState(() {
      if (_expandedRows.contains(itemId)) {
        _expandedRows.remove(itemId);
      } else {
        _expandedRows.add(itemId);
      }
    });
    
    // Đợi một frame rồi mới restore position
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted && verticalScrollController.hasClients) {
        final newMaxScrollExtent = verticalScrollController.position.maxScrollExtent;
        final targetOffset = scrollOffset.clamp(0.0, newMaxScrollExtent);
        
        if ((verticalScrollController.offset - targetOffset).abs() > 1.0) {
          verticalScrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  /// Lấy ID của item
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

  /// Xử lý khi click vào row
  void _handleRowTap(int rowIndex) {
    final tableState = ref.read(widget.tableProvider);
    if (widget.onRowTap != null && rowIndex < tableState.currentPageData.length) {
      widget.onRowTap!(tableState.currentPageData[rowIndex]);
    }
  }

  /// Resize column methods
  void _startResizing(int columnIndex, double startX) {
    if (columnIndex >= _columns.length) return;
    
    setState(() {
      _resizingColumnIndex = columnIndex;
      _startDragX = startX;
      _resizingColumnKey = _columns[columnIndex].key;
      _initialColumnWidth = ref.read(widget.tableProvider).columnsState.widths[_resizingColumnKey] ?? _columns[columnIndex].width;
      _isResizing = true;
      _previewWidth = _initialColumnWidth;
    });
  }

  void _updatePreviewWidth(double currentX) {
    if (!_isResizing || _resizingColumnIndex == -1) return;
    
    final deltaX = currentX - _startDragX;
    final newWidth = (_initialColumnWidth + deltaX).clamp(50.0, double.infinity);
    
    setState(() {
      _previewWidth = newWidth;
    });
  }

  void _finishResizing() {
    if (!_isResizing || _resizingColumnIndex == -1 || _resizingColumnKey == null) return;

    final newWidth = _previewWidth;
    ref.read(widget.tableProvider.notifier).resizeColumn(_resizingColumnKey!, newWidth);

    setState(() {
      _isResizing = false;
      _resizingColumnIndex = -1;
      _resizingColumnKey = null;
      _previewWidth = 0;
    });
  }
}
