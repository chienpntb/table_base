# Hướng Dẫn Sử Dụng Hierarchical Table

## Tổng Quan

Hierarchical Table là một widget mở rộng từ table hiện tại, hỗ trợ hiển thị dữ liệu phân cấp với khả năng collapse/expand các hàng con. Widget này được thiết kế để dễ sử dụng và tối ưu hiệu năng.

## Tính Năng Chính

### ✅ Đã Hoàn Thành

1. **Cấu trúc phân cấp**: Hỗ trợ hàng cha và hàng con với nhiều cấp độ
2. **Collapse/Expand**: Nhấn vào mũi tên để mở/đóng các hàng con
3. **Animation mượt mà**: Hiệu ứng chuyển động khi collapse/expand
4. **Indentation**: Hàng con được thụt lề để phân biệt rõ ràng
5. **Màu sắc phân biệt**: Hàng cha màu trắng, hàng con màu xám nhạt
6. **Tương thích**: Hoạt động với tất cả tính năng của table hiện tại (sort, filter, pagination, selection)

## Cách Sử Dụng

### 1. Import Package

```dart
import 'package:table_base/widgets/table/table.dart';
```

### 2. Tạo Model Dữ Liệu

```dart
class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final double salary;
  final DateTime joinDate;
  final bool isManager;
  final List<Employee>? subordinates;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.salary,
    required this.joinDate,
    this.isManager = false,
    this.subordinates,
  });
}
```

### 3. Tạo Provider

```dart
final hierarchicalTableProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<Employee>, GenericTableState<Employee>>((ref) {
  return HierarchicalTableNotifier();
});

class HierarchicalTableNotifier extends TableNotifier<Employee> {
  @override
  Future<List<Employee>> generateData() async {
    // Trả về dữ liệu phân cấp
    return [
      Employee(
        id: 'emp_001',
        name: 'Nguyễn Văn A',
        email: 'nguyenvana@company.com',
        department: 'IT',
        position: 'Manager',
        salary: 15000000,
        joinDate: DateTime(2020, 1, 15),
        isManager: true,
        subordinates: [
          Employee(
            id: 'emp_002',
            name: 'Trần Thị B',
            email: 'tranthib@company.com',
            department: 'IT',
            position: 'Developer',
            salary: 12000000,
            joinDate: DateTime(2021, 3, 10),
          ),
          // ... thêm các nhân viên khác
        ],
      ),
      // ... thêm các manager khác
    ];
  }
}
```

### 4. Sử Dụng Widget

```dart
HierarchicalTable<Employee>(
  tableProvider: hierarchicalTableProvider,
  hierarchicalColumns: [
    HierarchicalTableColumnData.simple(
      name: 'Tên nhân viên',
      key: 'name',
      width: 200,
      flex: 1,
    ),
    HierarchicalTableColumnData.simple(
      name: 'Email',
      key: 'email',
      width: 250,
      flex: 1,
    ),
    HierarchicalTableColumnData.simple(
      name: 'Phòng ban',
      key: 'department',
      width: 120,
      flex: 0.5,
    ),
    HierarchicalTableColumnData.simple(
      name: 'Vị trí',
      key: 'position',
      width: 150,
      flex: 0.8,
    ),
    HierarchicalTableColumnData.simple(
      name: 'Lương',
      key: 'salary',
      width: 120,
      flex: 0.6,
    ),
    HierarchicalTableColumnData.simple(
      name: 'Ngày vào',
      key: 'joinDate',
      width: 120,
      flex: 0.6,
    ),
  ],
  valueGetter: (employee, columnIndex) {
    switch (columnIndex) {
      case 0: return employee.name;
      case 1: return employee.email;
      case 2: return employee.department;
      case 3: return employee.position;
      case 4: return employee.salary;
      case 5: return employee.joinDate;
      default: return '';
    }
  },
  cellBuilderByKey: (employee, key) {
    switch (key) {
      case 'salary':
        return TableCellData(
          widget: Text(
            '${employee.salary.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            )} VNĐ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      case 'joinDate':
        return TableCellData(
          widget: Text(
            '${employee.joinDate.day}/${employee.joinDate.month}/${employee.joinDate.year}',
          ),
        );
      default:
        return null;
    }
  },
  idGetter: (employee) => employee.id,
  rowIdGetter: (employee) => employee.id,
  isParentRowGetter: (employee) => employee.isManager,
  getChildItems: (employee) => employee.subordinates ?? [],
  showCheckboxColumn: true,
  showActionsColumn: true,
  enableRowSelection: true,
  enableRowHover: true,
  showAlternatingRowColors: true,
  childRowBackgroundColor: Colors.grey.shade100,
  childRowPadding: const EdgeInsets.only(left: 32.0),
  enableCollapseAnimation: true,
  onEdit: (employee) {
    // Xử lý sửa nhân viên
  },
  onDelete: (employee) {
    // Xử lý xóa nhân viên
  },
  onRowTap: (employee) {
    // Xử lý khi nhấn vào hàng
  },
)
```

## Các Tham Số Quan Trọng

### Callbacks Bắt Buộc

- `tableProvider`: Provider quản lý trạng thái bảng
- `hierarchicalColumns`: Danh sách cấu hình các cột
- `valueGetter`: Callback lấy giá trị từ item theo cột
- `idGetter`: Callback lấy ID từ item để chọn/bỏ chọn
- `rowIdGetter`: Callback lấy rowId để quản lý collapse/expand
- `isParentRowGetter`: Callback kiểm tra item có phải hàng cha không
- `getChildItems`: Callback lấy danh sách item con từ item cha

### Callbacks Tùy Chọn

- `cellBuilderByKey`: Tùy chỉnh hiển thị ô theo key cột
- `cellsBuilder`: Tùy chỉnh hiển thị ô theo index cột
- `onEdit`: Xử lý khi nhấn nút sửa
- `onDelete`: Xử lý khi nhấn nút xóa
- `onRowTap`: Xử lý khi nhấn vào hàng

### Cấu Hình Hiển Thị

- `showCheckboxColumn`: Hiển thị cột checkbox (mặc định: true)
- `showActionsColumn`: Hiển thị cột actions (mặc định: false)
- `enableRowSelection`: Cho phép chọn hàng (mặc định: true)
- `enableRowHover`: Hiệu ứng hover (mặc định: true)
- `showAlternatingRowColors`: Màu xen kẽ (mặc định: false)
- `enableCollapseAnimation`: Animation collapse/expand (mặc định: true)

### Cấu Hình Màu Sắc

- `childRowBackgroundColor`: Màu nền hàng con (mặc định: Colors.grey.shade100)
- `childRowPadding`: Padding hàng con (mặc định: EdgeInsets.only(left: 32.0))
- `alternateColor`: Màu xen kẽ
- `hoverColor`: Màu khi hover
- `selectedRowColor`: Màu khi chọn

## Cấu Trúc Dữ Liệu Phân Cấp

### HierarchicalTableColumnData

```dart
HierarchicalTableColumnData.simple(
  name: 'Tên cột',
  key: 'column_key',
  width: 200,
  flex: 1,
  filterType: FilterType.select, // Tùy chọn
  isResizable: true,
  isSortable: true,
  isFilterable: true,
)
```

### HierarchicalTableColumnData với Cột Con

```dart
HierarchicalTableColumnData.withChildren(
  name: 'Cột Cha',
  key: 'parent_column',
  width: 300,
  childColumns: [
    HierarchicalTableColumnData.simple(
      name: 'Cột Con 1',
      key: 'child_column_1',
      width: 150,
    ),
    HierarchicalTableColumnData.simple(
      name: 'Cột Con 2',
      key: 'child_column_2',
      width: 150,
    ),
  ],
  isCollapsible: true,
  isCollapsedByDefault: true,
)
```

## Tối Ưu Hiệu Năng

### 1. Lazy Loading
- Dữ liệu con chỉ được tải khi hàng cha được expand
- Sử dụng `getChildItems` callback để tải dữ liệu theo yêu cầu

### 2. Animation Optimization
- Animation được tối ưu với `SingleTickerProviderStateMixin`
- Sử dụng `AnimatedBuilder` để tránh rebuild không cần thiết

### 3. State Management
- Sử dụng Riverpod để quản lý trạng thái hiệu quả
- Trạng thái collapse được lưu trong `TableCollapseState`

## Ví Dụ Hoàn Chỉnh

Xem file `lib/widgets/table/example/hierarchical_table_example.dart` để có ví dụ hoàn chỉnh về cách sử dụng HierarchicalTable.

## Lưu Ý Quan Trọng

1. **Performance**: Với dữ liệu lớn, nên sử dụng lazy loading cho các hàng con
2. **Memory**: Trạng thái collapse được lưu trong memory, cần cân nhắc với dữ liệu rất lớn
3. **Animation**: Có thể tắt animation bằng `enableCollapseAnimation: false` để tăng hiệu năng
4. **Compatibility**: Widget tương thích với tất cả tính năng của table hiện tại

## Troubleshooting

### Lỗi Thường Gặp

1. **"Classes can only extend other classes"**: Đảm bảo import đúng `TableNotifier`
2. **"Undefined class 'FilterType'"**: Import `table_state.dart` trong model
3. **Animation không mượt**: Kiểm tra `enableCollapseAnimation` và `animationDuration`

### Debug Tips

1. Sử dụng `print()` trong các callback để debug
2. Kiểm tra `rowIdGetter` trả về unique ID
3. Đảm bảo `isParentRowGetter` trả về đúng boolean
4. Kiểm tra `getChildItems` trả về đúng danh sách con
