import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/dashed_line.dart';
import 'package:table_base/widgets/table/widgets/filter_menu_widget.dart';
import 'package:table_base/widgets/table/widgets/pagination_bar.dart';
import 'package:table_base/widgets/table/widgets/table_actions_widget.dart';
import 'package:table_base/widgets/table/widgets/table_header_widget.dart';
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

class _ExpandableRiverpodTableState<T, C> extends ConsumerState<ExpandableRiverpodTable<T, C>> {
  /// Set các row đang được expand
  final Set<String> _expandedRows = <String>{};
  
  // Map lưu trữ dữ liệu con đã load (có thể sử dụng trong tương lai)
  // final Map<String, List<C>> _cachedChildData = {};

  /// Scroll controllers để đồng bộ hóa scroll giữa header và body
  final ScrollController _headerController = ScrollController();
  final ScrollController _bodyController = ScrollController();
  final ScrollController _scrollbarController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  /// Danh sách cấu hình các cột (bao gồm cả cột checkbox nếu có)
  List<TableColumnData> _columns = [];

  /// Lưu độ rộng đã tính cuối cùng theo key để dùng cho resize (bao gồm cả flex)
  Map<String, double> _lastComputedWidths = {};

  /// Lưu độ rộng ban đầu theo key để dùng cho resize
  Map<String, double> _initialComputedWidths = {};

  /// Các cột đã được người dùng resize sẽ bị "pin" thành fixed để giữ width
  final Set<String> _pinnedColumnKeys = <String>{};

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

  /// Cờ báo hiệu đã tính toán width lần đầu
  bool _hasInitializedWidths = false;

  /// Cờ báo hiệu đã khởi tạo table
  bool _hasInitializedTable = false;

  /// Cờ báo hiệu đang trong quá trình cập nhật sau resize để tránh tính toán liên tục
  bool _isUpdatingAfterResize = false;

  double _maxWidth = 0;

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    // Khởi tạo bảng với các thông số ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Prevent multiple initializations
      if (_hasInitializedTable) {
        print('ExpandableTable: Already initialized, skipping');
        return;
      }

      // Check if data is already loaded to avoid clearing it
      final currentState = ref.read(widget.tableProvider);
      // Always ensure valueGetter is set, even if data exists
      final columnWidths = _columns.fold<Map<String, double>>(
        {},
        (map, column) => map..[column.key] = column.width,
      );
      
      if (currentState.allData.isEmpty) {
        print('ExpandableTable: Initializing table with empty data');
        ref
            .read(widget.tableProvider.notifier)
            .initialize(
              columnWidths: columnWidths,
              valueGetter: widget.valueGetter,
            );
        print('ExpandableTable: Initialize called with valueGetter: ${widget.valueGetter != null}');
      } else {
        print('ExpandableTable: Data already exists, but ensuring valueGetter is set');
        // Ensure valueGetter is set even if data exists
        ref
            .read(widget.tableProvider.notifier)
            .initialize(
              columnWidths: columnWidths,
              valueGetter: widget.valueGetter,
            );
        print('ExpandableTable: Re-initialize called with valueGetter: ${widget.valueGetter != null}');
      }
      _hasInitializedWidths = true;
      _hasInitializedTable = true;
    });

    _onInitListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset flag khi kích thước màn hình thay đổi để tính toán lại
    _hasInitializedWidths = false;
  }

  @override
  void didUpdateWidget(covariant ExpandableRiverpodTable<T, C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKeys = oldWidget.columns.map((c) => c.key).toList(growable: false);
    final newKeys = widget.columns.map((c) => c.key).toList(growable: false);
    final columnsChanged =
        oldKeys.length != newKeys.length ||
        oldKeys.asMap().entries.any((e) => e.value != newKeys[e.key]);
    final checkboxChanged =
        oldWidget.showCheckboxColumn != widget.showCheckboxColumn;
    final actionsChanged =
        oldWidget.showActionsColumn != widget.showActionsColumn ||
        oldWidget.actionsColumnWidth != widget.actionsColumnWidth;

    if (columnsChanged || checkboxChanged || actionsChanged) {
      // Lưu width cũ theo key để giữ lại nếu có thể
      final oldState = ref.read(widget.tableProvider);
      final oldWidths = oldState.columnsState.widths;

      // Tái khởi tạo danh sách cột hiển thị
      _initializeColumns();

      // Tạo map width mới dựa trên key, ưu tiên giữ width cũ nếu tồn tại
      final Map<String, double> newWidths = {};
      for (final col in _columns) {
        newWidths[col.key] = oldWidths[col.key] ?? col.width;
      }

      // Cập nhật widths không reload dữ liệu (tránh gọi initialize để không load lại)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          ref.read(widget.tableProvider.notifier).updateWidths(newWidths);
          // Reset flag để tính lại width khi có thay đổi cột
          _hasInitializedWidths = false;
          // Reset pinned columns khi có thay đổi cột
          _pinnedColumnKeys.clear();
          // Làm sạch cache width để tránh sử dụng dữ liệu cũ
          _lastComputedWidths.clear();
        } catch (_) {
          if (mounted) setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _scrollbarController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  /// Khởi tạo danh sách cột theo cấu hình và thêm các cột đặc biệt (checkbox/actions)
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

    // Thêm các cột từ widget.columns
    for (int i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];
      _columns.add(column);
    }

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

  void _syncControllers(
    ScrollController source,
    List<ScrollController> targets,
  ) {
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

  /// Thiết lập các listener để đồng bộ hóa scroll ngang giữa header và nội dung
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

  /// Xử lý sự kiện sắp xếp khi người dùng nhấp vào tiêu đề cột
  void _handleSort(int columnIndex) {
    if (columnIndex < _columns.length && _columns[columnIndex].isSortable) {
      ref.read(widget.tableProvider.notifier).sort(columnIndex);
    }
  }

  /// Hiển thị menu lọc dữ liệu khi người dùng nhấp vào icon filter
  Future<void> _showFilterMenu(
    String columnName,
    int columnIndex,
    Offset tapPosition,
  ) async {
    if (columnIndex >= _columns.length || !_columns[columnIndex].isFilterable) {
      return;
    }

    final tableState = ref.watch(widget.tableProvider);
    final currentFilter = tableState.filterState.columnFilters[columnIndex];
    final column = _columns[columnIndex];

    if (column.filterType == null) {
      return;
    }

    // Sử dụng FilterType từ cấu hình cột
    FilterType filterType = column.filterType!;

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTWH(tapPosition.dx, tapPosition.dy - 20, 0, 0),
      Offset.zero & overlay.size,
    );

    double maxHeight = MediaQuery.of(context).size.height * 0.8;
    double minHeight = 0;
    await showMenu(
      context: context,
      position: position,
      elevation: 8,
      menuPadding: EdgeInsets.zero,
      color: Colors.white,
      shadowColor: Colors.black,
      constraints: BoxConstraints(
        minWidth: 200,
        maxWidth: filterType == FilterType.date ? 440 : 320,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        1,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          enabled: false,
          child: FilterMenuWidget<T>(
            columnIndex: columnIndex,
            columnName: columnName,
            filterType: filterType,
            allData: tableState.filteredData,
            valueGetter: widget.valueGetter,
            tableProvider: widget.tableProvider,
            currentFilter: currentFilter,
            maxWidth: filterType == FilterType.date ? 440 : 320,
            pageSize: widget.showPageSizeFilter,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableState = ref.watch(widget.tableProvider);
    final providerWidths = tableState.columnsState.widths;

    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        final computed = _computeColumnWidths(
          constraints.maxWidth,
          providerWidths,
        );
        // Ghi nhớ widths đã tính để phục vụ logic resize dựa trên width hiển thị
        _lastComputedWidths = Map<String, double>.from(computed);
        // Cập nhật provider với kết quả flex mới chỉ khi lần đầu khởi tạo
        if (!_hasInitializedWidths) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(widget.tableProvider.notifier).updateWidths(computed);
              _hasInitializedWidths = true;
            }
          });
        }

        // Lưu độ rộng ban đầu cho lần đầu (hoặc cho cột mới xuất hiện) chỉ một lần
        if (_initialComputedWidths.isEmpty) {
          _initialComputedWidths = Map<String, double>.from(computed);
        } else {
          // Chỉ cập nhật khi có cột mới xuất hiện (khi người dùng bật/tắt cột)
          for (final entry in computed.entries) {
            if (!_initialComputedWidths.containsKey(entry.key)) {
              _initialComputedWidths.putIfAbsent(entry.key, () => entry.value);
            }
          }
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
                Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header của bảng
                        _buildHeader(),
                        // Nội dung bảng với chiều cao cố định
                        SizedBox(
                          height: widget.maxHeight ?? 400,
                          child: _buildExpandableTableContent(),
                        ),
                        const SizedBox(height: 4),
                        _buildHorizontalScrollbar(),
                      ],
                    ),
                    // Đường kẻ preview khi resize cột
                    if (_isResizing && _resizingColumnIndex >= 0)
                      _buildPreviewLine(),
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

  Widget _buildHeader() {
    return TableHeaderWidget<T>(
      columns: _columns,
      computedWidths: _lastComputedWidths,
      tableProvider: widget.tableProvider,
      headerController: _headerController,
      headerHeight: widget.headerHeight,
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

  Widget _buildExpandableTableContent() {
    final tableState = ref.watch(widget.tableProvider);
    
    // Debug information
    // print('Table State - isLoading: ${tableState.isLoading}');
    // print('Table State - currentPageData length: ${tableState.currentPageData.length}');
    // print('Table State - allData length: ${tableState.allData.length}');
    
    if (tableState.isLoading && tableState.currentPageData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!tableState.isLoading && tableState.currentPageData.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('Không có dữ liệu'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _bodyController,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _verticalScrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
    final tableState = ref.watch(widget.tableProvider);
    final notifier = ref.read(widget.tableProvider.notifier);

    // Kiểm tra xem mục này có được chọn không
    final dynamic itemIdObj = widget.idGetter != null ? widget.idGetter!(item) : (item as dynamic).id;
    final String? itemIdString = itemIdObj?.toString();
    final bool isItemSelected = itemIdString != null &&
        tableState.selectionState.selectedIds.map((id) => id.toString()).contains(itemIdString);

    return Column(
      children: [
        // Parent row
        GestureDetector(
          onTap: () {
            if (widget.onRowTap != null) {
              widget.onRowTap!(item);
            }
          },
          child: Container(
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
              ..._columns.map((column) {
                return Container(
                  width: _lastComputedWidths[column.key] ?? column.width,
                  padding: widget.cellPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: widget.cellDecoration,
                  child: _buildCellContent(item, column, isItemSelected, notifier),
                );
              }).toList(),
            ],
          ),
          ),
        ),
        
        // Child table (nếu đang expand)
        if (isExpanded && hasChildren)
          _buildChildTable(item, childData),
      ],
    );
  }

  Widget _buildCellContent(T item, TableColumnData column, bool isItemSelected, dynamic notifier) {
    // Cột checkbox
    if (widget.showCheckboxColumn && column.key == 'checkbox') {
      final dynamic itemIdObj = widget.idGetter != null ? widget.idGetter!(item) : (item as dynamic).id;
      return Checkbox(
        activeColor: AppColor.greenLight,
        checkColor: Colors.white,
        side: BorderSide(color: AppColor.textGrey, width: 1.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        overlayColor: WidgetStatePropertyAll<Color>(
          AppColor.textGrey.withValues(alpha: .2),
        ),
        value: isItemSelected,
        onChanged: itemIdObj == null ? null : (_) => notifier.toggleItemSelection(itemIdObj),
      );
    }

    // Cột actions
    if (widget.showActionsColumn && column.key == 'actions') {
      return TableActionsWidget<T>(
        item: item,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
        customActions: widget.customActions,
      );
    }

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
    print('_buildChildTable called with childData length: ${childData.length}');
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

  /// Tính toán độ rộng cột thông minh với hệ thống flex layout
  Map<String, double> _computeColumnWidths(
    double maxWidth,
    Map<String, double> providerWidths,
  ) {
    // Chỉ sử dụng width từ provider khi đã khởi tạo và không có cột flex
    final hasFlexColumns = _columns.any((c) => c.flex > 0);

    if (_hasInitializedWidths &&
        !_isResizing &&
        !_isUpdatingAfterResize &&
        providerWidths.isNotEmpty &&
        !hasFlexColumns) {
      final result = <String, double>{};
      for (final col in _columns) {
        final providerWidth = providerWidths[col.key];
        if (providerWidth != null &&
            providerWidth.isFinite &&
            providerWidth > 0) {
          result[col.key] = providerWidth;
        } else {
          result[col.key] = col.width;
        }
      }
      return result;
    }

    if (!maxWidth.isFinite || maxWidth <= 0) {
      maxWidth = _columns
          .map((c) => providerWidths[c.key] ?? c.width)
          .fold<double>(0, (s, w) => s + w);
      if (!maxWidth.isFinite || maxWidth <= 0) {
        maxWidth = _maxWidth > 0 ? _maxWidth : MediaQuery.of(context).size.width;
      }
    }

    final List<TableColumnData> cols = List<TableColumnData>.from(_columns);

    // Helper: prefer last computed (displayed) width when resizing
    double preferStableWidth(TableColumnData c) {
      if (_isResizing) {
        final fromLast = _lastComputedWidths[c.key];
        if (fromLast != null && fromLast.isFinite && fromLast > 0) {
          return fromLast;
        }
      }

      if (_pinnedColumnKeys.contains(c.key)) {
        final fromProvider = providerWidths[c.key];
        if (fromProvider != null && fromProvider.isFinite && fromProvider > 0) {
          return fromProvider;
        }
      }

      final fromProvider = providerWidths[c.key];
      if (fromProvider != null && fromProvider.isFinite && fromProvider > 0) {
        return fromProvider;
      }
      final fromLast = _lastComputedWidths[c.key];
      if (fromLast != null && fromLast.isFinite && fromLast > 0) {
        return fromLast;
      }
      return c.width;
    }

    // Quy ước: cột fixed là cột có flex <= 0, cột đặc biệt, hoặc đã được pin khi resize
    bool isFixed(TableColumnData c) =>
        c.flex <= 0 ||
        c.key == 'checkbox' ||
        c.key == 'actions' ||
        _pinnedColumnKeys.contains(c.key);

    final fixedCols = cols.where(isFixed).toList();
    final flexCols = cols.where((c) => !isFixed(c)).toList();

    // If we are in resizing mode, freeze all widths to current displayed widths
    if (_isResizing) {
      final result = {for (final c in cols) c.key: preferStableWidth(c)};
      return result;
    }

    // Tổng width tất cả cột theo provider/default
    final double totalAllWidths = cols.fold<double>(0, (sum, c) {
      final v = preferStableWidth(c);
      return sum + ((v.isFinite && v > 0) ? v : c.width);
    });

    // Nếu tổng width của tất cả cột > maxWidth => không chia flex, dùng width sẵn có
    if (totalAllWidths > maxWidth) {
      final result = <String, double>{};
      for (final c in cols) {
        final width = preferStableWidth(c);
        result[c.key] = _finitePositive(width, c.width);
      }
      return result;
    }

    // Nếu không có cột flex, cũng giữ nguyên width sẵn có
    if (flexCols.isEmpty) {
      final result = {
        for (final c in cols)
          c.key: _finitePositive(preferStableWidth(c), c.width),
      };
      return result;
    }

    // Tính phần còn lại để chia cho các cột flex
    double fixedSum = 0;
    for (final c in fixedCols) {
      final v = preferStableWidth(c);
      fixedSum += (v.isFinite && v > 0) ? v : c.width;
    }

    final remaining = (maxWidth - fixedSum).clamp(0, maxWidth).toDouble();
    final totalFlex = flexCols.fold<double>(0, (s, c) => s + c.flex);

    if (remaining <= 0 || totalFlex <= 0) {
      // Không có không gian cho cột flex, sử dụng width cố định
      final result = {
        for (final c in cols)
          c.key: _finitePositive(preferStableWidth(c), c.width),
      };
      return result;
    }

    final Map<String, double> result = {
      for (final c in fixedCols)
        c.key: _finitePositive(preferStableWidth(c), c.width),
    };

    double acc = 0;
    for (int i = 0; i < flexCols.length; i++) {
      final c = flexCols[i];
      double w;
      if (i < flexCols.length - 1) {
        w = (remaining * (c.flex / totalFlex));
        w = w.floorToDouble();
        acc += w;
      } else {
        w = (remaining - acc).clamp(0, remaining);
      }
      result[c.key] = _finitePositive(w, c.width);
    }

    // Bảo đảm tất cả key đều có width (bao gồm cột không flex)
    for (final c in cols) {
      result.putIfAbsent(
        c.key,
        () => _finitePositive(preferStableWidth(c), c.width),
      );
    }

    return result;
  }

  double _finitePositive(double value, double fallback) {
    if (value.isFinite && value > 0) return value;
    if (fallback.isFinite && fallback > 0) return fallback;
    return 40; // min width mặc định tránh vô hạn/zero
  }

  /// Đường kẻ preview thể hiện vị trí resize cột khi người dùng kéo
  Widget _buildPreviewLine() {
    final tableState = ref.watch(widget.tableProvider);
    final columnsWidths = tableState.columnsState.widths;

    // Tính toán vị trí X của đường kẻ theo đúng thứ tự _columns
    double lineX = 0;
    for (int i = 0; i < _resizingColumnIndex; i++) {
      final key = _columns[i].key;
      final w =
          _lastComputedWidths[key] ?? columnsWidths[key] ?? _columns[i].width;
      lineX += w;
    }
    lineX += _previewWidth;

    // Trừ đi offset scroll ngang để đường kẻ hiển thị đúng vị trí
    final scrollOffset =
        _headerController.hasClients ? _headerController.offset : 0.0;
    lineX -= scrollOffset;

    return Positioned(
      left: lineX,
      top: 0,
      bottom: 12,
      child: DashedLine(
        axis: Axis.vertical,
        color: AppColor.textGrey,
        dashWidth: 6,
        dashSpace: 6,
        thickness: 2,
        width: 0.1,
      ),
    );
  }

  Widget _buildHorizontalScrollbar() {
    // Tạo fake content để có thể scroll
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

  /// Khởi tạo quá trình resize cột khi người dùng bắt đầu kéo handle
  void _startResizing(int columnIndex, double startX) {
    setState(() {
      _isResizing = true;
      _hoveredColumnIndex = -1; // Tắt hover khi bắt đầu resize
    });
    _resizingColumnIndex = columnIndex;
    _startDragX = startX;

    if (columnIndex < _columns.length) {
      final column = _columns[columnIndex];
      _resizingColumnKey = column.key;
      _initialColumnWidth = _lastComputedWidths[column.key] ?? column.width;
      _previewWidth = _initialColumnWidth; // Khởi tạo preview width
    }
  }

  /// Cập nhật độ rộng preview trong quá trình kéo cột
  void _updatePreviewWidth(double currentX) {
    if (_resizingColumnIndex == -1 || _resizingColumnKey == null) {
      return;
    }

    // Tính toán độ rộng preview dựa trên vị trí kéo
    double delta = currentX - _startDragX;
    double newWidth = _initialColumnWidth + delta;

    // Đảm bảo độ rộng tối thiểu hợp lý để dễ co giãn trên màn hẹp
    const double absoluteMinWidth = 120.0; // ngưỡng tối thiểu an toàn
    double minWidth = absoluteMinWidth;
    if (newWidth < minWidth) newWidth = minWidth;

    // Chỉ cập nhật preview width, không cập nhật thực tế
    setState(() {
      _previewWidth = newWidth;
    });
  }

  /// Hoàn tất quá trình resize cột và thực hiện phân phối không gian thông minh
  void _finishResizing() {
    if (_resizingColumnKey != null) {
      // Cập nhật kích thước thực tế khi thả chuột
      _isUpdatingAfterResize = true;
      ref
          .read(widget.tableProvider.notifier)
          .resizeColumn(_resizingColumnKey!, _previewWidth);

      // Pin cột để lần tính tiếp theo coi như fixed, giữ width người dùng vừa đặt
      _pinnedColumnKeys.add(_resizingColumnKey!);

      // Cập nhật _lastComputedWidths để giữ width đã resize
      _lastComputedWidths[_resizingColumnKey!] = _previewWidth;
    }

    setState(() {
      _resizingColumnIndex = -1;
      _resizingColumnKey = null;
      _previewWidth = 0;
      _isResizing = false; // Bật lại hover sau khi resize xong
      _hoveredColumnIndex = -1;
      _isUpdatingAfterResize = false; // Reset cờ cập nhật
    });
  }
}
