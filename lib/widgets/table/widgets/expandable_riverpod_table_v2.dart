import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/dashed_line.dart';
import 'package:table_base/widgets/table/widgets/filter_menu_widget.dart';
import 'package:table_base/widgets/table/widgets/pagination_bar.dart';
import 'package:table_base/widgets/table/widgets/table_actions_widget.dart';
import 'package:table_base/widgets/table/widgets/table_content_widget.dart';
import 'package:table_base/widgets/table/widgets/table_header_widget.dart';
import '../models/table_model.dart';
import '../models/expandable_table_model.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';

/// Bảng dữ liệu có thể expand với table con - Clone từ RiverpodTable
///
/// TÍNH NĂNG CHÍNH:
/// - Hiển thị dữ liệu dạng bảng với khả năng cuộn ngang/dọc
/// - Hỗ trợ resize cột với phân phối không gian thông minh
/// - Tích hợp sắp xếp, lọc, phân trang
/// - Hỗ trợ chọn nhiều hàng với checkbox
/// - Hiển thị cột actions (sửa/xóa) tùy chọn
/// - EXPANDABLE: Hỗ trợ expand/collapse rows với table con
///
/// TỐI ƯU HIỆU SUẤT:
/// - Tính toán độ rộng cột thông minh với flex layout
/// - Cache kết quả tính toán để tránh tính lại không cần thiết
/// - Đồng bộ hóa scroll giữa header và body
/// - Phân phối không gian tự động khi resize cột
class ExpandableRiverpodTable<T, C> extends ConsumerStatefulWidget {
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

  /// Callback tạo TableCell theo key cột (ưu tiên cao nhất nếu cung cấp)
  final TableCellData? Function(T item, String key)? cellBuilderByKey;

  /// Callback lấy id từ item để chọn/bỏ chọn (kiểu động để tương thích)
  final dynamic Function(T item)? idGetter;

  /// Callback khi checkbox được thay đổi
  final void Function(T item, bool isSelected)? onCheckboxChanged;

  /// Callback để kiểm tra item có được chọn không
  final bool Function(T item)? isItemSelected;

  /// Provider để quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  >
  tableProvider;

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

  // Màu khi chọn hàng
  final Color? selectedRowColor;

  /// Màu cho header
  final Color? headerColor;

  /// Màu text cho header
  final Color textHeaderColor;

  /// Widget hiển thị khi có lỗi
  final Widget? errorWidget;

  /// Widget hiển thị khi không có dữ liệu
  final Widget? emptyWidget;

  final Color borderColor; // Màu viền bảng

  final double borderWidth; // Độ rộng viền bảng

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
    this.onCheckboxChanged,
    this.isItemSelected,
  });

  @override
  ConsumerState<ExpandableRiverpodTable<T, C>> createState() => _ExpandableRiverpodTableState<T, C>();
}

class _ExpandableRiverpodTableState<T, C> extends ConsumerState<ExpandableRiverpodTable<T, C>> {
  final ScrollController _headerController = ScrollController();
  final ScrollController _bodyController = ScrollController();
  final ScrollController _scrollbarController = ScrollController();

  /// Controller cuộn dọc cho nội dung bảng
  final ScrollController verticalScrollController = ScrollController();

  /// Danh sách cấu hình các cột (bao gồm cả cột checkbox nếu có)
  List<TableColumnData> _columns = [];

  /// Lưu độ rộng đã tính cuối cùng theo key để dùng cho resize (bao gồm cả flex)
  Map<String, double> _lastComputedWidths = {};

  /// Lưu độ rộng ban đầu theo key để dùng cho resize
  Map<String, double> _initialComputedWidths = {};

  /// Các cột đã được người dùng resize sẽ bị "pin" thành fixed để giữ width
  final Set<String> _pinnedColumnKeys = <String>{};

  /// Cờ báo hiệu đang cuộn header
  bool isScrolling1 = false;

  /// Cờ báo hiệu đang cuộn nội dung
  bool isScrolling2 = false;

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

  /// Cờ báo hiệu đang trong quá trình cập nhật sau resize để tránh tính toán liên tục
  bool _isUpdatingAfterResize = false;

  double _maxWidth = 0;

  /// EXPANDABLE: Set các row đang được expand
  final Set<String> _expandedRows = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    // Khởi tạo bảng với các thông số ban đầu
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

    // EXPANDABLE: Thêm cột expand
    _columns.add(
      TableColumnData(
        name: 'expand',
        key: 'expand',
        width: 60, // Tăng width lên 60 để tránh overflow
        isResizable: false,
        isSortable: false,
        isFilterable: false,
      ),
    );

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

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _scrollbarController.dispose();

    super.dispose();
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
                    children: [
                      // Header của bảng
                      TableHeaderWidget<T>(
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
                        onColumnHover:
                            (index) =>
                                setState(() => _hoveredColumnIndex = index),
                        onColumnHoverExit:
                            () => setState(() => _hoveredColumnIndex = -1),
                        hoveredColumnIndex: _hoveredColumnIndex,
                        isResizing: _isResizing,
                        onStartResizing: _startResizing,
                        onUpdatePreviewWidth: _updatePreviewWidth,
                        onFinishResizing: _finishResizing,
                      ),
                      // Nội dung bảng - Sử dụng TableContentWidget như table cũ
                      TableContentWidget<T>(
                        tableProvider: widget.tableProvider,
                        showQuantityColumn: widget.showQuantityColumn,
                        maxHeight: widget.maxHeight,
                        rowHeight: widget.rowHeight,
                        cellPadding: widget.cellPadding,
                        cellDecoration: widget.cellDecoration,
                        hoverColor: widget.hoverColor,
                        selectedRowColor: widget.selectedRowColor,
                        enableRowHover: widget.enableRowHover,
                        enableRowSelection: widget.enableRowSelection,
                        errorWidget: widget.errorWidget,
                        emptyWidget: widget.emptyWidget,
                        onRowTap: widget.onRowTap,
                        tableData: _createExpandableTableData(),
                        bodyController: _bodyController,
                        verticalScrollController: verticalScrollController,
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

  /// EXPANDABLE: Tạo TableData cho expandable table
  TableData _createExpandableTableData() {
    final tableState = ref.watch(widget.tableProvider);
    final notifier = ref.read(widget.tableProvider.notifier);
    
    // Tạo các hàng dữ liệu với expandable functionality
    final dataRows = List<TableRowData>.generate(
      tableState.currentPageData.length,
      (index) {
        final item = tableState.currentPageData[index];
        final itemId = _getItemId(item);
        final isExpanded = _expandedRows.contains(itemId);
        final childData = widget.childDataGetter(item);
        final hasChildren = childData != null && childData.isNotEmpty;

        // Kiểm tra xem mục này có được chọn không
        final dynamic itemIdObj = widget.idGetter != null
            ? widget.idGetter!(item)
            : (item is Map ? item['id'] : (item as dynamic).id);

        final String? itemIdString = itemIdObj?.toString();
        final bool isItemSelected =
            itemIdString != null &&
            tableState.selectionState.selectedIds
                .map((id) => id.toString())
                .contains(itemIdString);

        // Dựng lại danh sách ô theo đúng thứ tự hiển thị hiện tại của _columns
        final List<TableCellData?> cells = [];
        final List<TableCellData?> builtCells =
            widget.cellsBuilder != null ? widget.cellsBuilder!(item) : [];

        for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
          final column = _columns[colIndex];

          // Cột checkbox
          if (widget.showCheckboxColumn && column.key == 'checkbox') {
            cells.add(
              TableCellData(
                widget: Checkbox(
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
                  onChanged: itemIdObj == null
                      ? null
                      : (_) => notifier.toggleItemSelection(itemIdObj),
                ),
              ),
            );
            continue;
          }

          // Cột expand
          if (column.key == 'expand') {
            cells.add(
              TableCellData(
                widget: hasChildren
                    ? IconButton(
                        icon: Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                        onPressed: () => _toggleExpand(itemId),
                      )
                    : const SizedBox(),
              ),
            );
            continue;
          }

          // Cột actions
          if (widget.showActionsColumn && column.key == 'actions') {
            cells.add(
              TableCellData(
                widget: TableActionsWidget<T>(
                  item: item,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                  customActions: widget.customActions,
                ),
              ),
            );
            continue;
          }

          if (widget.cellBuilderByKey != null) {
            final customCell = widget.cellBuilderByKey!(item, column.key);
            if (customCell != null) {
              cells.add(customCell);
              continue;
            }
          }

          // Fallback sang cellsBuilder theo vị trí
          if (colIndex < builtCells.length) {
            cells.add(builtCells[colIndex]);
          } else {
            cells.add(TableCellData(widget: const SizedBox()));
          }
        }

        // Tạo hàng với các ô đã xử lý
        return TableRowData(cells: cells, isSelected: isItemSelected);
      },
    );

    // Kết hợp parent rows và child rows
    final allRows = <TableRowData>[];
    for (int i = 0; i < dataRows.length; i++) {
      allRows.add(dataRows[i]);
      
      // Thêm child rows nếu item được expand
      final item = tableState.currentPageData[i];
      final itemId = _getItemId(item);
      if (_expandedRows.contains(itemId)) {
        final childData = widget.childDataGetter(item);
        print('Expanded item $itemId has ${childData?.length ?? 0} child items');
        if (childData != null && childData.isNotEmpty) {
          // Thêm child table header
          allRows.add(_createChildTableHeader());
          
          // Tạo một child row cho mỗi child item
          for (final childItem in childData) {
            allRows.add(_createChildTableRow(item, [childItem]));
          }
        }
      }
    }

    final orderedWidths = _columns
        .map((c) => _lastComputedWidths[c.key] ?? c.width)
        .toList(growable: false);
    
    return TableData(
      rows: allRows,
      columnWidths: orderedWidths,
      showAlternatingRowColors: widget.showAlternatingRowColors,
      alternateColor: widget.alternateColor ?? Colors.grey.shade100,
    );
  }

  /// EXPANDABLE: Tạo child table header
  TableRowData _createChildTableHeader() {
    final cells = <TableCellData?>[];
    
    // Tạo cells cho tất cả columns
    for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
      final column = _columns[colIndex];
      
      if (column.key == 'checkbox') {
        // Empty cell cho checkbox column
        cells.add(TableCellData(widget: const SizedBox()));
      } else if (column.key == 'expand') {
        // Empty cell cho expand column
        cells.add(TableCellData(widget: const SizedBox()));
      } else if (column.key == 'actions') {
        // Empty cell cho actions column
        cells.add(TableCellData(widget: const SizedBox()));
      } else {
        // Child header cell - tìm child column tương ứng
        final childColumnIndex = _findChildColumnIndex(colIndex);
        if (childColumnIndex >= 0 && childColumnIndex < widget.childColumns.length) {
          final childColumn = widget.childColumns[childColumnIndex];
          
          cells.add(TableCellData(
            widget: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                border: Border.all(color: Colors.green.shade400),
              ),
              child: Text(
                childColumn.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.green,
                ),
              ),
            ),
          ));
        } else {
          // Empty cell nếu không có child column tương ứng
          cells.add(TableCellData(widget: const SizedBox()));
        }
      }
    }
    
    return TableRowData(
      cells: cells,
    );
  }

  /// EXPANDABLE: Tạo child table row
  TableRowData _createChildTableRow(T parentItem, List<C> childData) {
    final cells = <TableCellData?>[];
    final childItem = childData.first; // Lấy child item đầu tiên
    
    // Tạo cells cho tất cả columns
    for (int colIndex = 0; colIndex < _columns.length; colIndex++) {
      final column = _columns[colIndex];
      
      if (column.key == 'checkbox') {
        // Empty cell cho checkbox column
        cells.add(TableCellData(widget: const SizedBox()));
      } else if (column.key == 'expand') {
        // Empty cell cho expand column với width 60
        cells.add(TableCellData(
          widget: Container(
            width: 60,
            child: const SizedBox(),
          ),
        ));
      } else if (column.key == 'actions') {
        // Empty cell cho actions column
        cells.add(TableCellData(widget: const SizedBox()));
      } else {
        // Child data cell - tìm child column tương ứng
        final childColumnIndex = _findChildColumnIndex(colIndex);
        print('Column ${column.key} -> child column index: $childColumnIndex');
        if (childColumnIndex >= 0 && childColumnIndex < widget.childColumns.length) {
          final childColumn = widget.childColumns[childColumnIndex];
          print('Using child column: ${childColumn.key} (${childColumn.name})');
          
          final cellValue = _getChildValue(childItem, childColumn.key);
          print('Child cell value for ${childColumn.key}: $cellValue');
          
          if (widget.childCellBuilder != null) {
            final customCell = widget.childCellBuilder!(childItem, childColumn.key);
            if (customCell != null) {
              cells.add(customCell);
            } else {
              cells.add(_createDefaultChildCell(childItem, childColumn));
            }
          } else {
            cells.add(_createDefaultChildCell(childItem, childColumn));
          }
        } else {
          // Empty cell nếu không có child column tương ứng
          print('No child column for ${column.key}, adding empty cell');
          cells.add(TableCellData(widget: const SizedBox()));
        }
      }
    }
    
    print('Created child row with ${cells.length} cells');
    return TableRowData(
      cells: cells,
    );
  }

  /// Tìm index của child column tương ứng với parent column
  int _findChildColumnIndex(int parentColumnIndex) {
    int childIndex = 0;
    
    for (int i = 0; i < _columns.length; i++) {
      final column = _columns[i];
      
      // Skip special columns
      if (column.key == 'checkbox' || column.key == 'expand' || column.key == 'actions') {
        if (i == parentColumnIndex) {
          return -1; // Không có child column tương ứng
        }
        continue;
      }
      
      // Đây là data column
      if (i == parentColumnIndex) {
        print('Found data column at index $i, child index: $childIndex');
        return childIndex;
      }
      
      // Tăng childIndex cho mỗi data column
      childIndex++;
    }
    
    print('No matching child column found for parent column index $parentColumnIndex');
    return -1;
  }

  /// Tạo default child cell
  TableCellData _createDefaultChildCell(C childItem, TableColumnData childColumn) {
    final value = _getChildValue(childItem, childColumn.key);
    
    return TableCellData(
      widget: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      alignment: Alignment.centerLeft,
    );
  }

  /// Lấy giá trị từ child item
  String _getChildValue(C childItem, String key) {
    try {
      final dynamic item = childItem;
      if (item is Map) {
        final value = item[key]?.toString() ?? '';
        print('Child value for key $key: $value');
        return value;
      }
      final dynamic value = (item as dynamic)[key];
      final result = value?.toString() ?? '';
      print('Child value for key $key: $result');
      return result;
    } catch (e) {
      print('Error getting child value for key $key: $e');
      return '';
    }
  }


  /// EXPANDABLE: Toggle expand state
  void _toggleExpand(String itemId) {
    setState(() {
      if (_expandedRows.contains(itemId)) {
        _expandedRows.remove(itemId);
        print('Collapsed item: $itemId');
      } else {
        _expandedRows.add(itemId);
        print('Expanded item: $itemId');
      }
    });
    print('Current expanded rows: $_expandedRows');
  }

  /// Lấy item ID
  String _getItemId(T item) {
    if (widget.idGetter != null) {
      return widget.idGetter!(item)?.toString() ?? '';
    }
    
    try {
      final dynamic itemObj = item;
      if (itemObj is Map) {
        return itemObj['id']?.toString() ?? item.hashCode.toString();
      }
      return (itemObj as dynamic).id?.toString() ?? item.hashCode.toString();
    } catch (e) {
      return item.hashCode.toString();
    }
  }

  // ===== TẤT CẢ CÁC METHOD KHÁC GIỮ NGUYÊN TỪ RIVERPODTABLE =====
  // (Tôi sẽ copy toàn bộ logic từ RiverpodTable để đảm bảo hoạt động giống hệt)

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
        maxWidth = MediaQuery.of(context).size.width;
      }
    }

    final List<TableColumnData> cols = List<TableColumnData>.from(_columns);

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

    bool isFixed(TableColumnData c) =>
        c.flex <= 0 ||
        c.key == 'checkbox' ||
        c.key == 'expand' || // EXPANDABLE: Thêm expand column
        c.key == 'actions' ||
        _pinnedColumnKeys.contains(c.key);

    final fixedCols = cols.where(isFixed).toList();
    final flexCols = cols.where((c) => !isFixed(c)).toList();

    if (_isResizing) {
      final result = {for (final c in cols) c.key: preferStableWidth(c)};
      return result;
    }

    final double totalAllWidths = cols.fold<double>(0, (sum, c) {
      final v = preferStableWidth(c);
      return sum + ((v.isFinite && v > 0) ? v : c.width);
    });

    if (totalAllWidths > maxWidth) {
      final result = <String, double>{};
      for (final c in cols) {
        final width = preferStableWidth(c);
        result[c.key] = _finitePositive(width, c.width);
      }
      return result;
    }

    if (flexCols.isEmpty) {
      final result = {
        for (final c in cols)
          c.key: _finitePositive(preferStableWidth(c), c.width),
      };
      return result;
    }

    double fixedSum = 0;
    for (final c in fixedCols) {
      final v = preferStableWidth(c);
      fixedSum += (v.isFinite && v > 0) ? v : c.width;
    }

    final remaining = (maxWidth - fixedSum).clamp(0, maxWidth).toDouble();
    final totalFlex = flexCols.fold<double>(0, (s, c) => s + c.flex);

    if (remaining <= 0 || totalFlex <= 0) {
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
    return 40;
  }

  Map<String, double> _computeOriginalWidths(double maxWidth) {
    final List<TableColumnData> cols = List<TableColumnData>.from(_columns);

    double getDefaultWidth(TableColumnData c) => c.width;

    bool isFixed(TableColumnData c) =>
        c.flex <= 0 || c.key == 'checkbox' || c.key == 'expand' || c.key == 'actions';

    final fixedCols = cols.where(isFixed).toList();
    final flexCols = cols.where((c) => !isFixed(c)).toList();

    final double totalAllWidths = cols.fold<double>(0, (sum, c) {
      final v = getDefaultWidth(c);
      return sum + ((v.isFinite && v > 0) ? v : c.width);
    });

    if (totalAllWidths > maxWidth) {
      return {
        for (final c in cols)
          c.key: _finitePositive(getDefaultWidth(c), c.width),
      };
    }

    if (flexCols.isEmpty) {
      return {
        for (final c in cols)
          c.key: _finitePositive(getDefaultWidth(c), c.width),
      };
    }

    double fixedSum = 0;
    for (final c in fixedCols) {
      final v = getDefaultWidth(c);
      fixedSum += (v.isFinite && v > 0) ? v : c.width;
    }

    final remaining = (maxWidth - fixedSum).clamp(0, maxWidth).toDouble();
    final totalFlex = flexCols.fold<double>(0, (s, c) => s + c.flex);

    if (remaining <= 0 || totalFlex <= 0) {
      return {
        for (final c in cols)
          c.key: _finitePositive(getDefaultWidth(c), c.width),
      };
    }

    final Map<String, double> result = {
      for (final c in fixedCols)
        c.key: _finitePositive(getDefaultWidth(c), c.width),
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

    for (final c in cols) {
      result.putIfAbsent(
        c.key,
        () => _finitePositive(getDefaultWidth(c), c.width),
      );
    }

    return result;
  }

  void _startResizing(int columnIndex, double startX) {
    setState(() {
      _isResizing = true;
      _hoveredColumnIndex = -1;
    });
    _resizingColumnIndex = columnIndex;
    _startDragX = startX;

    if (columnIndex < _columns.length) {
      final column = _columns[columnIndex];
      _resizingColumnKey = column.key;
      _initialColumnWidth = _lastComputedWidths[column.key] ?? column.width;
      _previewWidth = _initialColumnWidth;
    }
  }

  void _updatePreviewWidth(double currentX) {
    if (_resizingColumnIndex == -1 || _resizingColumnKey == null) {
      return;
    }

    double delta = currentX - _startDragX;
    double newWidth = _initialColumnWidth + delta;

    const double absoluteMinWidth = 120.0;
    double minWidth = absoluteMinWidth;
    if (newWidth < minWidth) newWidth = minWidth;

    setState(() {
      _previewWidth = newWidth;
    });
  }

  void _finishResizing() {
    final maxWidth =
        _maxWidth == 0 ? MediaQuery.of(context).size.width : _maxWidth;
    if (_resizingColumnKey != null) {
      final currentWidth = _lastComputedWidths[_resizingColumnKey!] ?? 0;
      final newWidth = _previewWidth;
      final widthDelta = newWidth - currentWidth;

      _isUpdatingAfterResize = true;
      ref
          .read(widget.tableProvider.notifier)
          .resizeColumn(_resizingColumnKey!, _previewWidth);

      if (widthDelta < 0) {
        double currentTotalWidth = 0.0;
        for (final col in _columns) {
          final currentWidth = _lastComputedWidths[col.key] ?? col.width;
          if (col.key == _resizingColumnKey) {
            currentTotalWidth += _previewWidth;
          } else {
            currentTotalWidth += currentWidth;
          }
        }

        final originalWidths = _computeOriginalWidths(maxWidth);

        double originalTotalWidth = 0.0;
        for (final col in _columns) {
          originalTotalWidth += originalWidths[col.key] ?? col.width;
        }

        if (currentTotalWidth <= originalTotalWidth) {
          final double deficit = (originalTotalWidth - currentTotalWidth).clamp(
            0,
            double.infinity,
          );
          _redistributeSpaceToRightColumns(_resizingColumnKey!, deficit);
        }
      }

      _pinnedColumnKeys.add(_resizingColumnKey!);
      _lastComputedWidths[_resizingColumnKey!] = _previewWidth;
    }

    setState(() {
      _resizingColumnIndex = -1;
      _resizingColumnKey = null;
      _previewWidth = 0;
      _isResizing = false;
      _hoveredColumnIndex = -1;
      _isUpdatingAfterResize = false;
    });
  }

  void _redistributeSpaceToRightColumns(
    String resizedColumnKey,
    double availableSpace,
  ) {
    final resizedColumnIndex = _columns.indexWhere(
      (c) => c.key == resizedColumnKey,
    );

    if (resizedColumnIndex == -1) {
      return;
    }

    TableColumnData? targetColumn;
    for (int i = resizedColumnIndex + 1; i < _columns.length; i++) {
      final column = _columns[i];

      if (column.key != 'checkbox' &&
          column.key != 'expand' &&
          column.key != 'actions' &&
          column.isResizable) {
        targetColumn = column;
        break;
      }
    }

    if (targetColumn == null) {
      for (int i = resizedColumnIndex - 1; i >= 0; i--) {
        final column = _columns[i];

        if (column.key != 'checkbox' &&
            column.key != 'expand' &&
            column.key != 'actions' &&
            column.isResizable) {
          targetColumn = column;
          break;
        }
      }
    }

    if (targetColumn == null || availableSpace <= 0) {
      return;
    }

    final currentWidth =
        _lastComputedWidths[targetColumn.key] ?? targetColumn.width;
    final newWidth = currentWidth + availableSpace;

    ref
        .read(widget.tableProvider.notifier)
        .resizeColumn(targetColumn.key, newWidth);
    if (!_pinnedColumnKeys.contains(targetColumn.key)) {
      _pinnedColumnKeys.add(targetColumn.key);
    }
    _lastComputedWidths[targetColumn.key] = newWidth;
  }
}
