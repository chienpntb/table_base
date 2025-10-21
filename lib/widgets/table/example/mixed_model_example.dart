/// Model cho Order (hàng cha)
class Order {
  final String id;
  final String customerName;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
  });
}

/// Model cho OrderItem (hàng con)
class OrderItem {
  final String id;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String category;

  OrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.category,
  });
}

/// Union type để hiển thị cả Order và OrderItem
abstract class MixedTableItem {
  String get id;
  String get name;
  String get date;
  String get amount;
  String get status;
  bool get isOrder; // true = Order, false = OrderItem
}

/// Extension để Order implement MixedTableItem
extension OrderAsMixedTableItem on Order {
  MixedTableItem get asMixedTableItem => _OrderMixedTableItem(this);
}

/// Extension để OrderItem implement MixedTableItem
extension OrderItemAsMixedTableItem on OrderItem {
  MixedTableItem get asMixedTableItem => _OrderItemMixedTableItem(this);
}

/// Wrapper cho Order
class _OrderMixedTableItem implements MixedTableItem {
  final Order _order;
  
  _OrderMixedTableItem(this._order);
  
  @override
  String get id => _order.id;
  
  @override
  String get name => _order.customerName;
  
  @override
  String get date => _order.orderDate.toString().split(' ')[0]; // Chỉ lấy ngày
  
  @override
  String get amount => _order.totalAmount.toStringAsFixed(0);
  
  @override
  String get status => _order.status;
  
  @override
  bool get isOrder => true;
}

/// Wrapper cho OrderItem
class _OrderItemMixedTableItem implements MixedTableItem {
  final OrderItem _orderItem;
  
  _OrderItemMixedTableItem(this._orderItem);
  
  @override
  String get id => _orderItem.id;
  
  @override
  String get name => _orderItem.productName;
  
  @override
  String get date => _orderItem.category; // Sử dụng category thay vì date
  
  @override
  String get amount => _orderItem.subtotal.toStringAsFixed(0);
  
  @override
  String get status => '${_orderItem.quantity}x'; // Hiển thị quantity
  
  @override
  bool get isOrder => false;
}

/// Dữ liệu mẫu
class MixedSampleData {
  static List<Order> getOrders() {
    return [
      Order(
        id: 'ORD001',
        customerName: 'Nguyễn Văn A',
        orderDate: DateTime(2024, 1, 15),
        totalAmount: 1500000,
        status: 'Đã giao',
        items: [
          OrderItem(
            id: 'ITEM001',
            productName: 'Laptop Dell XPS 13',
            quantity: 1,
            unitPrice: 25000000,
            subtotal: 25000000,
            category: 'Electronics',
          ),
          OrderItem(
            id: 'ITEM002',
            productName: 'Chuột không dây',
            quantity: 2,
            unitPrice: 500000,
            subtotal: 1000000,
            category: 'Accessories',
          ),
        ],
      ),
      Order(
        id: 'ORD002',
        customerName: 'Trần Thị B',
        orderDate: DateTime(2024, 1, 16),
        totalAmount: 800000,
        status: 'Đang xử lý',
        items: [
          OrderItem(
            id: 'ITEM003',
            productName: 'Áo thun nam',
            quantity: 3,
            unitPrice: 200000,
            subtotal: 600000,
            category: 'Clothing',
          ),
          OrderItem(
            id: 'ITEM004',
            productName: 'Quần jean',
            quantity: 1,
            unitPrice: 800000,
            subtotal: 800000,
            category: 'Clothing',
          ),
        ],
      ),
      Order(
        id: 'ORD003',
        customerName: 'Lê Văn C',
        orderDate: DateTime(2024, 1, 17),
        totalAmount: 2000000,
        status: 'Đã hủy',
        items: [],
      ),
    ];
  }
}
