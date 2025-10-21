/// Trạng thái sắp xếp của bảng
class TableSortState {
  final int? columnIndex;
  final bool ascending;

  const TableSortState({this.columnIndex, this.ascending = true});

  TableSortState copyWith({int? columnIndex, bool? ascending}) {
    return TableSortState(
      columnIndex: columnIndex ?? this.columnIndex,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Trạng thái phân trang của bảng
class TablePaginationState {
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int indexStart;
  final int indexEnd;

  const TablePaginationState({
    this.currentPage = 0,
    this.itemsPerPage = 50,
    this.totalItems = 0,
  }) : indexStart = currentPage * itemsPerPage + 1,
       indexEnd =
           (currentPage + 1) * itemsPerPage > totalItems
               ? totalItems
               : (currentPage + 1) * itemsPerPage;

  int get totalPages => (totalItems / itemsPerPage).ceil();
  bool get canGoNext => currentPage < totalPages - 1;
  bool get canGoPrevious => currentPage > 0;

  TablePaginationState copyWith({
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
  }) {
    return TablePaginationState(
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

/// Trạng thái chọn dữ liệu của bảng
class TableSelectionState {
  final Set<String> selectedIds;
  final bool selectAll;

  const TableSelectionState({
    this.selectedIds = const {},
    this.selectAll = false,
  });

  TableSelectionState copyWith({Set<String>? selectedIds, bool? selectAll}) {
    return TableSelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      selectAll: selectAll ?? this.selectAll,
    );
  }
}

/// Lưu trữ thông tin kích thước của các cột
class TableColumnsState {
  final Map<String, double> widths;

  const TableColumnsState({required this.widths});

  TableColumnsState copyWith({Map<String, double>? widths}) {
    return TableColumnsState(widths: widths ?? this.widths);
  }
}

/// Trạng thái lọc của bảng
class TableFilterState {
  final Map<int, ColumnFilter> columnFilters;
  final bool hasActiveFilters;

  const TableFilterState({
    this.columnFilters = const {},
    this.hasActiveFilters = false,
  });

  TableFilterState copyWith({
    Map<int, ColumnFilter>? columnFilters,
    bool? hasActiveFilters,
  }) {
    return TableFilterState(
      columnFilters: columnFilters ?? this.columnFilters,
      hasActiveFilters: hasActiveFilters ?? this.hasActiveFilters,
    );
  }
}

/// Loại lọc cho cột
enum FilterType { number, date, select }

/// Thông tin lọc cho một cột
class ColumnFilter {
  final int columnIndex;
  final FilterType filterType;
  final double? minNumberValue;
  final double? maxNumberValue;
  final DateTime? startDateValue;
  final DateTime? endDateValue;
  final Set<dynamic> selectedValues;
  final String? customText;

  const ColumnFilter({
    required this.columnIndex,
    required this.filterType,
    this.minNumberValue,
    this.maxNumberValue,
    this.startDateValue,
    this.endDateValue,
    this.selectedValues = const {},
    this.customText,
  });

  ColumnFilter copyWith({
    int? columnIndex,
    FilterType? filterType,
    double? minNumberValue,
    double? maxNumberValue,
    DateTime? startDateValue,
    DateTime? endDateValue,
    Set<dynamic>? selectedValues,
    String? customText,
  }) {
    return ColumnFilter(
      columnIndex: columnIndex ?? this.columnIndex,
      filterType: filterType ?? this.filterType,
      minNumberValue: minNumberValue ?? this.minNumberValue,
      maxNumberValue: maxNumberValue ?? this.maxNumberValue,
      startDateValue: startDateValue ?? this.startDateValue,
      endDateValue: endDateValue ?? this.endDateValue,
      selectedValues: selectedValues ?? this.selectedValues,
      customText: customText ?? this.customText,
    );
  }
}

/// Trạng thái collapse/expand của các hàng phân cấp
class TableCollapseState {
  /// Map lưu trạng thái collapse của các hàng cha
  /// Key: rowId, Value: true nếu collapsed, false nếu expanded
  final Map<String, bool> collapsedRows;
  
  /// Có đang trong quá trình animation collapse/expand không
  final bool isAnimating;

  const TableCollapseState({
    this.collapsedRows = const {},
    this.isAnimating = false,
  });

  TableCollapseState copyWith({
    Map<String, bool>? collapsedRows,
    bool? isAnimating,
  }) {
    return TableCollapseState(
      collapsedRows: collapsedRows ?? this.collapsedRows,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  /// Kiểm tra một hàng có bị collapse không
  bool isRowCollapsed(String rowId) {
    return collapsedRows[rowId] ?? true; // Mặc định là collapsed
  }

  /// Toggle trạng thái collapse của một hàng
  TableCollapseState toggleRowCollapse(String rowId) {
    final newCollapsedRows = Map<String, bool>.from(collapsedRows);
    newCollapsedRows[rowId] = !isRowCollapsed(rowId);
    return copyWith(collapsedRows: newCollapsedRows);
  }

  /// Set trạng thái collapse của một hàng
  TableCollapseState setRowCollapse(String rowId, bool collapsed) {
    final newCollapsedRows = Map<String, bool>.from(collapsedRows);
    newCollapsedRows[rowId] = collapsed;
    return copyWith(collapsedRows: newCollapsedRows);
  }

  /// Expand tất cả các hàng
  TableCollapseState expandAll() {
    final newCollapsedRows = Map<String, bool>.from(collapsedRows);
    for (final key in newCollapsedRows.keys) {
      newCollapsedRows[key] = false;
    }
    return copyWith(collapsedRows: newCollapsedRows);
  }

  /// Collapse tất cả các hàng
  TableCollapseState collapseAll() {
    final newCollapsedRows = Map<String, bool>.from(collapsedRows);
    for (final key in newCollapsedRows.keys) {
      newCollapsedRows[key] = true;
    }
    return copyWith(collapsedRows: newCollapsedRows);
  }
}

/// Trạng thái tổng hợp của bảng dữ liệu
class GenericTableState<T> {
  final List<T> allData;
  final List<T> filteredData;
  final List<T> currentPageData;
  final bool isLoading;
  final String? errorMessage;
  final TableSortState sortState;
  final TablePaginationState paginationState;
  final TableSelectionState selectionState;
  final TableColumnsState columnsState;
  final TableFilterState filterState;
  final TableCollapseState collapseState;
  final String? searchQuery;

  const GenericTableState({
    required this.allData,
    required this.filteredData,
    required this.currentPageData,
    required this.isLoading,
    this.errorMessage,
    required this.sortState,
    required this.paginationState,
    required this.selectionState,
    required this.columnsState,
    required this.filterState,
    required this.collapseState,
    this.searchQuery,
  });

  GenericTableState<T> copyWith({
    List<T>? allData,
    List<T>? filteredData,
    List<T>? currentPageData,
    bool? isLoading,
    String? errorMessage,
    TableSortState? sortState,
    TablePaginationState? paginationState,
    TableSelectionState? selectionState,
    TableColumnsState? columnsState,
    TableFilterState? filterState,
    TableCollapseState? collapseState,
    String? searchQuery,
  }) {
    return GenericTableState<T>(
      allData: allData ?? this.allData,
      filteredData: filteredData ?? this.filteredData,
      currentPageData: currentPageData ?? this.currentPageData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      sortState: sortState ?? this.sortState,
      paginationState: paginationState ?? this.paginationState,
      selectionState: selectionState ?? this.selectionState,
      columnsState: columnsState ?? this.columnsState,
      filterState: filterState ?? this.filterState,
      collapseState: collapseState ?? this.collapseState,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<T> get selectedItems =>
      filteredData
          .where(
            (item) => selectionState.selectedIds.contains((item as dynamic).id),
          )
          .toList();
}
