import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/models/expandable_table_model.dart';
import 'package:table_base/widgets/table/widgets/expandable_table_content_widget.dart';
import 'package:table_base/widgets/table/widgets/table_header_widget.dart';
import 'package:table_base/widgets/table/widgets/pagination_bar.dart';
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
  /// Controllers cho scroll
  final ScrollController _headerController = ScrollController();
  final ScrollController _bodyController = ScrollController();
  final ScrollController _scrollbarController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  
  /// Danh sách cấu hình các cột (bao gồm cả cột checkbox nếu có)
  List<TableColumnData> _columns = [];
  
  /// Lưu độ rộng đã tính cuối cùng theo key để dùng cho resize
  Map<String, double> _lastComputedWidths = {};

  @override
  void initState() {
    super.initState();
    _initializeColumns();
    _syncControllers();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    _scrollbarController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  /// Khởi tạo danh sách cột theo cấu hình và thêm các cột đặc biệt
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

    // Thêm cột expand nếu có child data
    _columns.add(
      TableColumnData(
        name: 'expand',
        key: 'expand',
        width: 40,
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

  /// Đồng bộ hóa scroll giữa header và body
  void _syncControllers() {
    _headerController.addListener(() {
      if (_bodyController.hasClients) {
        _bodyController.jumpTo(_headerController.offset);
      }
    });
    _bodyController.addListener(() {
      if (_headerController.hasClients) {
        _headerController.jumpTo(_bodyController.offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
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
                      onSort: (index) {}, // Disable sort for expandable
                      onShowFilterMenu: (name, index, position) async {}, // Disable filter
                      onColumnHover: (index) {},
                      onColumnHoverExit: () {},
                      hoveredColumnIndex: -1,
                      isResizing: false,
                      onStartResizing: (index, x) {},
                      onUpdatePreviewWidth: (width) {},
                      onFinishResizing: () {},
                    ),
                    // Nội dung bảng với expandable rows
                    ExpandableTableContentWidget<T, C>(
                      tableProvider: widget.tableProvider,
                      childDataGetter: widget.childDataGetter,
                      childColumns: widget.childColumns,
                      columns: widget.columns,
                      valueGetter: widget.valueGetter,
                      cellsBuilder: widget.cellsBuilder,
                      cellBuilderByKey: widget.cellBuilderByKey,
                      idGetter: widget.idGetter,
                      showQuantityColumn: widget.showQuantityColumn,
                      rowHeight: widget.rowHeight,
                      enableRowHover: widget.enableRowHover,
                      enableRowSelection: widget.enableRowSelection,
                      maxHeight: widget.maxHeight,
                      cellPadding: widget.cellPadding,
                      cellDecoration: widget.cellDecoration,
                      hoverColor: widget.hoverColor,
                      selectedRowColor: widget.selectedRowColor,
                      errorWidget: widget.errorWidget,
                      emptyWidget: widget.emptyWidget,
                      onRowTap: widget.onRowTap,
                      bodyController: _bodyController,
                      verticalScrollController: _verticalScrollController,
                      childTableBackgroundColor: widget.childTableBackgroundColor,
                      childTableTitle: widget.childTableTitle,
                      childTableMaxHeight: widget.childTableMaxHeight,
                      childCellBuilder: widget.childCellBuilder,
                    ),
                    const SizedBox(height: 4),
                    _buildHorizontalScrollbar(),
                  ],
                ),
              ],
            ),
            // Thanh phân trang
            PaginationBar<T>(tableProvider: widget.tableProvider),
          ],
        );
      },
    );
  }


  /// Tạo horizontal scrollbar
  Widget _buildHorizontalScrollbar() {
    return Scrollbar(
      controller: _scrollbarController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollbarController,
        child: SizedBox(
          width: _columns.fold<double>(0.0, (sum, col) => sum + col.width),
          height: 10,
        ),
      ),
    );
  }
}
