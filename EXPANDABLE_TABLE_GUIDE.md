# Hướng dẫn sử dụng Expandable Table

## Tổng quan

Expandable Table là một widget Flutter cho phép hiển thị table với khả năng expand/collapse để hiển thị table con. Table con sẽ được align theo column của table cha, giống như trong ảnh mẫu.

## Cấu trúc dự án

```
lib/
├── widgets/table/
│   ├── models/
│   │   ├── table_model.dart
│   │   └── expandable_table_model.dart
│   ├── widgets/
│   │   ├── expandable_riverpod_table.dart
│   │   ├── child_table_widget.dart
│   │   └── flexible_table.dart
│   └── providers/
│       ├── table_state.dart
│       └── table_notifier.dart
└── example/
    ├── demo_expandable.dart
    ├── simple_expandable_example.dart
    └── expandable_table_example.dart
```

## Cách sử dụng cơ bản

### 1. Import các widget cần thiết

```dart
import 'package:table_base/widgets/table/widgets/expandable_riverpod_table.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';
```

### 2. Tạo Provider

```dart
final myTableProvider = StateNotifierProvider.autoDispose<TableNotifier<MyDataType>, GenericTableState<MyDataType>>(
  (ref) => TableNotifier<MyDataType>(),
);
```

### 3. Sử dụng ExpandableRiverpodTable

```dart
ExpandableRiverpodTable<ParentType, ChildType>(
  tableProvider: myTableProvider,
  childDataGetter: (parentData) => getChildData(parentData),
  childColumns: [
    TableColumnData.simple(name: 'Child Col 1', key: 'child1', width: 100),
    TableColumnData.simple(name: 'Child Col 2', key: 'child2', width: 120),
  ],
  columns: [
    TableColumnData.simple(name: 'Parent Col 1', key: 'parent1', width: 150),
    TableColumnData.simple(name: 'Parent Col 2', key: 'parent2', width: 200),
  ],
  valueGetter: (item, index) => getValueByIndex(item, index),
  cellBuilderByKey: (item, key) => buildCustomCell(item, key),
  childTableTitle: 'Child Table Title',
  childTableBackgroundColor: Colors.yellow.shade50,
  childTableMaxHeight: 200,
  showCheckboxColumn: true,
  showActionsColumn: true,
  enableRowSelection: true,
  enableRowHover: true,
  showAlternatingRowColors: true,
  onRowTap: (item) => handleRowTap(item),
  onEdit: (item) => handleEdit(item),
  onDelete: (item) => handleDelete(item),
)
```

## Các callback quan trọng

### childDataGetter
Trả về dữ liệu con từ dữ liệu cha:

```dart
List<ChildType>? childDataGetter(ParentType parentData) {
  // Trả về danh sách dữ liệu con
  return getChildDataForParent(parentData);
}
```

### cellBuilderByKey
Tạo custom cell cho từng column:

```dart
TableCellData? cellBuilderByKey(ParentType item, String key) {
  switch (key) {
    case 'name':
      return TableCellData(
        widget: Column(
          children: [
            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(item.email, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
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
    case 'progress':
      return TableCellData(
        widget: Column(
          children: [
            Text('${item.progress}%'),
            LinearProgressIndicator(value: item.progress / 100),
          ],
        ),
      );
    default:
      return null;
  }
}
```

## Styling và Customization

### Màu sắc
```dart
ExpandableRiverpodTable(
  childTableBackgroundColor: Colors.yellow.shade50,  // Màu nền table con
  childTableTitle: 'Child Table Title',              // Tiêu đề table con
  hoverColor: Colors.blue.shade50,                   // Màu hover
  selectedRowColor: Colors.blue.shade100,           // Màu khi chọn
  alternateColor: Colors.grey.shade50,              // Màu xen kẽ
)
```

### Kích thước
```dart
ExpandableRiverpodTable(
  childTableMaxHeight: 200,    // Chiều cao tối đa table con
  rowHeight: 48,               // Chiều cao mỗi row
  headerHeight: 48,           // Chiều cao header
)
```

### Tính năng
```dart
ExpandableRiverpodTable(
  showCheckboxColumn: true,    // Hiển thị cột checkbox
  showActionsColumn: true,     // Hiển thị cột actions
  enableRowSelection: true,    // Cho phép chọn row
  enableRowHover: true,       // Hiệu ứng hover
  showAlternatingRowColors: true, // Màu xen kẽ
)
```

## Example hoàn chỉnh

### Dữ liệu mẫu
```dart
// Parent data
final employees = [
  {
    'id': '1',
    'name': 'Providenci Alten',
    'email': 'Alten@address.com',
    'status': 'Available',
    'department': 'Sales',
    'score': 15384,
  },
  // ... more employees
];

// Child data
final projects = [
  {
    'id': '1',
    'name': 'Website Redesign',
    'duration': '3 months',
    'progress': 75,
    'budget': 50000,
  },
  // ... more projects
];
```

### Cấu hình columns
```dart
// Parent columns
List<TableColumnData> _getParentColumns() {
  return [
    TableColumnData.simple(name: 'Employee', key: 'name', width: 200),
    TableColumnData.simple(name: 'Status', key: 'status', width: 120),
    TableColumnData.simple(name: 'Department', key: 'department', width: 120),
    TableColumnData.simple(name: 'Score', key: 'score', width: 100),
  ];
}

// Child columns
List<TableColumnData> _getChildColumns() {
  return [
    TableColumnData.simple(name: 'Project', key: 'name', width: 200),
    TableColumnData.simple(name: 'Duration', key: 'duration', width: 120),
    TableColumnData.simple(name: 'Progress', key: 'progress', width: 100),
    TableColumnData.simple(name: 'Budget', key: 'budget', width: 120),
  ];
}
```

## Chạy demo

```bash
flutter run
```

Demo sẽ hiển thị:
- Table với 2 employees
- Mỗi employee có thể expand để xem project details
- Table con được align theo column của table cha
- Hỗ trợ hover, selection, actions

## Tính năng nâng cao

### Custom Actions
```dart
ExpandableRiverpodTable(
  customActions: [
    CustomAction(
      icon: Icons.edit,
      label: 'Edit',
      onTap: (item) => editItem(item),
    ),
    CustomAction(
      icon: Icons.delete,
      label: 'Delete',
      onTap: (item) => deleteItem(item),
    ),
  ],
)
```

### Custom Styling
```dart
ExpandableRiverpodTable(
  cellPadding: EdgeInsets.all(12),
  cellDecoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(4),
  ),
  borderColor: Colors.grey,
  borderWidth: 1,
)
```

## Troubleshooting

### Lỗi thường gặp

1. **Provider type mismatch**: Đảm bảo sử dụng `StateNotifierProvider.autoDispose`
2. **Column alignment**: Kiểm tra số lượng columns và width
3. **Data loading**: Đảm bảo gọi `loadData()` trong `initState`

### Debug tips

1. Kiểm tra console logs
2. Sử dụng `debugPrint()` để debug data
3. Kiểm tra provider state
4. Verify column configuration

## Kết luận

Expandable Table cung cấp một giải pháp mạnh mẽ để hiển thị dữ liệu hierarchical với column alignment. Widget này rất phù hợp cho các ứng dụng cần hiển thị dữ liệu phức tạp với khả năng drill-down.
