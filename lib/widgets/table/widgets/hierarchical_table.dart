import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/table/widgets/pagination_bar.dart';
import 'package:table_base/widgets/table/widgets/table_actions_widget.dart';
import 'package:table_base/widgets/table/widgets/collapse_expand_widget.dart';
import '../models/hierarchical_table_model.dart';
import '../models/table_model.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';
import 'loading_state_widget.dart';
import 'empty_state_widget.dart';

/// Widget hiển thị bảng phân cấp với khả năng collapse/expand
class HierarchicalTable<T> extends ConsumerStatefulWidget {
  /// Callback để tạo các ô cho một hàng từ một mục dữ liệu
  final List<TableCellData?> Function(T item)? cellsBuilder;

  /// Callback để lấy giá trị từ một mục theo cột
  final dynamic Function(T item, int columnIndex) valueGetter;

  /// Callback tạo TableCell theo key cột (ưu tiên cao nhất nếu cung cấp)
  final TableCellData? Function(T item, String key)? cellBuilderByKey;

  /// Callback lấy id từ item để chọn/bỏ chọn
  final dynamic Function(T item)? idGetter;

  /// Callback lấy rowId từ item để quản lý collapse/expand
  final String Function(T item)? rowIdGetter;

  /// Callback kiểm tra item có phải là parent row không
  final bool Function(T item)? isParentRowGetter;

  /// Callback lấy danh sách child items từ parent item
  final List<T> Function(T parentItem)? getChildItems;

  /// Provider để quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;

  /// Danh sách cấu hình các cột phân cấp
  final List<HierarchicalTableColumnData> hierarchicalColumns;

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

  /// Màu nền cho hàng con
  final Color? childRowBackgroundColor;

  /// Padding cho hàng con
  final EdgeInsets childRowPadding;

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

  /// Có hiển thị animation collapse/expand không
  final bool enableCollapseAnimation;

  const HierarchicalTable({
    super.key,
    required this.valueGetter,
    required this.tableProvider,
    required this.hierarchicalColumns,
    this.cellsBuilder,
    this.cellBuilderByKey,
    this.idGetter,
    this.rowIdGetter,
    this.isParentRowGetter,
    this.getChildItems,
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
    this.childRowBackgroundColor,
    this.childRowPadding = const EdgeInsets.all(5.0),
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
    this.enableCollapseAnimation = true,
  });

  @override
  ConsumerState<HierarchicalTable<T>> createState() => _HierarchicalTableState<T>();
}

class _HierarchicalTableState<T> extends ConsumerState<HierarchicalTable<T>> {
  final ScrollController _headerController = ScrollController();
  final ScrollController _bodyController = ScrollController();
  final ScrollController _scrollbarController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  /// Danh sách cấu hình các cột (bao gồm cả cột checkbox nếu có)
  List<TableColumnData> _columns = [];

  /// Lưu độ rộng đã tính cuối cùng theo key để dùng cho resize
  Map<String, double> _lastComputedWidths = {};

  /// Cờ báo hiệu đã tính toán width lần đầu
  bool _hasInitializedWidths = false;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final columnWidths = _columns.fold<Map<String, double>>(
        {},
        (map, column) => map..[column.key] = column.width,
      );
      ref
          .read(widget.tableProvider.notifier)
          .initialize(
            columnWidths: columnWidths,
            valueGetter: widget.valueGetter,
          );
      _hasInitializedWidths = true;
    });

    _onInitListener();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _scrollbarController.dispose();
    super.dispose();
  }

  /// Khởi tạo danh sách cột từ hierarchical columns
  void _initializeColumns() {
    _columns = [];

    // Thêm cột checkbox nếu cần
    if (widget.showCheckboxColumn) {
      _columns.add(
        TableColumnData(
          name: 'checkbox',
          key: 'checkbox',
          width: 50,
          isResizable: false,
          isSortable: false,
          isFilterable: false,
        ),
      );
    }

    // Thêm các cột từ hierarchical columns (flatten)
    _addHierarchicalColumns(widget.hierarchicalColumns);

    // Thêm cột actions nếu cần
    if (widget.showActionsColumn) {
      _columns.add(
        TableColumnData(
          name: 'actions',
          key: 'actions',
          width: widget.actionsColumnWidth + 30,
          isResizable: false,
          isSortable: false,
          isFilterable: false,
        ),
      );
    }
  }

  /// Đệ quy thêm các cột phân cấp
  void _addHierarchicalColumns(List<HierarchicalTableColumnData> hierarchicalColumns) {
    for (final hierarchicalColumn in hierarchicalColumns) {
      // Thêm cột cha
      _columns.add(hierarchicalColumn.toTableColumnData());
      
      // Thêm các cột con nếu có và không bị collapse
      if (hierarchicalColumn.childColumns != null && 
          hierarchicalColumn.childColumns!.isNotEmpty) {
        _addHierarchicalColumns(hierarchicalColumn.childColumns!);
      }
    }
  }

  void _syncControllers(
    ScrollController source,
    List<ScrollController> targets,
  ) {
    bool _syncing = false;
    source.addListener(() {
      if (_syncing) return;
      _syncing = true;
      for (final target in targets) {
        if (target.hasClients) {
          target.jumpTo(source.offset);
        }
      }
      _syncing = false;
    });
  }

  void _onInitListener() {
    _syncControllers(_headerController, [
      _bodyController,
      _scrollbarController,
    ]);
    _syncControllers(_bodyController, [
      _headerController,
      _scrollbarController,
    ]);
    _syncControllers(_scrollbarController, [
      _headerController,
      _bodyController,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tableState = ref.watch(widget.tableProvider);
    final providerWidths = tableState.columnsState.widths;

    return LayoutBuilder(
      builder: (context, constraints) {
        final computed = _computeColumnWidths(
          constraints.maxWidth,
          providerWidths,
        );
        _lastComputedWidths = Map<String, double>.from(computed);
        
        if (!_hasInitializedWidths) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(widget.tableProvider.notifier).updateWidths(computed);
              _hasInitializedWidths = true;
            }
          });
        }

        return ScrollbarTheme(
          data: ScrollbarThemeData(
            trackColor: WidgetStateProperty.all(Colors.white),
            thumbColor: WidgetStateProperty.all(AppColor.textHint),
            trackVisibility: WidgetStateProperty.all(true),
            thumbVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(8),
            radius: const Radius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  // Header của bảng
                  _buildTableHeader(),
                  // Nội dung bảng
                  _buildTableContent(tableState),
                  const SizedBox(height: 4),
                  _buildHorizontalScrollbar(),
                ],
              ),
              // Thanh phân trang
              PaginationBar<T>(tableProvider: widget.tableProvider),
            ],
          ),
        );
      },
    );
  }

  /// Xây dựng header của bảng
  Widget _buildTableHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _headerController,
      child: Container(
        color: widget.headerColor ?? AppColor.greenLight,
        child: Row(
          children: List.generate(_columns.length, (index) {
            final column = _columns[index];
            final width = _lastComputedWidths[column.key] ?? column.width;
            return Container(
              width: width,
              height: widget.headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: widget.borderColor,
                    width: widget.borderWidth,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  column.name,
                  style: TextStyle(
                    color: widget.textHeaderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Xây dựng nội dung bảng
  Widget _buildTableContent(GenericTableState<T> tableState) {
    // Hiển thị trạng thái lỗi
    if (tableState.errorMessage != null) {
      return widget.errorWidget ?? _buildErrorWidget(tableState.errorMessage!);
    }

    // Hiển thị trạng thái đang tải
    if (tableState.isLoading && tableState.currentPageData.isEmpty) {
      return const LoadingStateWidget();
    }

    // Hiển thị trạng thái rỗng
    if (!tableState.isLoading && tableState.currentPageData.isEmpty) {
      return widget.emptyWidget ?? const EmptyStateWidget();
    }

    // Hiển thị dữ liệu bảng
    if (!tableState.isLoading && tableState.currentPageData.isNotEmpty) {
      return _buildHierarchicalTableContent(tableState);
    }

    return const SizedBox.shrink();
  }

  /// Xây dựng nội dung bảng phân cấp
  Widget _buildHierarchicalTableContent(GenericTableState<T> tableState) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? widget.showQuantityColumn * widget.rowHeight,
        minHeight: 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: verticalScrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _bodyController,
          child: _buildHierarchicalRows(tableState),
        ),
      ),
    );
  }

  /// Xây dựng các hàng phân cấp
  Widget _buildHierarchicalRows(GenericTableState<T> tableState) {
    final rows = <Widget>[];
    
    for (int i = 0; i < tableState.currentPageData.length; i++) {
      final item = tableState.currentPageData[i];
      final isParentRow = widget.isParentRowGetter?.call(item) ?? false;
      
      if (isParentRow) {
        // Hàng cha
        final parentRow = _buildParentRow(item, i, tableState);
        final childRows = <Widget>[];
        
        // Lấy các hàng con
        final childItems = widget.getChildItems?.call(item) ?? [];
        for (int j = 0; j < childItems.length; j++) {
          childRows.add(_buildChildRow(childItems[j], j));
        }
        
        // Tạo collapsible row
        final rowId = widget.rowIdGetter?.call(item) ?? item.toString();
        final isCollapsed = tableState.collapseState.isRowCollapsed(rowId);
        
        rows.add(
          CollapsibleTableRow(
            parentRow: parentRow,
            childRows: childRows,
            collapsed: isCollapsed,
            onToggleCollapse: () {
              ref.read(widget.tableProvider.notifier).toggleRowCollapse(rowId);
            },
            childRowBackgroundColor: widget.childRowBackgroundColor,
            childRowPadding: widget.childRowPadding,
            enableAnimation: widget.enableCollapseAnimation,
          ),
        );
      } else {
        // Hàng thường
        rows.add(_buildNormalRow(item, i, tableState));
      }
    }
    
    return Column(children: rows);
  }

  /// Xây dựng hàng cha với kích thước chuẩn
  Widget _buildParentRow(T item, int index, GenericTableState<T> tableState) {
    final cells = <Widget>[];
    
    // Tính tổng độ rộng của tất cả cột để đảm bảo hàng cha có kích thước chuẩn
    double totalWidth = 0;
    for (final column in _columns) {
      totalWidth += _lastComputedWidths[column.key] ?? column.width;
    }
    
    for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
      final column = _columns[colIndex];
      final width = _lastComputedWidths[column.key] ?? column.width;
      
      Widget cellContent;
      
      // Cột checkbox
      if (widget.showCheckboxColumn && column.key == 'checkbox') {
        final itemId = widget.idGetter?.call(item) ?? (item as dynamic).id;
        final isSelected = tableState.selectionState.selectedIds.contains(itemId?.toString());
        
        cellContent = Checkbox(
          activeColor: AppColor.greenLight,
          checkColor: Colors.white,
          side: BorderSide(color: AppColor.textGrey, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          value: isSelected,
          onChanged: itemId == null ? null : (_) {
            ref.read(widget.tableProvider.notifier).toggleItemSelection(itemId.toString());
          },
        );
      }
      // Cột actions
      else if (widget.showActionsColumn && column.key == 'actions') {
        cellContent = TableActionsWidget<T>(
          item: item,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          customActions: widget.customActions,
        );
      }
      // Cột đầu tiên - thêm nút collapse/expand
      else if (colIndex == (widget.showCheckboxColumn ? 1 : 0)) {
        final rowId = widget.rowIdGetter?.call(item) ?? item.toString();
        final isCollapsed = tableState.collapseState.isRowCollapsed(rowId);
        
        cellContent = Row(
          children: [
            CollapseExpandButton(
              isCollapsed: isCollapsed,
              onTap: () {
                ref.read(widget.tableProvider.notifier).toggleRowCollapse(rowId);
              },
              enableAnimation: widget.enableCollapseAnimation,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCellContent(item, column.key),
            ),
          ],
        );
      }
      // Các cột khác
      else {
        cellContent = _buildCellContent(item, column.key);
      }
      
      cells.add(
        Container(
          width: width,
          height: widget.rowHeight,
          padding: widget.cellPadding ?? const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: widget.borderColor,
                width: widget.borderWidth,
              ),
              bottom: BorderSide(
                color: widget.borderColor,
                width: widget.borderWidth,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: cellContent,
          ),
        ),
      );
    }
    
    // Đảm bảo hàng cha có kích thước chuẩn
    return SizedBox(
      width: totalWidth,
      child: Row(children: cells),
    );
  }

  /// Xây dựng hàng con với kích thước bằng hàng cha
  Widget _buildChildRow(T item, int index) {
    final cells = <Widget>[];
    
    for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
      final column = _columns[colIndex];
      final width = _lastComputedWidths[column.key] ?? column.width;
      
      Widget cellContent;
      
      // Cột checkbox
      if (widget.showCheckboxColumn && column.key == 'checkbox') {
        final itemId = widget.idGetter?.call(item) ?? (item as dynamic).id;
        final tableState = ref.watch(widget.tableProvider);
        final isSelected = tableState.selectionState.selectedIds.contains(itemId?.toString());
        
        cellContent = Checkbox(
          activeColor: AppColor.greenLight,
          checkColor: Colors.white,
          side: BorderSide(color: AppColor.textGrey, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          value: isSelected,
          onChanged: itemId == null ? null : (_) {
            ref.read(widget.tableProvider.notifier).toggleItemSelection(itemId.toString());
          },
        );
      }
      // Cột actions
      else if (widget.showActionsColumn && column.key == 'actions') {
        cellContent = TableActionsWidget<T>(
          item: item,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          customActions: widget.customActions,
        );
      }
      // Các cột khác
      else {
        cellContent = _buildCellContent(item, column.key);
      }
      
      cells.add(
        Container(
          width: width,
          height: widget.rowHeight,
          padding: widget.cellPadding ?? const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: widget.childRowBackgroundColor ?? Colors.grey.shade50,
            border: Border(
              right: BorderSide(
                color: widget.borderColor,
                width: widget.borderWidth,
              ),
              bottom: BorderSide(
                color: widget.borderColor,
                width: widget.borderWidth,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: cellContent,
          ),
        ),
      );
    }
    
    // Tính tổng độ rộng của tất cả cột để đảm bảo hàng con có kích thước bằng hàng cha
    double totalWidth = 0;
    for (final column in _columns) {
      totalWidth += _lastComputedWidths[column.key] ?? column.width;
    }
    
    // Wrap Row trong SizedBox để đảm bảo kích thước chính xác
    return SizedBox(
      width: totalWidth,
      child: Row(children: cells),
    );
  }

  /// Xây dựng hàng thường với kích thước chuẩn
  Widget _buildNormalRow(T item, int index, GenericTableState<T> tableState) {
    final cells = <Widget>[];
    
    // Tính tổng độ rộng của tất cả cột để đảm bảo hàng thường có kích thước chuẩn
    double totalWidth = 0;
    for (final column in _columns) {
      totalWidth += _lastComputedWidths[column.key] ?? column.width;
    }
    
    for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
      final column = _columns[colIndex];
      final width = _lastComputedWidths[column.key] ?? column.width;
      
      Widget cellContent;
      
      // Cột checkbox
      if (widget.showCheckboxColumn && column.key == 'checkbox') {
        final itemId = widget.idGetter?.call(item) ?? (item as dynamic).id;
        final isSelected = tableState.selectionState.selectedIds.contains(itemId?.toString());
        
        cellContent = Checkbox(
          activeColor: AppColor.greenLight,
          checkColor: Colors.white,
          side: BorderSide(color: AppColor.textGrey, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          value: isSelected,
          onChanged: itemId == null ? null : (_) {
            ref.read(widget.tableProvider.notifier).toggleItemSelection(itemId.toString());
          },
        );
      }
      // Cột actions
      else if (widget.showActionsColumn && column.key == 'actions') {
        cellContent = TableActionsWidget<T>(
          item: item,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
          customActions: widget.customActions,
        );
      }
      // Các cột khác
      else {
        cellContent = _buildCellContent(item, column.key);
      }
      
      cells.add(
        Container(
          width: width,
          height: widget.rowHeight,
          padding: widget.cellPadding ?? const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: widget.borderColor,
                width: widget.borderWidth,
              ),
              bottom: BorderSide(
                color: widget.borderColor,
                width: widget.borderWidth,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: cellContent,
          ),
        ),
      );
    }
    
    // Đảm bảo hàng thường có kích thước chuẩn
    return SizedBox(
      width: totalWidth,
      child: Row(children: cells),
    );
  }

  /// Xây dựng nội dung ô
  Widget _buildCellContent(T item, String columnKey) {
    if (widget.cellBuilderByKey != null) {
      final customCell = widget.cellBuilderByKey!(item, columnKey);
      if (customCell != null) {
        return customCell.widget;
      }
    }
    
    if (widget.cellsBuilder != null) {
      final cells = widget.cellsBuilder!(item);
      final columnIndex = _columns.indexWhere((c) => c.key == columnKey);
      if (columnIndex >= 0 && columnIndex < cells.length && cells[columnIndex] != null) {
        return cells[columnIndex]!.widget;
      }
    }
    
    // Fallback: sử dụng valueGetter
    final columnIndex = _columns.indexWhere((c) => c.key == columnKey);
    if (columnIndex >= 0) {
      final value = widget.valueGetter(item, columnIndex);
      return Text(value?.toString() ?? '');
    }
    
    return const SizedBox();
  }

  /// Tính toán độ rộng cột
  Map<String, double> _computeColumnWidths(
    double maxWidth,
    Map<String, double> providerWidths,
  ) {
    final result = <String, double>{};
    
    for (final column in _columns) {
      final providerWidth = providerWidths[column.key];
      if (providerWidth != null && providerWidth.isFinite && providerWidth > 0) {
        result[column.key] = providerWidth;
      } else {
        result[column.key] = column.width;
      }
    }
    
    return result;
  }

  Widget _buildHorizontalScrollbar() {
    return Scrollbar(
      controller: _scrollbarController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollbarController,
        child: SizedBox(
          width: _lastComputedWidths.values.fold<double>(0.0, (a, b) => a + b),
          height: 10,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(widget.tableProvider.notifier).loadData([]),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
