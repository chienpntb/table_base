import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expandable_table_model.dart';

/// State cho expandable table
class ExpandableTableState<T> {
  /// Dữ liệu expandable
  final ExpandableTableData<T>? expandableData;
  
  /// Dữ liệu hiện tại đang hiển thị (đã flatten)
  final List<T> currentDisplayData;
  
  /// Trạng thái loading
  final bool isLoading;
  
  /// Thông báo lỗi
  final String? error;

  const ExpandableTableState({
    this.expandableData,
    this.currentDisplayData = const [],
    this.isLoading = false,
    this.error,
  });

  ExpandableTableState<T> copyWith({
    ExpandableTableData<T>? expandableData,
    List<T>? currentDisplayData,
    bool? isLoading,
    String? error,
  }) {
    return ExpandableTableState<T>(
      expandableData: expandableData ?? this.expandableData,
      currentDisplayData: currentDisplayData ?? this.currentDisplayData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier quản lý state cho expandable table
class ExpandableTableNotifier<T> extends StateNotifier<ExpandableTableState<T>> {
  final String? Function(T)? _idGetter;

  ExpandableTableNotifier({
    String? Function(T)? idGetter,
  }) : _idGetter = idGetter,
       super(const ExpandableTableState());

  /// Khởi tạo dữ liệu expandable
  void initializeData(List<ExpandableRowData<T>> parentRows) {
    final expandableData = ExpandableTableData<T>(
      parentRows: parentRows,
      expandStates: {},
      displayItems: [],
    );

    // Tạo display items ban đầu
    final displayItems = _createDisplayItems(expandableData);
    final flatData = displayItems.map((item) => item.data).toList();

    final updatedExpandableData = expandableData.copyWith(
      displayItems: displayItems,
    );

    state = state.copyWith(
      expandableData: updatedExpandableData,
      currentDisplayData: flatData,
    );
  }

  /// Toggle expand/collapse cho một hàng
  void toggleExpand(String parentId) {
    if (state.expandableData == null) return;

    final currentExpandStates = Map<String, bool>.from(
      state.expandableData!.expandStates,
    );
    
    // Toggle trạng thái expand
    final currentExpanded = currentExpandStates[parentId] ?? false;
    currentExpandStates[parentId] = !currentExpanded;

    // Cập nhật expandable data
    final updatedExpandableData = state.expandableData!.copyWith(
      expandStates: currentExpandStates,
    );

    // Tạo lại display items
    final newDisplayItems = _createDisplayItems(updatedExpandableData);
    final flatData = newDisplayItems.map((item) => item.data).toList();

    state = state.copyWith(
      expandableData: updatedExpandableData.copyWith(displayItems: newDisplayItems),
      currentDisplayData: flatData,
    );
  }

  /// Expand tất cả các hàng
  void expandAll() {
    if (state.expandableData == null) return;

    final expandStates = <String, bool>{};
    
    // Đánh dấu tất cả parent rows là expanded
    void markAllExpanded(List<ExpandableRowData<T>> rows) {
      for (final row in rows) {
        final rowId = _idGetter?.call(row.parentData) ?? row.id;
        expandStates[rowId] = true;
        
        if (row.children != null && row.children!.isNotEmpty) {
          // Tạo ExpandableRowData cho children và đệ quy
          final childRows = row.children!.map((child) => 
            ExpandableRowData<T>(
              parentData: child,
              id: _idGetter?.call(child) ?? '',
            )
          ).toList();
          markAllExpanded(childRows);
        }
      }
    }
    
    markAllExpanded(state.expandableData!.parentRows);

    final updatedExpandableData = state.expandableData!.copyWith(
      expandStates: expandStates,
    );

    final newDisplayItems = _createDisplayItems(updatedExpandableData);
    final flatData = newDisplayItems.map((item) => item.data).toList();

    state = state.copyWith(
      expandableData: updatedExpandableData.copyWith(displayItems: newDisplayItems),
      currentDisplayData: flatData,
    );
  }

  /// Collapse tất cả các hàng
  void collapseAll() {
    if (state.expandableData == null) return;

    final updatedExpandableData = state.expandableData!.copyWith(
      expandStates: {},
    );

    final newDisplayItems = _createDisplayItems(updatedExpandableData);
    final flatData = newDisplayItems.map((item) => item.data).toList();

    state = state.copyWith(
      expandableData: updatedExpandableData.copyWith(displayItems: newDisplayItems),
      currentDisplayData: flatData,
    );
  }

  /// Tạo display items từ expandable data
  List<ExpandableDisplayItem<T>> _createDisplayItems(
    ExpandableTableData<T> data,
  ) {
    final items = <ExpandableDisplayItem<T>>[];
    
    void addItems(
      List<ExpandableRowData<T>> rows,
      int level,
    ) {
      for (final row in rows) {
        // Tạo id cho row
        final rowId = _idGetter?.call(row.parentData) ?? row.id;
        
        // Thêm parent row
        items.add(ExpandableDisplayItem<T>(
          data: row.parentData,
          level: level,
          isParent: true,
          itemId: rowId,
          hasChildren: row.hasChildren,
          isExpanded: data.expandStates[rowId] ?? false,
        ));
        
        // Nếu có children và đang expand thì thêm children
        if (row.hasChildren && (data.expandStates[rowId] ?? false)) {
          final children = row.children ?? [];
          for (final child in children) {
            final childId = _idGetter?.call(child) ?? '';
            items.add(ExpandableDisplayItem<T>(
              data: child,
              level: level + 1,
              isParent: false,
              parentId: rowId,
              itemId: childId,
              hasChildren: false,
              isExpanded: false,
            ));
          }
        }
      }
    }
    
    addItems(data.parentRows, 0);
    return items;
  }

}