# 🚀 Migration Guide - Hierarchical Table

## ⚡ Migration nhanh (5 phút)

### **Bước 1: Kiểm tra data hiện tại**
```dart
// Data của bạn có cấu trúc phân cấp không?
class YourData {
  final String id;
  final String name;
  final List<YourData>? children; // ✅ Có sẵn
  // hoặc
  final String? parentId; // ✅ Có parentId
}
```

### **Bước 2: Thêm 3 thuộc tính**
```dart
RiverpodTable<YourData>(
  // ... tất cả thuộc tính cũ giữ nguyên
  
  // 🆕 THÊM 3 DÒNG NÀY:
  isParentRowGetter: (item) => item.children?.isNotEmpty == true,
  getChildItems: (item) => item.children ?? [],
  rowIdGetter: (item) => item.id,
)
```

### **Bước 3: Test**
```dart
// Chạy app và kiểm tra:
// 1. Hàng cha có nút mũi tên
// 2. Click mũi tên để thu gọn/mở rộng
// 3. Hàng con có màu nền khác
```

## 🔄 Các trường hợp phổ biến

### **Trường hợp 1: Data có cấu trúc phân cấp sẵn**
```dart
// ✅ Đơn giản nhất
isParentRowGetter: (item) => item.children?.isNotEmpty == true,
getChildItems: (item) => item.children ?? [],
rowIdGetter: (item) => item.id,
```

### **Trường hợp 2: Data dựa trên parentId**
```dart
// 🔄 Cần logic để lấy children
isParentRowGetter: (item) => item.parentId == null,
getChildItems: (item) => allItems.where((i) => i.parentId == item.id).toList(),
rowIdGetter: (item) => item.id,
```

### **Trường hợp 3: Data từ nhiều bảng**
```dart
// 🔄 Cần convert data
isParentRowGetter: (order) => order.items?.isNotEmpty == true,
getChildItems: (order) => order.items?.map((item) => Order(
  id: item.id,
  name: item.productName,
  // ... convert các field khác
)).toList() ?? [],
rowIdGetter: (order) => order.id,
```

## ⚠️ Lưu ý quan trọng

1. **Kiểu dữ liệu**: `RiverpodTable<T>` chỉ hiển thị kiểu `T`
2. **Convert data**: Nếu hàng con có kiểu khác, phải convert về kiểu `T`
3. **Performance**: Với data lớn, nên implement pagination
4. **Tương thích**: Tất cả tính năng cũ vẫn hoạt động

## 🎨 Tùy chỉnh giao diện

```dart
RiverpodTable<YourData>(
  // ... các thuộc tính khác
  
  // 🎨 Tùy chỉnh
  enableCollapseAnimation: true,
  childRowBackgroundColor: Colors.blue.withOpacity(0.1),
  childRowPadding: const EdgeInsets.only(left: 32.0),
)
```

## 🐛 Lỗi thường gặp

### **Lỗi 1: "isn't returnable from a 'T' function"**
```dart
// ❌ Sai
getChildItems: (order) => order.items, // OrderItem không thể hiển thị

// ✅ Đúng
getChildItems: (order) => order.items?.map((item) => Order(...)).toList() ?? [],
```

### **Lỗi 2: Hàng con không hiển thị**
```dart
// Kiểm tra:
// 1. isParentRowGetter trả về true
// 2. getChildItems trả về danh sách không rỗng
// 3. rowIdGetter trả về string unique
```

## 📞 Hỗ trợ

- Xem ví dụ trong `lib/widgets/table/example/`
- Đọc README chi tiết: `README_HIERARCHICAL_TABLE_USAGE.md`
- Kiểm tra lỗi linting và sửa theo gợi ý

---

**Migration thành công! 🎉**
