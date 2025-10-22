import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/widgets/table_actions_widget.dart';
import '../models/table_model.dart';
import '../models/expandable_table_model.dart';
import '../providers/table_state.dart';
import '../providers/table_notifier_interface.dart';

/// Bảng dữ liệu expandable dựa trên RiverpodTable với tất cả tính năng của table cũ
///
/// TÍNH NĂNG CHÍNH:
/// - Tất cả tính năng của RiverpodTable (resize, sort, filter, pagination, ...)
/// - Thêm tính năng expand/collapse để hiển thị child table
/// - Preserve scroll position khi expand/collapse
/// - Quản lý state expandable một cách thông minh
class ExpandableRiverpodTableV2<T, C> extends ConsumerStatefulWidget {
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

  /// Provider để quản lý trạng thái bảng
  final AutoDisposeStateNotifierProvider<
    TableNotifierInterface<T>,
    GenericTableState<T>
  > tableProvider;

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

  const ExpandableRiverpodTableV2({
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
  ConsumerState<ExpandableRiverpodTableV2<T, C>> createState() => 
      _ExpandableRiverpodTableV2State<T, C>();
}

class _ExpandableRiverpodTableV2State<T, C> extends ConsumerState<ExpandableRiverpodTableV2<T, C>> {
  /// Set các row đang được expand - TÍNH NĂNG MỚI
  final Set<String> _expandedRows = <String>{};
  
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

  /// Thiết lập các listener để đồng bộ hóa scroll ngang giữa header và nội dung
  void _onInitListener() {
    _syncControllers(_headerController, [_bodyController, _scrollbarController]);
    _syncControllers(_bodyController, [_headerController, _scrollbarController]);
    _syncControllers(_scrollbarController, [_headerController, _bodyController]);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset flag khi kích thước màn hình thay đổi để tính toán lại
    _hasInitializedWidths = false;
  }

  @override
  void didUpdateWidget(covariant ExpandableRiverpodTableV2<T, C> oldWidget) {
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
      _initializeColumns();

      // Reset tính toán width
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final columnWidths = _columns.fold<Map<String, double>>(
          {},
          (map, column) => map..[column.key] = column.width,
        );
        ref.read(widget.tableProvider.notifier).updateWidths(columnWidths);
      });

      // Reset flag để tính toán lại
      _hasInitializedWidths = false;

      // Clear cache để rebuild UI
      if (mounted) setState(() {});
    }
  }

  /// Khởi tạo danh sách cột theo cấu hình và thêm các cột đặc biệt (checkbox/actions)
  /// TÍNH NĂNG MỚI: Thêm cột expand/collapse
  void _initializeColumns() {
    _columns = [];

    // Thêm cột expand/collapse đầu tiên - TÍNH NĂNG MỚI
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
    for (int i = 0; i < widget.columns.length; i++) {
      _columns.add(widget.columns[i]);
    }

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
  Widget build(BuildContext context) {
    final tableState = ref.watch(widget.tableProvider);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        
        return Stack(
          children: [
            Column(
              children: [
                // Header sẽ được implement sau với resize support
                Container(
                  height: widget.headerHeight,
                  color: widget.headerColor,
                  child: Row(
                    children: [
                      for (int i = 0; i < _columns.length; i++) ...[
                        Container(
                          width: _lastComputedWidths[_columns[i].key] ?? _columns[i].width,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _columns[i].name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Resize handle
                              if (widget.enableColumnResize && i < _columns.length - 1)
                                GestureDetector(
                                  onPanStart: (details) {
                                    _startResizing(i, details.globalPosition.dx);
                                  },
                                  onPanUpdate: (details) {
                                    _updatePreviewWidth(details.globalPosition.dx);
                                  },
                                  onPanEnd: (details) {
                                    _finishResizing();
                                  },
                                  child: Container(
                                    width: 8,
                                    height: double.infinity,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Content với expandable support
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: tableState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : tableState.currentPageData.isEmpty
                            ? const Center(child: Text('Không có dữ liệu'))
                            : SingleChildScrollView(
                                controller: verticalScrollController,
                                child: Column(
                                  children: [
                                    for (int index = 0; index < tableState.currentPageData.length; index++) ...[
                                      _buildExpandableRow(tableState.currentPageData[index], index),
                                    ],
                                  ],
                                ),
                              ),
                  ),
                ),
                
                // Pagination sẽ được implement sau
                if (tableState.paginationState.totalPages > 1)
                  Container(
                    height: 50,
                    color: Colors.grey[200],
                    child: Center(
                      child: Text(
                        'Page ${tableState.paginationState.currentPage + 1} of ${tableState.paginationState.totalPages}',
                      ),
                    ),
                  ),
              ],
            ),
            
            // Preview line khi resize
            if (_isResizing && _previewWidth > 0)
              Positioned(
                left: _previewWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.blue.shade400,
                ),
              ),
          ],
        );
      },
    );
  }

  /// TÍNH NĂNG MỚI: Build expandable row với expand/collapse support
  Widget _buildExpandableRow(dynamic item, int index) {
    final itemId = _getItemId(item);
    final isExpanded = _expandedRows.contains(itemId);
    final childData = widget.childDataGetter(item);
    final hasChildren = childData?.isNotEmpty ?? false;

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
              for (int i = 0; i < _columns.length; i++) ...[
                Container(
                  width: _lastComputedWidths[_columns[i].key] ?? _columns[i].width,
                  padding: const EdgeInsets.all(8),
                  child: _buildCellContent(item, _columns[i], i, hasChildren, isExpanded, itemId),
                ),
              ],
            ],
          ),
        ),
        
        // Child rows nếu đang expand
        if (isExpanded && hasChildren && childData != null) ...[
          Container(
            margin: const EdgeInsets.only(left: 40),
            child: Column(
              children: [
                for (final childItem in childData)
                  Container(
                    height: widget.rowHeight * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        for (int i = 1; i < _columns.length; i++) ...[
                          Container(
                            width: _lastComputedWidths[_columns[i].key] ?? _columns[i].width,
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              'Child: ${childItem.toString()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build nội dung cell với expand/collapse support
  Widget _buildCellContent(dynamic item, TableColumnData column, int columnIndex, bool hasChildren, bool isExpanded, String itemId) {
    if (column.key == 'expand') {
      // Cột expand/collapse
      return hasChildren
          ? IconButton(
              icon: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 20,
              ),
              onPressed: () => _toggleExpand(itemId),
            )
          : const SizedBox.shrink();
    }
    
    // Các cột khác - sử dụng valueGetter hoặc fallback
    final value = widget.valueGetter(item, columnIndex);
    
    return Text(
      value?.toString() ?? '',
      style: const TextStyle(fontSize: 14),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _scrollbarController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  /// Bắt đầu quá trình resize cột - Copy từ RiverpodTable
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

  /// Cập nhật độ rộng preview trong quá trình kéo cột - Copy từ RiverpodTable
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

  /// Hoàn tất quá trình resize cột - Copy từ RiverpodTable
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

  /// TÍNH NĂNG MỚI: Toggle expand/collapse row
  void _toggleExpand(String itemId) {
    setState(() {
      if (_expandedRows.contains(itemId)) {
        _expandedRows.remove(itemId);
      } else {
        _expandedRows.add(itemId);
      }
    });
  }

  /// TÍNH NĂNG MỚI: Lấy ID của item để quản lý expand state
  String _getItemId(dynamic item) {
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