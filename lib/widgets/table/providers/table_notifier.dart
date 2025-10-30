import 'table_state.dart';
import 'table_notifier_interface.dart';

/// Lớp cơ sở cho các table notifier, triển khai tất cả các phương thức chung
/// Các lớp con chỉ cần kế thừa và ghi đè các phương thức cần tùy chỉnh
class TableNotifier<T> extends TableNotifierInterface<T> {
  TableNotifier()
    : super(
        GenericTableState<T>(
          allData: [],
          filteredData: [],
          currentPageData: [],
          isLoading: true,
          sortState: const TableSortState(),
          paginationState: const TablePaginationState(),
          selectionState: const TableSelectionState(),
          columnsState: TableColumnsState(widths: {}),
          filterState: const TableFilterState(),
        ),
      );

  /// Function để lấy giá trị từ một mục theo cột
  dynamic Function(T item, int columnIndex)? _valueGetter;

  /// Callback khi chuyển trang trong chế độ API pagination
  Future<void> Function(int page)? _onPageChangedCallback;

  /// Hàm tạo dữ liệu mẫu - được ghi đè bởi các lớp con
  Future<List<T>> generateData() async {
    return [];
  }

  bool get hasActiveFilters => state.filterState.hasActiveFilters;

  @override
  void initialize({
    required Map<String, double> columnWidths,
    required dynamic Function(T item, int columnIndex) valueGetter,
    int itemsPerPage = 20,
  }) {
    _valueGetter = valueGetter;

    state = state.copyWith(
      columnsState: TableColumnsState(widths: Map.from(columnWidths)),
      paginationState: TablePaginationState(itemsPerPage: itemsPerPage),
    );

    // Tải dữ liệu ngay sau khi khởi tạo
    loadData();
  }

  @override
  void resizeColumn(String columnName, double width) {
    final newWidths = Map<String, double>.from(state.columnsState.widths);
    newWidths[columnName] = width;

    state = state.copyWith(columnsState: TableColumnsState(widths: newWidths));
  }

  @override
  void updateWidths(Map<String, double> widths) {
    // Cập nhật widths hàng loạt, không reload dữ liệu
    state = state.copyWith(
      columnsState: TableColumnsState(widths: Map<String, double>.from(widths)),
    );
  }

  @override
  Future<void> loadData([List<T>? data]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Nếu cung cấp dữ liệu, sử dụng nó; ngược lại, tạo dữ liệu mẫu
      final items = data?.isNotEmpty == true ? data! : await generateData();

      final sortedData = _sortData(items);
      final paginatedData = _getPaginatedData(sortedData);

      state = state.copyWith(
        allData: items,
        filteredData: sortedData,
        currentPageData: paginatedData,
        isLoading: false,
        paginationState: state.paginationState.copyWith(
          totalItems: items.length,
          currentPage: 0, // Reset to first page when new data is loaded
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading data: $error',
      );
    }
  }

  /// Thiết lập dữ liệu từ API cho chế độ API pagination
  /// Dùng khi nhận dữ liệu từ API call với pagination
  void setApiData(List<T> data, {int? totalPages, int? currentPage, int? totalItems}) {
    if (state.paginationState.useApiPagination) {
      // Trong chế độ API pagination, data đã được phân trang từ server
      state = state.copyWith(
        currentPageData: data,
        isLoading: false,
        errorMessage: null,
        paginationState: state.paginationState.copyWith(
          totalPagesFromApi: totalPages ?? state.paginationState.totalPagesFromApi,
          currentPageFromApi: currentPage ?? state.paginationState.currentPageFromApi,
          totalItems: totalItems ?? state.paginationState.totalItems,
        ),
      );
    } else {
      // Fallback về loadData thông thường
      loadData(data);
    }
  }

  @override
  void goToPage(int page) {
    if (page < 0 || page >= state.paginationState.totalPages) return;

    if (state.paginationState.useApiPagination) {
      // Cập nhật state
      state = state.copyWith(
        paginationState: state.paginationState.copyWith(
          currentPageFromApi: page,
        ),
      );
      
      // Gọi callback nếu có
      _onPageChangedCallback?.call(page);
    } else {
      // Chế độ local pagination
      state = state.copyWith(
        paginationState: state.paginationState.copyWith(currentPage: page),
        currentPageData: _getPaginatedData(state.filteredData, page: page),
      );
    }
  }

  @override
  void nextPage() {
    if (!state.paginationState.canGoNext) return;
    final currentDisplayPage = state.paginationState.currentDisplayPage;
    goToPage(currentDisplayPage + 1);
  }

  @override
  void previousPage() {
    if (!state.paginationState.canGoPrevious) return;
    final currentDisplayPage = state.paginationState.currentDisplayPage;
    goToPage(currentDisplayPage - 1);
  }

  @override
  void firstPage() {
    goToPage(0);
  }

  @override
  void lastPage() {
    final state = this.state;
    if (state.paginationState.useApiPagination) {
      // Trong chế độ API pagination, chuyển đến trang cuối từ API
      goToPage(state.paginationState.totalPages - 1);
    } else {
      // Chế độ local pagination
      goToPage(state.paginationState.totalPages - 1);
    }
  }

  @override
  void setApiPaginationInfo({
    required int totalPages,
    required int currentPage,
    int? totalItems,
  }) {
    state = state.copyWith(
      paginationState: state.paginationState.copyWith(
        useApiPagination: true,
        totalPagesFromApi: totalPages,
        currentPageFromApi: currentPage,
        totalItems: totalItems ?? state.paginationState.totalItems,
      ),
    );
  }

  @override
  void enableApiPagination(bool enabled) {
    state = state.copyWith(
      paginationState: state.paginationState.copyWith(
        useApiPagination: enabled,
        totalPagesFromApi: enabled ? state.paginationState.totalPagesFromApi : null,
        currentPageFromApi: enabled ? state.paginationState.currentPageFromApi : null,
      ),
    );
  }

  /// Thiết lập API pagination với callback để load dữ liệu
  /// Cách này cho phép bạn thiết lập từ bên ngoài nhưng vẫn tự động hóa
  void setupApiPagination({
    required Future<void> Function(int page) onPageChanged,
    int? initialTotalPages,
    int? initialCurrentPage,
  }) {
    enableApiPagination(true);
    
    if (initialTotalPages != null && initialCurrentPage != null) {
      setApiPaginationInfo(
        totalPages: initialTotalPages,
        currentPage: initialCurrentPage,
      );
    }
    
    // Store callback để sử dụng khi chuyển trang
    _onPageChangedCallback = onPageChanged;
  }

  @override
  void sort(int columnIndex) {
    final isReversing = state.sortState.columnIndex == columnIndex;
    final newAscending = isReversing ? !state.sortState.ascending : true;

    // Sắp xếp dữ liệu đã lọc thay vì allData
    final sortedData = _sortData(
      state.filteredData,
      columnIndex: columnIndex,
      ascending: newAscending,
    );

    state = state.copyWith(
      sortState: TableSortState(
        columnIndex: columnIndex,
        ascending: newAscending,
      ),
      filteredData: sortedData,
    );

    // Cập nhật dữ liệu trang hiện tại
    state = state.copyWith(
      currentPageData: _getPaginatedData(state.filteredData),
    );
  }

  @override
  void toggleItemSelection(String itemId) {
    final newSelectedIds = Set<String>.from(state.selectionState.selectedIds);

    if (newSelectedIds.contains(itemId)) {
      newSelectedIds.remove(itemId);
    } else {
      newSelectedIds.add(itemId);
    }

    // Cập nhật trạng thái selectAll
    final selectAll =
        state.filteredData.isNotEmpty &&
        state.filteredData.every(
          (item) => newSelectedIds.contains((item as dynamic).id),
        );

    state = state.copyWith(
      selectionState: state.selectionState.copyWith(
        selectedIds: newSelectedIds,
        selectAll: selectAll,
      ),
    );
  }

  @override
  void toggleSelectAll() {
    final selectAll = !state.selectionState.selectAll;
    final newSelectedIds = Set<String>.from(state.selectionState.selectedIds);

    if (selectAll) {
      // Thêm tất cả ID vào danh sách đã chọn
      for (var item in state.allData) {
        newSelectedIds.add((item as dynamic).id.toString());
      }
    } else {
      // Xóa tất cả ID khỏi danh sách đã chọn
      for (var item in state.allData) {
        newSelectedIds.remove((item as dynamic).id.toString());
      }
    }

    state = state.copyWith(
      selectionState: state.selectionState.copyWith(
        selectedIds: newSelectedIds,
        selectAll: selectAll,
      ),
    );
  }

  @override
  void applyColumnFilter(int columnIndex, ColumnFilter filter) {
    final newFilters = Map<int, ColumnFilter>.from(
      state.filterState.columnFilters,
    );
    newFilters[columnIndex] = filter;

    final hasActiveFilters = newFilters.isNotEmpty;

    state = state.copyWith(
      filterState: state.filterState.copyWith(
        columnFilters: newFilters,
        hasActiveFilters: hasActiveFilters,
      ),
    );

    // Áp dụng lọc và cập nhật dữ liệu
    _applyFilters();
  }

  @override
  void clearColumnFilter(int columnIndex) {
    final newFilters = Map<int, ColumnFilter>.from(
      state.filterState.columnFilters,
    );
    newFilters.remove(columnIndex);

    final hasActiveFilters = newFilters.isNotEmpty;

    state = state.copyWith(
      filterState: state.filterState.copyWith(
        columnFilters: newFilters,
        hasActiveFilters: hasActiveFilters,
      ),
    );

    // Áp dụng lọc và cập nhật dữ liệu
    _applyFilters();
  }

  @override
  void clearAllFilters() {
    state = state.copyWith(filterState: const TableFilterState());

    // Áp dụng lọc và cập nhật dữ liệu
    _applyFilters();
  }

  /// Áp dụng tất cả bộ lọc hiện tại
  void _applyFilters() {
    print('_applyFilters called with ${state.allData.length} allData items');
    print('Active filters: ${state.filterState.columnFilters.length}');
    List<T> filteredData = List<T>.from(state.allData);

    // Áp dụng từng bộ lọc
    for (final filter in state.filterState.columnFilters.values) {
      print('Applying filter for column ${filter.columnIndex}: ${filter.filterType}');
      filteredData = _filterDataByColumn(filteredData, filter);
    }

    // Sắp xếp dữ liệu đã lọc
    final sortedData = _sortData(filteredData);

    // Cập nhật pagination
    final paginatedData = _getPaginatedData(sortedData);

    print('Final filtered data: ${filteredData.length}, paginated: ${paginatedData.length}');

    state = state.copyWith(
      filteredData: sortedData,
      currentPageData: paginatedData,
      paginationState: state.paginationState.copyWith(
        totalItems: sortedData.length,
        currentPage: 0, // Reset to first page when filters change
      ),
    );
  }

  /// Lọc dữ liệu theo một cột cụ thể
  List<T> _filterDataByColumn(List<T> data, ColumnFilter filter) {
    print('_filterDataByColumn called with ${data.length} items, filter: ${filter.filterType}');
    if (_valueGetter == null) {
      print('_valueGetter is null, returning original data');
      return data;
    }

    final filteredData = data.where((item) {
      final value = _valueGetter!(item, filter.columnIndex);
      final result = _evaluateFilterCondition(value, filter);
      print('Filtering item: $item, value: $value, result: $result');
      return result;
    }).toList();
    
    print('Filtered data length: ${filteredData.length}');
    return filteredData;
  }

  /// Đánh giá điều kiện lọc
  bool _evaluateFilterCondition(dynamic value, ColumnFilter filter) {
    print('_evaluateFilterCondition: value=$value, filterType=${filter.filterType}');
    
    // Lọc theo filter chọn nhiều giá trị
    if (filter.filterType == FilterType.select) {
      final result = filter.selectedValues.contains(value);
      print('Select filter: selectedValues=${filter.selectedValues}, result=$result');
      return result;
    }

    // Lọc theo khoảng số [min, max]
    if (filter.filterType == FilterType.number) {
      double? start;
      double? end;
      start = filter.minNumberValue;
      end = filter.maxNumberValue;

      double? cur;
      if (value is num) {
        cur = value.toDouble();
      } else if (value is String) {
        cur = double.tryParse(value.replaceAll(RegExp(r"[^0-9.-]"), ''));
      }
      if (cur == null) {
        return false;
      }

      bool result;
      if (start != null && end != null) {
        result = cur >= start && cur <= end;
      } else if (start != null) {
        result = cur >= start;
      } else if (end != null) {
        result = cur <= end;
      } else {
        result = true;
      }
      return result;
    }

    // Lọc theo khoảng ngày
    if (filter.filterType == FilterType.date) {
      DateTime? start;
      DateTime? end;
      if (filter.startDateValue != null) start = filter.startDateValue;
      if (filter.endDateValue != null) end = filter.endDateValue;

      if (value is! DateTime) return false;
      final current = value;

      if (start != null && end != null) {
        return !current.isBefore(start) && !current.isAfter(end);
      }
      if (start != null) return !current.isBefore(start);
      if (end != null) return !current.isAfter(end);
      return true;
    }

    return false;
  }

  /// Sắp xếp dữ liệu theo cột
  List<T> _sortData(List<T> data, {int? columnIndex, bool? ascending}) {
    if (_valueGetter == null) return data;

    columnIndex = columnIndex ?? state.sortState.columnIndex;
    ascending = ascending ?? state.sortState.ascending;

    if (columnIndex == null) return data;

    final sortedList = List<T>.from(data);

    sortedList.sort((a, b) {
      var aValue = _valueGetter!(a, columnIndex!);
      var bValue = _valueGetter!(b, columnIndex);

      int result;
      if (aValue is num && bValue is num) {
        result = aValue.compareTo(bValue);
      } else if (aValue is String && bValue is String) {
        result = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        result = aValue.compareTo(bValue);
      } else if (aValue is bool && bValue is bool) {
        result =
            aValue
                ? 1
                : bValue
                ? -1
                : 0;
      } else {
        result = 0;
      }

      return ascending! ? result : -result;
    });

    return sortedList;
  }

  /// Lấy dữ liệu cho trang hiện tại
  List<T> _getPaginatedData(List<T> data, {int? page}) {
    page = page ?? state.paginationState.currentPage;
    final itemsPerPage = state.paginationState.itemsPerPage;

    final startIndex = page * itemsPerPage;
    final endIndex = (page + 1) * itemsPerPage;

    if (startIndex >= data.length) {
      return [];
    }

    return data.sublist(
      startIndex,
      endIndex > data.length ? data.length : endIndex,
    );
  }

  /// Hàm tìm kiếm tổng quát trên toàn bộ dữ liệu
  void search(String keyword) {
    // Chuyển từ khóa tìm kiếm về dạng chữ thường
    final lowerKeyword = keyword.toLowerCase();

    // Lọc dữ liệu dựa trên từ khóa
    final searchedData = state.allData.where((item) {
      // Duyệt qua tất cả các cột
      for (int columnIndex = 0; columnIndex < state.columnsState.widths.length; columnIndex++) {
        final value = _valueGetter?.call(item, columnIndex);
        if (value != null && value.toString().toLowerCase().contains(lowerKeyword)) {
          return true; // Nếu tìm thấy từ khóa trong bất kỳ cột nào
        }
      }
      return false; // Không tìm thấy từ khóa
    }).toList();

    // Cập nhật trạng thái với dữ liệu đã tìm kiếm
    state = state.copyWith(
      filteredData: searchedData,
      currentPageData: _getPaginatedData(searchedData),
      paginationState: state.paginationState.copyWith(
        totalItems: searchedData.length,
        currentPage: 0, // Reset về trang đầu tiên
      ),
    );
  }
}
