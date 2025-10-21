# 📊 Hierarchical Table - Hướng dẫn sử dụng

## 🎯 Tổng quan

Hierarchical Table là tính năng mở rộng của `RiverpodTable` hiện tại, cho phép hiển thị dữ liệu dạng phân cấp với khả năng collapse/expand hàng cha-con. Tính năng này được tích hợp vào `RiverpodTable` hiện tại mà không phá vỡ code cũ.

## ✨ Tính năng chính

- 🔄 **Collapse/Expand**: Thu gọn/mở rộng hàng con với animation mượt mà
- 🎨 **Hiển thị phân cấp**: Indentation và màu sắc phân biệt hàng cha/con
- 🔧 **Tương thích hoàn toàn**: Tất cả tính năng cũ vẫn hoạt động (sorting, filtering, pagination, selection, column resizing)
- ⚡ **Migration đơn giản**: Chỉ cần thêm 3 thuộc tính để có hierarchical
- 🎯 **Linh hoạt**: Hỗ trợ nhiều kiểu dữ liệu và cấu trúc phân cấp

## 🚀 Cách sử dụng

### 1. **Migration từ table cũ**

#### Trước (table cũ):
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

#### Sau (table mới với hierarchical):
```dart
RiverpodTable<Employee>(
  tableProvider: employeeProvider, // ✅ Cùng provider
  columns: [
    TableColumnData(name: 'ID', key: 'id', width: 100),
    TableColumnData(name: 'Tên', key: 'name', width: 200),
    TableColumnData(name: 'Chức vụ', key: 'position', width: 150),
  ],
  valueGetter: (employee, index) { // ✅ Cùng logic
    switch (index) {
      case 0: return employee.id;
      case 1: return employee.name;
      case 2: return employee.position;
      default: return '';
    }
  },
  
  // 🆕 CHỈ THÊM 3 THUỘC TÍNH NÀY:
  isParentRowGetter: (employee) => employee.subordinates?.isNotEmpty == true,
  getChildItems: (employee) => employee.subordinates ?? [],
  rowIdGetter: (employee) => employee.id,
)
```

### 2. **Các thuộc tính hierarchical**

| Thuộc tính | Kiểu | Bắt buộc | Mô tả |
|------------|------|----------|-------|
| `isParentRowGetter` | `bool Function(T item)?` | ✅ | Kiểm tra xem item có phải hàng cha không |
| `getChildItems` | `List<T> Function(T item)?` | ✅ | Lấy danh sách item con từ item cha |
| `rowIdGetter` | `String Function(T item)?` | ✅ | Lấy ID của hàng (dùng cho collapse/expand) |
| `enableCollapseAnimation` | `bool` | ❌ | Bật/tắt animation (mặc định: true) |
| `childRowBackgroundColor` | `Color?` | ❌ | Màu nền cho hàng con |
| `childRowPadding` | `EdgeInsets?` | ❌ | Padding cho hàng con (mặc định: left: 24px) |

## 📋 Ví dụ thực tế

### **Ví dụ 1: Dữ liệu có cấu trúc phân cấp sẵn**

```dart
class Department {
  final String id;
  final String name;
  final String manager;
  final List<Employee> employees; // ✅ Đã có cấu trúc phân cấp
}

class Employee {
  final String id;
  final String name;
  final String position;
}

// Sử dụng
RiverpodTable<Department>(
  tableProvider: departmentProvider,
  columns: [
    TableColumnData(name: 'ID', key: 'id', width: 100),
    TableColumnData(name: 'Tên phòng ban', key: 'name', width: 200),
    TableColumnData(name: 'Trưởng phòng', key: 'manager', width: 150),
  ],
  valueGetter: (dept, index) {
    switch (index) {
      case 0: return dept.id;
      case 1: return dept.name;
      case 2: return dept.manager;
      default: return '';
    }
  },
  
  // Logic phân cấp
  isParentRowGetter: (dept) => dept.employees.isNotEmpty,
  getChildItems: (dept) => dept.employees,
  rowIdGetter: (dept) => dept.id,
)
```

### **Ví dụ 2: Dữ liệu từ nhiều bảng khác nhau**

```dart
class Order {
  final String id;
  final String customerName;
  final List<OrderItem>? items;
}

class OrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double price;
}

// Sử dụng với convert data
RiverpodTable<Order>(
  tableProvider: orderProvider,
  columns: [
    TableColumnData(name: 'ID', key: 'id', width: 100),
    TableColumnData(name: 'Tên', key: 'name', width: 200),
    TableColumnData(name: 'Số lượng', key: 'quantity', width: 100),
    TableColumnData(name: 'Giá', key: 'price', width: 100),
  ],
  valueGetter: (order, index) {
    switch (index) {
      case 0: return order.id;
      case 1: return order.name;
      case 2: return order.quantity;
      case 3: return order.price;
      default: return '';
    }
  },
  
  // Logic phân cấp với convert
  isParentRowGetter: (order) => order.items?.isNotEmpty == true,
  getChildItems: (order) {
    // 🔄 Convert OrderItem thành Order để hiển thị
    return order.items?.map((item) => Order(
      id: item.id,
      name: item.productName,
      quantity: item.quantity,
      price: item.price,
      items: null, // Không có con
    )).toList() ?? [];
  },
  rowIdGetter: (order) => order.id,
)
```

### **Ví dụ 3: Dữ liệu dựa trên business rule**

```dart
class Product {
  final String id;
  final String name;
  final String category;
  final String? parentId; // ID của sản phẩm cha
}

// Sử dụng với logic business
RiverpodTable<Product>(
  tableProvider: productProvider,
  columns: [
    TableColumnData(name: 'ID', key: 'id', width: 100),
    TableColumnData(name: 'Tên sản phẩm', key: 'name', width: 200),
    TableColumnData(name: 'Danh mục', key: 'category', width: 150),
  ],
  valueGetter: (product, index) {
    switch (index) {
      case 0: return product.id;
      case 1: return product.name;
      case 2: return product.category;
      default: return '';
    }
  },
  
  // Logic phân cấp dựa trên parentId
  isParentRowGetter: (product) => product.parentId == null,
  getChildItems: (product) {
    // Lấy tất cả sản phẩm con từ data hiện tại
    return allProducts.where((p) => p.parentId == product.id).toList();
  },
  rowIdGetter: (product) => product.id,
)
```

## 🎨 Tùy chỉnh giao diện

### **Màu sắc và styling**

```dart
RiverpodTable<Employee>(
  // ... các thuộc tính khác
  
  // 🎨 Tùy chỉnh giao diện
  enableCollapseAnimation: true, // Animation mượt mà
  childRowBackgroundColor: Colors.blue.withOpacity(0.1), // Nền xanh nhạt cho hàng con
  childRowPadding: const EdgeInsets.only(left: 32.0), // Indentation 32px
  
  // 🎯 Custom hiển thị để phân biệt hàng cha/con
  cellBuilderByKey: (employee, key) {
    final isChildRow = employee.subordinates == null;
    
    if (key == 'name' && isChildRow) {
      return TableCellData(
        widget: Text(
          '  └─ ${employee.name}', // Indentation cho hàng con
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return null; // Sử dụng valueGetter mặc định
  },
)
```

## 🔧 Xử lý các trường hợp đặc biệt

### **1. Dữ liệu không có cấu trúc phân cấp**

```dart
// Nếu data không có cấu trúc phân cấp, không thêm 3 thuộc tính
RiverpodTable<Employee>(
  tableProvider: employeeProvider,
  columns: [...],
  valueGetter: (employee, index) => employee.getField(index),
  // Không có isParentRowGetter, getChildItems, rowIdGetter
  // => Table hoạt động bình thường như cũ
)
```

### **2. Dữ liệu có nhiều cấp phân cấp**

```dart
class Category {
  final String id;
  final String name;
  final List<Category>? subcategories;
}

// Hỗ trợ nhiều cấp (hiện tại chỉ hỗ trợ 2 cấp: cha-con)
RiverpodTable<Category>(
  // ... các thuộc tính khác
  
  isParentRowGetter: (category) => category.subcategories?.isNotEmpty == true,
  getChildItems: (category) => category.subcategories ?? [],
  rowIdGetter: (category) => category.id,
)
```

### **3. Dữ liệu động từ API**

```dart
class EmployeeNotifier extends TableNotifier<Employee> {
  @override
  Future<List<Employee>> generateData() async {
    // Lấy dữ liệu từ API
    final employees = await _employeeService.getAllEmployees();
    
    // Xử lý dữ liệu phân cấp
    final hierarchicalData = employees.map((emp) {
      final subordinates = employees
          .where((sub) => sub.managerId == emp.id)
          .toList();
      
      return emp.copyWith(subordinates: subordinates);
    }).toList();
    
    return hierarchicalData;
  }
}
```

## ⚠️ Lưu ý quan trọng

### **1. Kiểu dữ liệu**
- `RiverpodTable<T>` chỉ có thể hiển thị kiểu `T`
- Nếu hàng con có kiểu khác, phải convert về kiểu `T` trong `getChildItems`

### **2. Performance**
- Dữ liệu phân cấp được xử lý trong memory
- Với dữ liệu lớn, nên implement pagination và lazy loading

### **3. State management**
- Collapse/expand state được lưu trong `TableCollapseState`
- State được persist trong session, không persist qua restart app

### **4. Tương thích**
- Tất cả tính năng cũ vẫn hoạt động bình thường
- Không ảnh hưởng đến performance của table thường

## 🐛 Troubleshooting

### **Lỗi thường gặp:**

1. **"The returned type 'X' isn't returnable from a 'T' function"**
   ```dart
   // ❌ Sai
   getChildItems: (order) => order.items, // OrderItem không thể hiển thị
   
   // ✅ Đúng
   getChildItems: (order) => order.items?.map((item) => Order(...)).toList() ?? [],
   ```

2. **"Classes can only extend other classes"**
   ```dart
   // ❌ Sai
   class MyNotifier extends TableNotifierInterface<Employee>
   
   // ✅ Đúng
   class MyNotifier extends TableNotifier<Employee>
   ```

3. **Hàng con không hiển thị**
   ```dart
   // Kiểm tra:
   // 1. isParentRowGetter trả về true cho hàng cha
   // 2. getChildItems trả về danh sách không rỗng
   // 3. rowIdGetter trả về string unique
   ```

## 📚 Tài liệu tham khảo

- [RiverpodTable Documentation](./docs/riverpod_table.md)
- [Table State Management](./docs/table_state.md)
- [Examples](./lib/widgets/table/example/)

## 🤝 Hỗ trợ

Nếu gặp vấn đề, vui lòng:
1. Kiểm tra các ví dụ trong thư mục `example/`
2. Đảm bảo đã implement đúng 3 thuộc tính bắt buộc
3. Kiểm tra kiểu dữ liệu trong `getChildItems`

---

**Chúc bạn sử dụng thành công! 🎉**
