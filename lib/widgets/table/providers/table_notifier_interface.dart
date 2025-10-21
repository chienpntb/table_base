import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'table_state.dart';

/// Interface cho các notifier quản lý bảng dữ liệu
abstract class TableNotifierInterface<T> extends StateNotifier<GenericTableState<T>> {
  TableNotifierInterface(super.state);

  /// Khởi tạo bảng với các thông số ban đầu
  void initialize({
    required Map<String, double> columnWidths,
    required dynamic Function(T item, int columnIndex) valueGetter,
    int itemsPerPage = 50,
  });

  /// Cập nhật kích thước cột
  void resizeColumn(String columnName, double width);

  /// Cập nhật hàng loạt kích thước cột theo key (không reload dữ liệu)
  void updateWidths(Map<String, double> widths);

  /// Tải dữ liệu mới
  Future<void> loadData([List<T>? data]);

  /// Sắp xếp dữ liệu theo cột
  void sort(int columnIndex);

  /// Chọn/hủy chọn một mục
  void toggleItemSelection(String itemId);

  /// Chọn/hủy chọn tất cả các mục
  void toggleSelectAll();

  /// Chuyển trang
  void goToPage(int page);

  /// Chuyển đến trang tiếp theo
  void nextPage();

  /// Chuyển đến trang trước
  void previousPage();

  /// Chuyển đến trang đầu tiên
  void firstPage();

  /// Chuyển đến trang cuối cùng
  void lastPage();

  /// Áp dụng bộ lọc cho một cột
  void applyColumnFilter(int columnIndex, ColumnFilter filter);

  /// Xóa bộ lọc cho một cột
  void clearColumnFilter(int columnIndex);

  /// Xóa tất cả bộ lọc
  void clearAllFilters();

  /// Toggle trạng thái collapse/expand của một hàng cha
  void toggleRowCollapse(String rowId);

  /// Set trạng thái collapse của một hàng cha
  void setRowCollapse(String rowId, bool collapsed);

  /// Expand tất cả các hàng cha
  void expandAllRows();

  /// Collapse tất cả các hàng cha
  void collapseAllRows();
} 