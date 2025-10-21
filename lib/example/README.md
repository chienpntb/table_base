# Expandable Table Example

Đây là example sử dụng ExpandableRiverpodTable - một widget table có thể expand để hiển thị table con với column alignment.

## Tính năng chính

- **Expandable Rows**: Có thể expand/collapse các row để hiển thị dữ liệu con
- **Column Alignment**: Table con được align theo column của table cha
- **Custom Styling**: Hỗ trợ tùy chỉnh màu sắc, kích thước
- **Interactive**: Hỗ trợ hover, selection, actions
- **Responsive**: Tự động điều chỉnh kích thước

## Cách sử dụng

### 1. Import các widget cần thiết

```dart
import 'package:table_base/widgets/table/widgets/expandable_riverpod_table.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
```

### 2. Tạo Provider

```dart
final expandableTableProvider = StateNotifierProvider<TableNotifier<YourDataType>, GenericTableState<YourDataType>>(
  (ref) => TableNotifier<YourDataType>(),
);
```

### 3. Sử dụng ExpandableRiverpodTable

```dart
ExpandableRiverpodTable<ParentType, ChildType>(
  tableProvider: yourTableProvider,
  childDataGetter: (parentData) => getChildData(parentData),
  childColumns: [
    TableColumnData.simple(name: 'Column 1', key: 'col1', width: 100),
    TableColumnData.simple(name: 'Column 2', key: 'col2', width: 120),
  ],
  columns: [
    TableColumnData.simple(name: 'Parent Col 1', key: 'parent1', width: 150),
    TableColumnData.simple(name: 'Parent Col 2', key: 'parent2', width: 200),
  ],
  valueGetter: (item, index) => getValueByIndex(item, index),
  // ... các options khác
)
```

## Cấu trúc dữ liệu

### Parent Data (Dữ liệu cha)
```dart
class Employee {
  final String id;
  final String name;
  final String email;
  // ... các field khác
}
```

### Child Data (Dữ liệu con)
```dart
class Dessert {
  final String id;
  final String name;
  final double commits;
  // ... các field khác
}
```

## Callbacks quan trọng

### childDataGetter
```dart
List<ChildType>? childDataGetter(ParentType parentData) {
  // Trả về danh sách dữ liệu con từ dữ liệu cha
  return getChildDataForParent(parentData);
}
```

### cellBuilderByKey
```dart
TableCellData? cellBuilderByKey(ParentType item, String key) {
  switch (key) {
    case 'name':
      return TableCellData(
        widget: Text(item.name),
      );
    case 'status':
      return TableCellData(
        widget: Row(
          children: [
            Icon(Icons.circle, color: getStatusColor(item.status)),
            Text(item.status),
          ],
        ),
      );
    default:
      return null;
  }
}
```

## Styling

### Màu sắc
```dart
ExpandableRiverpodTable(
  childTableBackgroundColor: Colors.yellow.shade50,
  childTableTitle: 'Child Table Title',
  hoverColor: Colors.blue.shade50,
  selectedRowColor: Colors.blue.shade100,
  alternateColor: Colors.grey.shade50,
)
```

### Kích thước
```dart
ExpandableRiverpodTable(
  childTableMaxHeight: 200,
  rowHeight: 48,
  headerHeight: 48,
)
```

## Example hoàn chỉnh

Xem file `simple_expandable_example.dart` để có example hoàn chỉnh với:
- Dữ liệu mẫu Employee và Dessert
- Cấu hình columns
- Custom cell rendering
- Actions (edit, delete)
- Styling

## Chạy example

```bash
flutter run
```

Example sẽ hiển thị một table với:
- 3 employees
- Mỗi employee có thể expand để xem dessert details
- Table con được align theo column của table cha
- Hỗ trợ hover, selection, actions
