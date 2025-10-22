# Expandable Riverpod Table Complete

Đây là phiên bản hoàn chỉnh của expandable table được tạo bằng cách copy toàn bộ architecture từ `riverpod_table.dart` và thêm tính năng expandable.

## Tính năng chính

✅ **Giữ nguyên tất cả tính năng của table gốc:**
- Sắp xếp theo cột
- Lọc dữ liệu
- Phân trang
- Resize cột
- Selection (checkbox)
- Actions column
- Scroll đồng bộ header/body

✅ **Thêm tính năng expandable:**
- Cột expand/collapse đầu tiên
- Click để mở/đóng child table
- Giữ scroll position khi expand/collapse
- Child table có riêng columns và data
- Hỗ trợ custom cell builder cho child table

## Cách sử dụng

### 1. Định nghĩa data models

```dart
class ParentItem {
  final String id;
  final String name;
  final List<ChildItem> children;
  
  ParentItem({required this.id, required this.name, required this.children});
}

class ChildItem {
  final String id;
  final String detail;
  
  ChildItem({required this.id, required this.detail});
}
```

### 2. Tạo provider

```dart
final tableProvider = StateNotifierProvider.autoDispose<TableNotifier<ParentItem>, GenericTableState<ParentItem>>(
  (ref) {
    final notifier = TableNotifier<ParentItem>();
    notifier.initialize(
      columnWidths: {
        'expand': 50,
        'name': 200,
        // ... other columns
      },
      valueGetter: (item, columnIndex) {
        // Return value for each column
      },
    );
    notifier.loadData(yourData);
    return notifier;
  },
);
```

### 3. Sử dụng widget

```dart
ExpandableRiverpodTableComplete<ParentItem, ChildItem>(
  tableProvider: tableProvider,
  columns: [
    TableColumnData(name: 'Tên', key: 'name', width: 200),
    // ... other columns
  ],
  childColumns: [
    TableColumnData(name: 'Chi tiết', key: 'detail', width: 200),
    // ... child columns
  ],
  childDataGetter: (item) => item.children,
  idGetter: (item) => item.id,
  cellBuilderByKey: (item, key) {
    // Custom cell builder for parent rows
  },
  childCellBuilder: (childItem, key) {
    // Custom cell builder for child rows
  },
  // ... other properties
)
```

## Các thuộc tính quan trọng

- `childDataGetter`: Function để lấy child data từ parent item
- `childColumns`: Định nghĩa columns cho child table  
- `childCellBuilder`: Custom builder cho cells trong child table
- `childTableTitle`: Tiêu đề cho child table
- `childTableMaxHeight`: Chiều cao tối đa của child table
- `childTableBackgroundColor`: Màu nền cho child table

## Xử lý scroll position

Table sử dụng `AutomaticKeepAliveClientMixin` và các kỹ thuật preserve scroll position để đảm bảo:
- Scroll position được giữ nguyên khi expand/collapse
- Smooth animation khi thay đổi trạng thái
- Không nhảy về đầu trang khi thao tác

## So sánh với table gốc

| Tính năng | Riverpod Table | Expandable Table Complete |
|-----------|----------------|---------------------------|
| Sắp xếp | ✅ | ✅ |
| Lọc | ✅ | ✅ |
| Phân trang | ✅ | ✅ |
| Resize cột | ✅ | ✅ |
| Selection | ✅ | ✅ |
| Actions | ✅ | ✅ |
| Expandable | ❌ | ✅ |
| Child table | ❌ | ✅ |
| Scroll preservation | ✅ | ✅ |

## Demo

Xem file `expandable_table_test.dart` để có ví dụ đầy đủ về cách sử dụng.