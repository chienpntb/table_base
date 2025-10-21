import 'package:flutter/material.dart';

/// Model cho dữ liệu hàng có thể mở rộng
class ExpandableRowData<T> {
  /// Dữ liệu chính của hàng cha
  final T parentData;
  
  /// Danh sách dữ liệu con (nếu có)
  final List<T>? children;
  
  /// Trạng thái đóng/mở của hàng này
  final bool isExpanded;
  
  /// ID duy nhất của hàng để quản lý expand state
  final String id;
  
  /// Callback để lấy children từ parent data (tùy chọn, ưu tiên children property)
  final List<T>? Function(T parent)? childrenGetter;

  const ExpandableRowData({
    required this.parentData,
    required this.id,
    this.children,
    this.isExpanded = false,
    this.childrenGetter,
  });

  ExpandableRowData<T> copyWith({
    T? parentData,
    List<T>? children,
    bool? isExpanded,
    String? id,
    List<T>? Function(T parent)? childrenGetter,
  }) {
    return ExpandableRowData<T>(
      parentData: parentData ?? this.parentData,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      id: id ?? this.id,
      childrenGetter: childrenGetter ?? this.childrenGetter,
    );
  }

  /// Kiểm tra xem hàng này có children không
  bool get hasChildren {
    if (children != null && children!.isNotEmpty) return true;
    if (childrenGetter != null) {
      final childrenFromGetter = childrenGetter!(parentData);
      return childrenFromGetter != null && childrenFromGetter.isNotEmpty;
    }
    return false;
  }

  /// Lấy danh sách children thực tế
  List<T> getChildren() {
    if (children != null && children!.isNotEmpty) return children!;
    if (childrenGetter != null) {
      return childrenGetter!(parentData) ?? [];
    }
    return [];
  }
}

/// Model cho dữ liệu bảng có thể mở rộng
class ExpandableTableData<T> {
  /// Danh sách tất cả dữ liệu cha
  final List<ExpandableRowData<T>> parentRows;
  
  /// Map lưu trạng thái expand của từng hàng theo ID
  final Map<String, bool> expandStates;
  
  /// Danh sách flat data để hiển thị (bao gồm cả parent và children đã expand)
  final List<ExpandableDisplayItem<T>> displayItems;

  const ExpandableTableData({
    required this.parentRows,
    required this.expandStates,
    required this.displayItems,
  });

  ExpandableTableData<T> copyWith({
    List<ExpandableRowData<T>>? parentRows,
    Map<String, bool>? expandStates,
    List<ExpandableDisplayItem<T>>? displayItems,
  }) {
    return ExpandableTableData<T>(
      parentRows: parentRows ?? this.parentRows,
      expandStates: expandStates ?? this.expandStates,
      displayItems: displayItems ?? this.displayItems,
    );
  }
}

/// Item hiển thị trong bảng (có thể là parent hoặc child)
class ExpandableDisplayItem<T> {
  /// Dữ liệu thực tế
  final T data;
  
  /// Cấp độ indent (0 = parent, 1 = child level 1, ...)
  final int level;
  
  /// Có phải là parent row không
  final bool isParent;
  
  /// ID của parent (nếu đây là child item)
  final String? parentId;
  
  /// ID của chính item này (nếu là parent)
  final String? itemId;
  
  /// Có children không (chỉ áp dụng cho parent)
  final bool hasChildren;
  
  /// Trạng thái expand (chỉ áp dụng cho parent)
  final bool isExpanded;

  const ExpandableDisplayItem({
    required this.data,
    required this.level,
    required this.isParent,
    this.parentId,
    this.itemId,
    this.hasChildren = false,
    this.isExpanded = false,
  });

  ExpandableDisplayItem<T> copyWith({
    T? data,
    int? level,
    bool? isParent,
    String? parentId,
    String? itemId,
    bool? hasChildren,
    bool? isExpanded,
  }) {
    return ExpandableDisplayItem<T>(
      data: data ?? this.data,
      level: level ?? this.level,
      isParent: isParent ?? this.isParent,
      parentId: parentId ?? this.parentId,
      itemId: itemId ?? this.itemId,
      hasChildren: hasChildren ?? this.hasChildren,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Widget cho expand/collapse icon
class ExpandIcon extends StatelessWidget {
  final bool isExpanded;
  final bool hasChildren;
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  const ExpandIcon({
    super.key,
    required this.isExpanded,
    required this.hasChildren,
    this.onTap,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasChildren) {
      return SizedBox(width: size, height: size);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: Icon(
          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
          size: size,
          color: color ?? Colors.grey[600],
        ),
      ),
    );
  }
}
