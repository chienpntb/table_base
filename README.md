# 📊 Table Base - Flutter Table Component

## 🎯 Tổng quan

Table Base là một component table mạnh mẽ cho Flutter với hỗ trợ đầy đủ các tính năng hiện đại và khả năng mở rộng cao.

## ✨ Tính năng chính

### **Tính năng cơ bản**
- 📊 **Hiển thị dữ liệu**: Bảng dữ liệu với khả năng cuộn ngang/dọc
- 🔄 **Sorting**: Sắp xếp theo nhiều cột
- 🔍 **Filtering**: Lọc dữ liệu theo điều kiện
- 📄 **Pagination**: Phân trang với tùy chọn số lượng hiển thị
- ✅ **Selection**: Chọn nhiều hàng với checkbox
- 📏 **Column Resize**: Thay đổi kích thước cột
- 🎨 **Customizable**: Tùy chỉnh màu sắc, font, padding

### **Tính năng nâng cao**
- 🌳 **Hierarchical Table**: Hiển thị dữ liệu phân cấp với collapse/expand
- 🎭 **Animation**: Animation mượt mà cho collapse/expand
- 🎯 **Actions**: Cột hành động (sửa, xóa, tùy chỉnh)
- 🔧 **Flexible Layout**: Hệ thống flex layout thông minh
- 📱 **Responsive**: Tự động điều chỉnh theo kích thước màn hình

## 🚀 Cài đặt

### **1. Thêm dependency**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  # ... các dependency khác
```

### **2. Import**
```dart
import 'package:table_base/widgets/table/table.dart';
```

### **3. Sử dụng ProviderScope**
```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

## 📚 Hướng dẫn sử dụng

### **Table cơ bản**
```dart
RiverpodTable<Employee>(
  tableProvider: employeeProvider,
  columns: [
    TableColumnData(name: 'ID', key: 'id', width: 100),
    TableColumnData(name: 'Tên', key: 'name', width: 200),
    TableColumnData(name: 'Chức vụ', key: 'position', width: 150),
  ],
  valueGetter: (employee, index) {
    switch (index) {
      case 0: return employee.id;
      case 1: return employee.name;
      case 2: return employee.position;
      default: return '';
    }
  },
)
```

### **Hierarchical Table**
```dart
RiverpodTable<Employee>(
  tableProvider: employeeProvider,
  columns: [
    TableColumnData(name: 'ID', key: 'id', width: 100),
    TableColumnData(name: 'Tên', key: 'name', width: 200),
    TableColumnData(name: 'Chức vụ', key: 'position', width: 150),
  ],
  valueGetter: (employee, index) {
    switch (index) {
      case 0: return employee.id;
      case 1: return employee.name;
      case 2: return employee.position;
      default: return '';
    }
  },
  
  // 🆕 Tính năng hierarchical
  isParentRowGetter: (employee) => employee.subordinates?.isNotEmpty == true,
  getChildItems: (employee) => employee.subordinates ?? [],
  rowIdGetter: (employee) => employee.id,
)
```

## 📁 Cấu trúc project

```
lib/
├── widgets/
│   └── table/
│       ├── models/
│       │   ├── table_model.dart
│       │   └── hierarchical_table_model.dart
│       ├── providers/
│       │   ├── table_state.dart
│       │   ├── table_notifier.dart
│       │   └── table_notifier_interface.dart
│       ├── widgets/
│       │   ├── riverpod_table.dart
│       │   ├── hierarchical_table.dart
│       │   ├── collapse_expand_widget.dart
│       │   └── ...
│       └── example/
│           ├── hierarchical_table_example.dart
│           ├── simple_hierarchical_demo.dart
│           ├── riverpod_hierarchical_demo.dart
│           └── ...
├── main.dart
└── ...
```

## 🎨 Customization

### **Màu sắc**
```dart
RiverpodTable<Employee>(
  // ... các thuộc tính khác
  
  // 🎨 Tùy chỉnh màu sắc
  headerColor: Colors.blue,
  textHeaderColor: Colors.white,
  alternateColor: Colors.grey.shade100,
  hoverColor: Colors.blue.withOpacity(0.1),
  selectedRowColor: Colors.blue.withOpacity(0.2),
  childRowBackgroundColor: Colors.green.withOpacity(0.1), // Cho hierarchical
)
```

### **Kích thước**
```dart
RiverpodTable<Employee>(
  // ... các thuộc tính khác
  
  // 📏 Tùy chỉnh kích thước
  rowHeight: 48,
  headerHeight: 48,
  cellPadding: const EdgeInsets.all(12),
  childRowPadding: const EdgeInsets.only(left: 24), // Cho hierarchical
)
```

### **Animation**
```dart
RiverpodTable<Employee>(
  // ... các thuộc tính khác
  
  // 🎭 Tùy chỉnh animation
  enableCollapseAnimation: true, // Cho hierarchical
)
```

## 🔧 State Management

### **Provider**
```dart
final employeeProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<Employee>, GenericTableState<Employee>>(
  (ref) => EmployeeNotifier(),
);
```

### **Notifier**
```dart
class EmployeeNotifier extends TableNotifier<Employee> {
  @override
  Future<List<Employee>> generateData() async {
    final data = await _employeeService.getAllEmployees();
    
    state = state.copyWith(
      allData: data,
      filteredData: data,
      currentPageData: data,
      isLoading: false,
    );
    
    return data;
  }
}
```

## 📖 Tài liệu

- [📊 Hierarchical Table Usage](./README_HIERARCHICAL_TABLE_USAGE.md) - Hướng dẫn chi tiết
- [🚀 Migration Guide](./MIGRATION_GUIDE.md) - Hướng dẫn migration nhanh
- [📁 Examples](./lib/widgets/table/example/) - Các ví dụ thực tế

## 🎯 Examples

### **Demo có sẵn**
1. **Demo Đơn Giản** - Ví dụ cơ bản với dữ liệu sản phẩm
2. **Demo Cực Đơn Giản** - Ví dụ tối giản nhất (2 cột)
3. **Test Kích Thước** - Demo kiểm tra kích thước hàng con = hàng cha
4. **So Sánh Kích Thước** - Demo rõ ràng để kiểm tra kích thước
5. **RiverpodTable Hierarchical** - Sử dụng RiverpodTable với hierarchical
6. **Ví Dụ Đầy Đủ** - Ví dụ hoàn chỉnh với nhân viên

### **Chạy examples**
```bash
flutter run
# Chọn demo từ danh sách
```

## ⚠️ Lưu ý

### **Performance**
- Với dữ liệu lớn (>1000 rows), nên implement pagination
- Sử dụng `lazy loading` cho hierarchical data
- Cache kết quả tính toán để tối ưu performance

### **Tương thích**
- Flutter >= 3.0.0
- Dart >= 3.0.0
- flutter_riverpod >= 2.4.9

### **Best Practices**
1. Sử dụng `TableColumnData` với `flex` để responsive
2. Implement `cellBuilderByKey` cho custom cell
3. Sử dụng `idGetter` để selection hoạt động đúng
4. Test với dữ liệu thực tế trước khi deploy

## 🤝 Đóng góp

1. Fork project
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## 📄 License

MIT License - xem file [LICENSE](./LICENSE) để biết thêm chi tiết.

## 📞 Hỗ trợ

- 📧 Email: support@tablebase.com
- 💬 Discord: [Table Base Community](https://discord.gg/tablebase)
- 📖 Documentation: [docs.tablebase.com](https://docs.tablebase.com)
- 🐛 Issues: [GitHub Issues](https://github.com/tablebase/issues)

---

**Cảm ơn bạn đã sử dụng Table Base! 🎉**