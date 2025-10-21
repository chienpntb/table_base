# 🎯 Hierarchical Table - Hướng Dẫn Sử Dụng

## 📋 Tổng Quan

Hierarchical Table là một widget mở rộng từ table hiện tại, hỗ trợ hiển thị dữ liệu phân cấp với khả năng collapse/expand các hàng con. Widget này được thiết kế để dễ sử dụng và tối ưu hiệu năng.

## 🚀 Cách Chạy Demo

### 1. Chạy ứng dụng
```bash
flutter run
```

### 2. Chọn ví dụ demo
Khi ứng dụng chạy, bạn sẽ thấy màn hình chọn ví dụ với 3 tùy chọn:

- **🔵 Demo Đơn Giản**: Ví dụ với dữ liệu sản phẩm, dễ hiểu và test nhanh
- **🟣 Demo Cực Đơn Giản**: Ví dụ tối giản nhất, chỉ có 2 cột
- **🟠 Ví Dụ Đầy Đủ**: Ví dụ hoàn chỉnh với nhân viên, có đầy đủ tính năng

### 3. Test tính năng
- Nhấn vào **mũi tên** để mở/đóng các hàng con
- Quan sát **animation** mượt mà khi collapse/expand
- Chú ý **màu sắc** phân biệt: hàng cha (trắng), hàng con (xám nhạt)
- Thử **chọn nhiều hàng** với checkbox (nếu có)

## 📁 Cấu Trúc Files

```
lib/widgets/table/
├── models/
│   ├── hierarchical_table_model.dart    # Models phân cấp
│   └── table_model.dart                 # Models table gốc
├── widgets/
│   ├── hierarchical_table.dart         # Widget table phân cấp chính
│   ├── collapse_expand_widget.dart     # Widget collapse/expand
│   └── example/
│       ├── hierarchical_table_example.dart    # Ví dụ đầy đủ
│       ├── simple_hierarchical_demo.dart      # Ví dụ đơn giản
│       └── ultra_simple_demo.dart             # Ví dụ cực đơn giản
├── providers/
│   ├── table_state.dart                # State với collapse support
│   └── table_notifier.dart             # Notifier với collapse methods
└── README_HIERARCHICAL.md              # Tài liệu chi tiết
```

## 🎨 Tính Năng Chính

### ✅ Đã Hoàn Thành

1. **🔄 Collapse/Expand**: Nhấn mũi tên để mở/đóng hàng con
2. **🎬 Animation**: Hiệu ứng mượt mà khi collapse/expand  
3. **📐 Indentation**: Hàng con được thụt lề rõ ràng
4. **🎨 Màu sắc**: Phân biệt hàng cha (trắng) và hàng con (xám)
5. **🔗 Tương thích**: Hoạt động với sort, filter, pagination, selection
6. **⚡ Tối ưu**: Lazy loading và performance optimization

## 💻 Cách Sử Dụng Cơ Bản

### 1. Import Package
```dart
import 'package:table_base/widgets/table/table.dart';
```

### 2. Tạo Model Dữ Liệu
```dart
class MyItem {
  final String id;
  final String name;
  final bool isParent;
  final List<MyItem>? children;

  MyItem({
    required this.id,
    required this.name,
    this.isParent = false,
    this.children,
  });
}
```

### 3. Tạo Provider
```dart
final myTableProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<MyItem>, GenericTableState<MyItem>>((ref) {
  return MyTableNotifier();
});

class MyTableNotifier extends TableNotifier<MyItem> {
  @override
  Future<List<MyItem>> generateData() async {
    return [
      MyItem(
        id: 'parent1',
        name: 'Nhóm A',
        isParent: true,
        children: [
          MyItem(id: 'child1', name: 'Item A1'),
          MyItem(id: 'child2', name: 'Item A2'),
        ],
      ),
    ];
  }
}
```

### 4. Sử Dụng Widget
```dart
HierarchicalTable<MyItem>(
  tableProvider: myTableProvider,
  hierarchicalColumns: [
    HierarchicalTableColumnData.simple(
      name: 'Tên',
      key: 'name',
      width: 200,
    ),
  ],
  valueGetter: (item, columnIndex) => item.name,
  idGetter: (item) => item.id,
  rowIdGetter: (item) => item.id,
  isParentRowGetter: (item) => item.isParent,
  getChildItems: (item) => item.children ?? [],
)
```

## 🔧 Các Tham Số Quan Trọng

### Callbacks Bắt Buộc
- `tableProvider`: Provider quản lý trạng thái bảng
- `hierarchicalColumns`: Danh sách cấu hình các cột
- `valueGetter`: Callback lấy giá trị từ item theo cột
- `idGetter`: Callback lấy ID từ item để chọn/bỏ chọn
- `rowIdGetter`: Callback lấy rowId để quản lý collapse/expand
- `isParentRowGetter`: Callback kiểm tra item có phải hàng cha không
- `getChildItems`: Callback lấy danh sách item con từ item cha

### Cấu Hình Hiển Thị
- `showCheckboxColumn`: Hiển thị cột checkbox (mặc định: true)
- `showActionsColumn`: Hiển thị cột actions (mặc định: false)
- `enableRowSelection`: Cho phép chọn hàng (mặc định: true)
- `enableRowHover`: Hiệu ứng hover (mặc định: true)
- `enableCollapseAnimation`: Animation collapse/expand (mặc định: true)

### Cấu Hình Màu Sắc
- `childRowBackgroundColor`: Màu nền hàng con (mặc định: Colors.grey.shade100)
- `childRowPadding`: Padding hàng con (mặc định: EdgeInsets.only(left: 32.0))

## 📚 Ví Dụ Chi Tiết

### Ví Dụ 1: Demo Cực Đơn Giản
```dart
// Xem: lib/widgets/table/example/ultra_simple_demo.dart
// - Chỉ có 2 cột: Tên và Giá trị
// - Dữ liệu đơn giản: Nhóm A, B, C với các item con
// - Không có checkbox, actions
// - Phù hợp để hiểu cơ bản
```

### Ví Dụ 2: Demo Đơn Giản
```dart
// Xem: lib/widgets/table/example/simple_hierarchical_demo.dart
// - Dữ liệu sản phẩm: Điện thoại, Laptop, Phụ kiện
// - Có custom cell builder cho giá và tồn kho
// - Có checkbox để chọn nhiều sản phẩm
// - Phù hợp để test tính năng
```

### Ví Dụ 3: Ví Dụ Đầy Đủ
```dart
// Xem: lib/widgets/table/example/hierarchical_table_example.dart
// - Dữ liệu nhân viên với manager/subordinate
// - Có đầy đủ tính năng: sort, filter, pagination
// - Có actions column với edit/delete
// - Phù hợp để hiểu cách sử dụng trong thực tế
```

## 🎯 Tips Sử Dụng

### 1. Performance
- Với dữ liệu lớn, sử dụng lazy loading trong `getChildItems`
- Có thể tắt animation bằng `enableCollapseAnimation: false`
- Sử dụng `const` constructor khi có thể

### 2. UI/UX
- Đặt `childRowPadding` phù hợp để phân biệt rõ ràng
- Sử dụng màu sắc khác biệt cho hàng cha/con
- Thêm icon hoặc styling đặc biệt cho hàng cha

### 3. Data Structure
- Đảm bảo `rowIdGetter` trả về unique ID
- `isParentRowGetter` phải trả về đúng boolean
- `getChildItems` phải trả về đúng danh sách con

## 🐛 Troubleshooting

### Lỗi Thường Gặp
1. **"Classes can only extend other classes"**: Import đúng `TableNotifier`
2. **"Undefined class 'FilterType'"**: Import `table_state.dart`
3. **Animation không mượt**: Kiểm tra `enableCollapseAnimation`

### Debug Tips
1. Sử dụng `print()` trong các callback để debug
2. Kiểm tra `rowIdGetter` trả về unique ID
3. Đảm bảo `isParentRowGetter` trả về đúng boolean
4. Kiểm tra `getChildItems` trả về đúng danh sách con

## 📖 Tài Liệu Tham Khảo

- **Tài liệu chi tiết**: `lib/widgets/table/README_HIERARCHICAL.md`
- **Ví dụ đầy đủ**: `lib/widgets/table/example/hierarchical_table_example.dart`
- **Ví dụ đơn giản**: `lib/widgets/table/example/simple_hierarchical_demo.dart`
- **Ví dụ cực đơn giản**: `lib/widgets/table/example/ultra_simple_demo.dart`

## 🎉 Kết Luận

Hierarchical Table đã sẵn sàng sử dụng với đầy đủ tính năng:
- ✅ Collapse/Expand với animation
- ✅ Hiển thị phân cấp với indentation
- ✅ Màu sắc phân biệt hàng cha/con
- ✅ Tương thích với tất cả tính năng table hiện tại
- ✅ Tối ưu hiệu năng và dễ sử dụng

**Chạy `flutter run` để test ngay!** 🚀
