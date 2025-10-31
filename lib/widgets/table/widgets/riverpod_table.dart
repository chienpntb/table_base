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
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';

/// Bảng dữ liệu tổng quát dùng Riverpod để quản lý trạng thái
///
/// TÍNH NĂNG CHÍNH:
/// - Hiển thị dữ liệu dạng bảng với khả năng cuộn ngang/dọc
/// - Hỗ trợ resize cột với phân phối không gian thông minh
/// - Tích hợp sắp xếp, lọc, phân trang
/// - Hỗ trợ chọn nhiều hàng với checkbox
/// - Hiển thị cột actions (sửa/xóa) tùy chọn
///
/// TỐI ƯU HIỆU SUẤT:
/// - Tính toán độ rộng cột thông minh với flex layout
/// - Cache kết quả tính toán để tránh tính lại không cần thiết
/// - Đồng bộ hóa scroll giữa header và body
/// - Phân phối không gian tự động khi resize cột
class RiverpodTable<T> extends ConsumerStatefulWidget {
  /// Callback để tạo các ô cho một hàng từ một mục dữ liệu
  final List<TableCellData?> Function(T item)? cellsBuilder;

  /// Callback để lấy giá trị từ một mục theo cột
  final dynamic Function(T item, int columnIndex) valueGetter;

  /// Callback tạo TableCell theo key cột (ưu tiên cao nhất nếu cung cấp)
  final TableCellData? Function(T item, String key)? cellBuilderByKey;

  /// Callback lấy id từ item để chọn/bỏ chọn (kiểu động để tương thích)
  final dynamic Function(T item)? idGetter;

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

  const RiverpodTable({
    super.key,
    required this.valueGetter,
    required this.tableProvider,
    required this.columns,
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
    this.customActions, // Add this line to the initializer list
    this.showQuantityColumn = 16,
    this.rowHeight = 48,
    this.borderColor = Colors.grey,
    this.borderWidth = 1,
    this.headerHeight = 48,
    this.showPageSizeFilter = 100,
    this.maxHeight,
  });

  @override
  ConsumerState<RiverpodTable<T>> createState() => _RiverpodTableState<T>();
}

class _RiverpodTableState<T> extends ConsumerState<RiverpodTable<T>> {
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
  void didUpdateWidget(covariant RiverpodTable<T> oldWidget) {
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
                allData: tableState.paginationState.useApiPagination
                    ? tableState.currentPageData
                    : tableState.filteredData,
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
                      // Nội dung bảng
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
                        tableData: _createTableData(),
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

  /// Chuyển `state` hiện tại thành `TableData` cho `FlexibleTable`
  TableData _createTableData() {
    final tableState = ref.watch(widget.tableProvider);
    final notifier = ref.read(widget.tableProvider.notifier);
    // removed verbose build log
    // Tạo các hàng dữ liệu
    final dataRows = List<TableRowData>.generate(
      tableState.currentPageData.length,
      (index) {
        final item = tableState.currentPageData[index];

        // Kiểm tra xem mục này có được chọn không
        final dynamic itemId =
            widget.idGetter != null
                ? widget.idGetter!(item)
                : (item as dynamic).id;

        if (itemId is! String && itemId is! int) {
          print('Unsupported itemId type: ${itemId.runtimeType}');
        }

        final String? itemIdString = itemId?.toString();
        final bool isItemSelected =
            itemIdString != null &&
            tableState.selectionState.selectedIds
                .map((id) => id.toString())
                .contains(itemIdString);

        // Dựng lại danh sách ô theo đúng thứ tự hiển thị hiện tại của _columns
        final List<TableCellData?> cells = [];
        // Tối ưu: chỉ build cells một lần cho mỗi hàng nếu cần dùng
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
                  onChanged:
                      itemId == null
                          ? null
                          : (_) => notifier.toggleItemSelection(itemId),
                ),
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
                  customActions: widget.customActions, // Thêm dòng này
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

          // Fallback sang cellsBuilder theo vị trí (đã được cache ở trên)
          if (colIndex < builtCells.length) {
            cells.add(builtCells[colIndex]);
          } else {
            cells.add(TableCellData(widget: const SizedBox()));
          }
        }
        // Tạo hàng với các ô đã xử lý theo thứ tự cột hiện tại
        return TableRowData(cells: cells, isSelected: isItemSelected);
      },
    );

    final orderedWidths = _columns
        .map((c) => _lastComputedWidths[c.key] ?? c.width)
        .toList(growable: false);
    return TableData(
      rows: dataRows,
      columnWidths: orderedWidths,
      showAlternatingRowColors: widget.showAlternatingRowColors,
      alternateColor: widget.alternateColor ?? Colors.grey.shade100,
    );
  }

  /// Tính toán độ rộng cột thông minh với hệ thống flex layout
  ///
  /// LOGIC TÍNH TOÁN:
  /// 1. Ưu tiên sử dụng width từ provider nếu đã khởi tạo và không có cột flex
  /// 2. Tính tổng width của tất cả cột cố định (checkbox, actions, cột có flex <= 0)
  /// 3. Chia không gian còn lại cho các cột flex theo tỷ lệ
  /// 4. Đảm bảo tổng width không vượt quá maxWidth
  ///
  /// TỐI ƯU HIỆU SUẤT:
  /// - Cache kết quả để tránh tính lại không cần thiết
  /// - Sử dụng cờ _isUpdatingAfterResize để tránh tính toán liên tục
  /// - Tự động tính lại khi ẩn/hiện cột hoặc thay đổi kích thước màn hình
  Map<String, double> _computeColumnWidths(
    double maxWidth,
    Map<String, double> providerWidths,
  ) {
    // Chỉ sử dụng width từ provider khi đã khởi tạo và không có cột flex
    // Để đảm bảo tính toán lại khi ẩn/hiện cột hoặc thay đổi kích thước màn hình
    final hasFlexColumns = _columns.any((c) => c.flex > 0);

    // Sử dụng width từ provider khi đã khởi tạo và không có cột flex
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
      // Trường hợp maxWidth không hợp lệ: fallback sang tổng width hiện có hoặc width màn hình
      maxWidth = _columns
          .map((c) => providerWidths[c.key] ?? c.width)
          .fold<double>(0, (s, w) => s + w);
      if (!maxWidth.isFinite || maxWidth <= 0) {
        maxWidth = MediaQuery.of(context).size.width;
      }
    }

    final List<TableColumnData> cols = List<TableColumnData>.from(_columns);

    // Helper: prefer last computed (displayed) width when resizing, then provider width, then default width
    double preferStableWidth(TableColumnData c) {
      // Khi đang resize, ưu tiên width đang hiển thị (_lastComputedWidths) để giữ nguyên kích thước
      if (_isResizing) {
        final fromLast = _lastComputedWidths[c.key];
        if (fromLast != null && fromLast.isFinite && fromLast > 0) {
          return fromLast;
        }
      }

      // Khi có pinned columns, ưu tiên provider width (đã được cập nhật) cho cột đã pin
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
    // removed verbose log

    // Tổng width tất cả cột theo provider/default
    final double totalAllWidths = cols.fold<double>(0, (sum, c) {
      final v = preferStableWidth(c);
      return sum + ((v.isFinite && v > 0) ? v : c.width);
    });

    // Tiêu chí 2: Nếu tổng width của tất cả cột > maxWidth => không chia flex, dùng width sẵn có
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

  /// Tính toán độ rộng ban đầu của các cột để so sánh với trạng thái hiện tại
  ///
  /// MỤC ĐÍCH:
  /// - Cung cấp baseline width để quyết định có nên phân phối không gian hay không
  /// - Sử dụng width mặc định của cột thay vì dữ liệu đã bị thay đổi
  /// - Đảm bảo logic phân phối không gian chính xác khi ẩn/hiện cột
  ///
  /// KHÁC BIỆT VỚI _computeColumnWidths:
  /// - Không sử dụng _isResizing, _isUpdatingAfterResize
  /// - Luôn tính toán dựa trên width mặc định của cột
  /// - Không bị ảnh hưởng bởi trạng thái resize hiện tại
  Map<String, double> _computeOriginalWidths(double maxWidth) {
    final List<TableColumnData> cols = List<TableColumnData>.from(_columns);

    // Helper: sử dụng width mặc định của cột
    double getDefaultWidth(TableColumnData c) => c.width;

    // Quy ước: cột fixed là cột có flex <= 0, cột đặc biệt
    bool isFixed(TableColumnData c) =>
        c.flex <= 0 || c.key == 'checkbox' || c.key == 'actions';

    final fixedCols = cols.where(isFixed).toList();
    final flexCols = cols.where((c) => !isFixed(c)).toList();

    // Tổng width tất cả cột theo width mặc định
    final double totalAllWidths = cols.fold<double>(0, (sum, c) {
      final v = getDefaultWidth(c);
      return sum + ((v.isFinite && v > 0) ? v : c.width);
    });

    // Nếu tổng width của tất cả cột > maxWidth => không chia flex, dùng width sẵn có
    if (totalAllWidths > maxWidth) {
      return {
        for (final c in cols)
          c.key: _finitePositive(getDefaultWidth(c), c.width),
      };
    }

    // Nếu không có cột flex, cũng giữ nguyên width sẵn có
    if (flexCols.isEmpty) {
      return {
        for (final c in cols)
          c.key: _finitePositive(getDefaultWidth(c), c.width),
      };
    }

    // Tính phần còn lại để chia cho các cột flex
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

    // Bảo đảm tất cả key đều có width (bao gồm cột không flex)
    for (final c in cols) {
      result.putIfAbsent(
        c.key,
        () => _finitePositive(getDefaultWidth(c), c.width),
      );
    }

    return result;
  }

  /// Khởi tạo quá trình resize cột khi người dùng bắt đầu kéo handle
  ///
  /// THIẾT LẬP:
  /// - Lưu vị trí bắt đầu kéo và width ban đầu của cột
  /// - Đặt cờ _isResizing để tắt hover effect
  /// - Khởi tạo preview width để hiển thị đường kẻ dự đoán
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
  ///
  /// CHỨC NĂNG:
  /// - Tính toán width mới dựa trên vị trí chuột hiện tại
  /// - Đảm bảo width không nhỏ hơn ngưỡng tối thiểu
  /// - Chỉ cập nhật preview, không thay đổi width thực tế
  /// - Hiển thị đường kẻ dự đoán vị trí resize
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
  ///
  /// QUY TRÌNH XỬ LÝ:
  /// 1. Cập nhật width thực tế của cột được resize
  /// 2. Tính toán sự thay đổi width (widthDelta)
  /// 3. Nếu cột bị thu nhỏ (widthDelta < 0):
  ///    - Tính tổng width hiện tại và width ban đầu
  ///    - Nếu tổng width hiện tại <= width ban đầu: phân phối không gian
  /// 4. Pin cột để giữ width đã resize
  /// 5. Cập nhật cache để UI phản ánh ngay lập tức
  ///
  /// TỐI ƯU:
  /// - Sử dụng _isUpdatingAfterResize để tránh tính toán liên tục
  /// - Tính toán chính xác dựa trên cấu trúc cột hiện tại
  void _finishResizing() {
    final maxWidth =
        _maxWidth == 0 ? MediaQuery.of(context).size.width : _maxWidth;
    if (_resizingColumnKey != null) {
      // Tính toán sự thay đổi width
      final currentWidth = _lastComputedWidths[_resizingColumnKey!] ?? 0;
      final newWidth = _previewWidth;
      final widthDelta = newWidth - currentWidth;

      // Cập nhật kích thước thực tế khi thả chuột
      _isUpdatingAfterResize = true;
      ref
          .read(widget.tableProvider.notifier)
          .resizeColumn(_resizingColumnKey!, _previewWidth);

      // Nếu cột được thu nhỏ (widthDelta < 0), kiểm tra xem có cần phân phối không gian không
      if (widthDelta < 0) {
        // Tính tổng độ rộng hiện tại của các cột hiện tại (sau khi resize)
        double currentTotalWidth = 0.0;
        for (final col in _columns) {
          final currentWidth = _lastComputedWidths[col.key] ?? col.width;
          if (col.key == _resizingColumnKey) {
            currentTotalWidth += _previewWidth; // Sử dụng width mới
          } else {
            currentTotalWidth += currentWidth;
          }
        }

        // Tính tổng độ rộng ban đầu của các cột hiện tại bằng cách tính toán lại
        // Sử dụng logic tương tự như _computeColumnWidths nhưng không có resize
        final originalWidths = _computeOriginalWidths(maxWidth);

        double originalTotalWidth = 0.0;
        for (final col in _columns) {
          originalTotalWidth += originalWidths[col.key] ?? col.width;
        }

        // Chỉ phân phối không gian nếu tổng độ rộng hiện tại <= độ rộng ban đầu của bảng
        if (currentTotalWidth <= originalTotalWidth) {
          final double deficit = (originalTotalWidth - currentTotalWidth).clamp(
            0,
            double.infinity,
          );
          _redistributeSpaceToRightColumns(_resizingColumnKey!, deficit);
        }
      }

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

  /// Phân phối không gian thông minh cho các cột khác khi một cột được thu nhỏ
  ///
  /// CHIẾN LƯỢC PHÂN PHỐI:
  /// 1. Tìm cột đích ưu tiên: cột bên phải cột được resize
  /// 2. Nếu không có cột bên phải: tìm cột bên trái
  /// 3. Chỉ phân phối cho cột có thể resize (isResizable = true)
  /// 4. Loại trừ cột đặc biệt (checkbox, actions)
  ///
  /// TỐI ƯU:
  /// - Chỉ tìm trong danh sách cột hiện tại (không bao gồm cột đã ẩn)
  /// - Pin cột đích để giữ width đã phân phối
  /// - Cập nhật cache để UI phản ánh ngay lập tức
  void _redistributeSpaceToRightColumns(
    String resizedColumnKey,
    double availableSpace,
  ) {
    // Tìm vị trí của cột được resize trong danh sách cột hiện tại
    final resizedColumnIndex = _columns.indexWhere(
      (c) => c.key == resizedColumnKey,
    );

    if (resizedColumnIndex == -1) {
      return;
    }

    // Tìm cột ngay bên phải (không phải cột đặc biệt và có thể resize)
    TableColumnData? targetColumn;
    for (int i = resizedColumnIndex + 1; i < _columns.length; i++) {
      final column = _columns[i];

      if (column.key != 'checkbox' &&
          column.key != 'actions' &&
          column.isResizable) {
        targetColumn = column;
        break;
      }
    }

    // Nếu không có cột bên phải, tìm cột bên trái (không phải cột đặc biệt và có thể resize)
    if (targetColumn == null) {
      for (int i = resizedColumnIndex - 1; i >= 0; i--) {
        final column = _columns[i];

        if (column.key != 'checkbox' &&
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

    // Lấy width hiện tại của cột đích
    final currentWidth =
        _lastComputedWidths[targetColumn.key] ?? targetColumn.width;
    final newWidth = currentWidth + availableSpace;

    // Cập nhật width cho cột đích và pin nó (nếu chưa pin)
    ref
        .read(widget.tableProvider.notifier)
        .resizeColumn(targetColumn.key, newWidth);
    if (!_pinnedColumnKeys.contains(targetColumn.key)) {
      _pinnedColumnKeys.add(targetColumn.key);
    }
    // Cập nhật cache hiển thị để UI phản ánh ngay width mới
    _lastComputedWidths[targetColumn.key] = newWidth;
  }
}
