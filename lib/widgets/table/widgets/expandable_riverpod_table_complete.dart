import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/table_model.dart';
import '../providers/table_notifier_interface.dart';
import '../providers/table_state.dart';
import '../widgets/child_table_widget.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/table_actions_widget.dart';
import '../widgets/table_header_widget.dart';

class ExpandableRiverpodTableComplete<T, C> extends ConsumerStatefulWidget {
  final AutoDisposeStateNotifierProvider<TableNotifierInterface<T>, GenericTableState<T>> tableProvider;
  final List<TableColumnData> columns;
  final List<TableColumnData> childColumns;
  final List<TableCellData?> Function(T item)? cellsBuilder;
  final TableCellData? Function(T item, String key)? cellBuilderByKey;
  final TableCellData? Function(C childItem, String key)? childCellBuilder;
  final List<C> Function(T item) childDataGetter;
  final String? Function(T)? idGetter;
  final Widget Function(T item)? onEdit;
  final Widget Function(T item)? onDelete;
  final List<CustomAction<T>>? customActions;
  final bool showCheckboxColumn;
  final bool showActionsColumn;
  final bool enableColumnResize;
  final int showPageSizeFilter;
  final double actionsColumnWidth;
  final double headerHeight;
  final double rowHeight;
  final double showQuantityColumn;
  final double? maxHeight;
  final double? childTableMaxHeight;
  final String? childTableTitle;
  final Color headerColor;
  final Color textHeaderColor;
  final Color borderColor;
  final Color? selectedRowColor;
  final Color? childTableBackgroundColor;
  final double borderWidth;
  final EdgeInsets? cellPadding;
  final BoxDecoration? cellDecoration;
  final Widget? emptyWidget;

  const ExpandableRiverpodTableComplete({
    super.key,
    required this.tableProvider,
    required this.columns,
    required this.childColumns,
    required this.childDataGetter,
    this.cellsBuilder,
    this.cellBuilderByKey,
    this.childCellBuilder,
    this.idGetter,
    this.onEdit,
    this.onDelete,
    this.customActions,
    this.showCheckboxColumn = false,
    this.showActionsColumn = false,
    this.enableColumnResize = true,
    this.showPageSizeFilter = 1,
    this.actionsColumnWidth = 150,
    this.headerHeight = 50,
    this.rowHeight = 48,
    this.showQuantityColumn = 20,
    this.maxHeight,
    this.childTableMaxHeight,
    this.childTableTitle,
    this.headerColor = Colors.grey,
    this.textHeaderColor = Colors.white,
    this.borderColor = Colors.grey,
    this.selectedRowColor,
    this.childTableBackgroundColor,
    this.borderWidth = 1,
    this.cellPadding,
    this.cellDecoration,
    this.emptyWidget,
  });

  @override
  ConsumerState<ExpandableRiverpodTableComplete<T, C>> createState() => _ExpandableRiverpodTableCompleteState<T, C>();
}

class _ExpandableRiverpodTableCompleteState<T, C> extends ConsumerState<ExpandableRiverpodTableComplete<T, C>>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  late List<TableColumnData> _columns;
  final Set<String> _expandedRows = <String>{};
  
  // Scroll controllers
  late ScrollController _headerController;
  late ScrollController _bodyController;
  late ScrollController _scrollbarController;
  late ScrollController verticalScrollController;
  bool _syncing = false;
  
  // Column resize
  String? _resizingColumnKey;
  double _startDragX = 0;
  double _initialColumnWidth = 0;
  bool _isResizing = false;
  double _previewWidth = 0;
  
  // UI state
  int _hoveredColumnIndex = -1;
  double _maxWidth = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _prepareColumns();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onInitListener();
    });
  }

  void _initializeControllers() {
    _headerController = ScrollController();
    _bodyController = ScrollController();
    _scrollbarController = ScrollController();
    verticalScrollController = ScrollController();
  }

  void _prepareColumns() {
    _columns = [];
    
    // Thêm cột expand đầu tiên
    _columns.add(TableColumnData(
      name: '',
      key: 'expand',
      width: 50,
      isSortable: false,
    ));
    
    // Thêm checkbox column nếu cần
    if (widget.showCheckboxColumn) {
      _columns.add(TableColumnData(
        name: '',
        key: 'checkbox',
        width: 50,
        isSortable: false,
      ));
    }
    
    // Thêm các cột chính
    _columns.addAll(widget.columns);
    
    // Thêm actions column nếu cần
    if (widget.showActionsColumn) {
      _columns.add(TableColumnData(
        name: 'Hành động',
        key: 'actions',
        width: widget.actionsColumnWidth,
        isSortable: false,
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

  /// Xử lý sự kiện sắp xếp khi người dùng nhấp vào tiêu đề cột
  void _handleSort(int columnIndex) {
    if (columnIndex < _columns.length && _columns[columnIndex].isSortable) {
      ref.read(widget.tableProvider.notifier).sort(columnIndex);
    }
  }

  /// Hiển thị menu lọc dữ liệu
  Future<void> _showFilterMenu(String columnName, int columnIndex, Offset tapPosition) async {
    // Implementation tương tự như RiverpodTable nếu cần
  }

  /// TÍNH NĂNG MỚI: Toggle expand/collapse row
  void _toggleExpand(String itemId) {
    // Preserve scroll position
    final scrollOffset = verticalScrollController.hasClients ? verticalScrollController.offset : 0.0;
    
    setState(() {
      if (_expandedRows.contains(itemId)) {
        _expandedRows.remove(itemId);
      } else {
        _expandedRows.add(itemId);
      }
    });
    
    // Restore scroll position after rebuild
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

  /// TÍNH NĂNG MỚI: Lấy ID của item
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
            // Content với expandable rows
            Expanded(child: _buildExpandableTableContent(computedWidths)),
            // Pagination
            if (tableState.paginationState.totalPages > 1)
              PaginationBar<T>(tableProvider: widget.tableProvider),
            // Preview line for column resize
            if (_isResizing) _buildPreviewLine(),
          ],
        );
      },
    );
  }

  /// Build table header
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

  /// TÍNH NĂNG MỚI: Build expandable table content
  Widget _buildExpandableTableContent(Map<String, double> computedWidths) {
    final tableState = ref.watch(widget.tableProvider);
    
    if (tableState.isLoading && tableState.currentPageData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!tableState.isLoading && tableState.currentPageData.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('Không có dữ liệu'));
    }

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
          child: _buildExpandableRows(computedWidths, tableState),
        ),
      ),
    );
  }

  /// TÍNH NĂNG MỚI: Build expandable rows
  Widget _buildExpandableRows(Map<String, double> computedWidths, GenericTableState<T> tableState) {
    final children = <Widget>[];
    
    for (int itemIndex = 0; itemIndex < tableState.currentPageData.length; itemIndex++) {
      final item = tableState.currentPageData[itemIndex];
      final itemId = _getItemId(item);
      final isExpanded = _expandedRows.contains(itemId);
      final childData = widget.childDataGetter(item);
      final hasChildren = childData.isNotEmpty;

      // Parent row
      children.add(_buildParentRow(item, itemId, isExpanded, hasChildren, computedWidths, tableState));

      // Child table nếu đang expand
      if (isExpanded && hasChildren) {
        children.add(_buildChildTable(item, childData, computedWidths));
      }
    }

    return Column(children: children);
  }

  /// TÍNH NĂNG MỚI: Build parent row
  Widget _buildParentRow(T item, String itemId, bool isExpanded, bool hasChildren, 
                        Map<String, double> computedWidths, GenericTableState<T> tableState) {
    final isSelected = tableState.selectionState.selectedIds.contains(itemId);
    
    return Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: isSelected ? widget.selectedRowColor ?? Colors.blue.shade50 : 
               (isExpanded ? Colors.yellow.shade50 : Colors.white),
        border: Border.all(color: widget.borderColor, width: 0.5),
      ),
      child: Row(
        children: _buildRowCells(item, itemId, isExpanded, hasChildren, computedWidths, tableState),
      ),
    );
  }

  /// TÍNH NĂNG MỚI: Build row cells
  List<Widget> _buildRowCells(T item, String itemId, bool isExpanded, bool hasChildren,
                             Map<String, double> computedWidths, GenericTableState<T> tableState) {
    final cells = <Widget>[];
    
    for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
      final column = _columns[colIndex];
      final width = computedWidths[column.key] ?? column.width;
      
      Widget cellContent;
      
      if (column.key == 'expand') {
        // Cột expand/collapse
        cellContent = hasChildren 
          ? IconButton(
              icon: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
              ),
              onPressed: () => _toggleExpand(itemId),
            )
          : const SizedBox(width: 40);
      } else if (column.key == 'checkbox' && widget.showCheckboxColumn) {
        // Cột checkbox
        final isSelected = tableState.selectionState.selectedIds.contains(itemId);
        cellContent = Checkbox(
          value: isSelected,
          onChanged: (_) => ref.read(widget.tableProvider.notifier).toggleItemSelection(itemId),
        );
      } else if (column.key == 'actions' && widget.showActionsColumn) {
        // Cột actions
        cellContent = TableActionsWidget<T>(
          item: item,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          customActions: widget.customActions,
        );
      } else {
        // Cột dữ liệu thông thường
        cellContent = _buildCellContent(item, column);
      }
      
      cells.add(Container(
        width: width,
        padding: widget.cellPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: widget.cellDecoration,
        child: cellContent,
      ));
    }
    
    return cells;
  }

  /// Build cell content
  Widget _buildCellContent(T item, TableColumnData column) {
    if (widget.cellBuilderByKey != null) {
      final customCell = widget.cellBuilderByKey!(item, column.key);
      if (customCell != null) {
        return customCell.widget;
      }
    }

    if (widget.cellsBuilder != null) {
      final cells = widget.cellsBuilder!(item);
      final originalColumnIndex = widget.columns.indexWhere((c) => c.key == column.key);
      if (originalColumnIndex >= 0 && originalColumnIndex < cells.length && cells[originalColumnIndex] != null) {
        return cells[originalColumnIndex]!.widget;
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

  /// TÍNH NĂNG MỚI: Build child table
  Widget _buildChildTable(T parentItem, List<C> childData, Map<String, double> computedWidths) {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 4, bottom: 4),
      child: ChildTableWidget<C>(
        childData: childData,
        childColumns: widget.childColumns,
        parentColumns: widget.columns,
        title: widget.childTableTitle,
        maxHeight: widget.childTableMaxHeight,
        backgroundColor: widget.childTableBackgroundColor,
        childCellBuilder: widget.childCellBuilder,
        borderColor: widget.borderColor,
        borderWidth: widget.borderWidth,
        rowHeight: widget.rowHeight * 0.8,
        cellPadding: widget.cellPadding ?? const EdgeInsets.all(8),
      ),
    );
  }

  /// Tính toán độ rộng cột
  Map<String, double> _computeColumnWidths(double maxWidth, Map<String, double> providerWidths) {
    final computedWidths = <String, double>{};
    double totalFixedWidth = 0;
    int flexibleColumns = 0;
    
    // Tính tổng width của các cột có width cố định
    for (final column in _columns) {
      final savedWidth = providerWidths[column.key];
      if (savedWidth != null) {
        computedWidths[column.key] = savedWidth;
        totalFixedWidth += savedWidth;
      } else {
        computedWidths[column.key] = column.width;
        totalFixedWidth += column.width;
        // Kiểm tra flexible dựa trên flex > 0
        if (column.flex > 0) {
          flexibleColumns++;
        }
      }
    }
    
    // Điều chỉnh width nếu cần
    if (totalFixedWidth < maxWidth && flexibleColumns > 0) {
      final remainingWidth = maxWidth - totalFixedWidth;
      final additionalWidthPerColumn = remainingWidth / flexibleColumns;
      
      for (final column in _columns) {
        if (column.flex > 0) {
          computedWidths[column.key] = (computedWidths[column.key] ?? 0) + additionalWidthPerColumn;
        }
      }
    }
    
    return computedWidths;
  }

  /// Preview line cho column resize
  Widget _buildPreviewLine() {
    return Positioned(
      left: _previewWidth,
      top: 0,
      bottom: 0,
      width: 2,
      child: Container(color: Colors.blue.shade300),
    );
  }

  // Column resize methods
  void _startResizing(int columnIndex, double startX) {
    setState(() {
      _startDragX = startX;
      _resizingColumnKey = _columns[columnIndex].key;
      _initialColumnWidth = ref.read(widget.tableProvider).columnsState.widths[_resizingColumnKey] ?? _columns[columnIndex].width;
      _isResizing = true;
      _previewWidth = _initialColumnWidth;
    });
  }

  void _updatePreviewWidth(double currentX) {
    if (!_isResizing) return;
    
    final deltaX = currentX - _startDragX;
    final newWidth = (_initialColumnWidth + deltaX).clamp(50.0, double.infinity);
    
    setState(() {
      _previewWidth = newWidth;
    });
  }

  void _finishResizing() {
    if (!_isResizing || _resizingColumnKey == null) return;

    final newWidth = _previewWidth;
    ref.read(widget.tableProvider.notifier).resizeColumn(_resizingColumnKey!, newWidth);

    setState(() {
      _isResizing = false;
      _resizingColumnKey = null;
      _previewWidth = 0;
    });
  }
}