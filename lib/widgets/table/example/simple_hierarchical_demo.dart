import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Model dữ liệu đơn giản cho demo
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final bool isParent;
  final List<Product>? subProducts;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.isParent = false,
    this.subProducts,
  });
}

/// Provider tạo dữ liệu demo
final demoTableProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<Product>, GenericTableState<Product>>((ref) {
  return DemoTableNotifier();
});

class DemoTableNotifier extends TableNotifier<Product> {
  @override
  Future<List<Product>> generateData() async {
    return [
      Product(
        id: 'cat_1',
        name: 'Điện Thoại',
        category: 'Electronics',
        price: 0,
        stock: 0,
        isParent: true,
        subProducts: [
          Product(id: 'prod_1', name: 'iPhone 15', category: 'Phone', price: 25000000, stock: 50),
          Product(id: 'prod_2', name: 'Samsung Galaxy S24', category: 'Phone', price: 22000000, stock: 30),
          Product(id: 'prod_3', name: 'Xiaomi 14', category: 'Phone', price: 15000000, stock: 25),
        ],
      ),
      Product(
        id: 'cat_2',
        name: 'Laptop',
        category: 'Electronics',
        price: 0,
        stock: 0,
        isParent: true,
        subProducts: [
          Product(id: 'prod_4', name: 'MacBook Pro M3', category: 'Laptop', price: 45000000, stock: 15),
          Product(id: 'prod_5', name: 'Dell XPS 13', category: 'Laptop', price: 35000000, stock: 20),
          Product(id: 'prod_6', name: 'HP Pavilion', category: 'Laptop', price: 18000000, stock: 35),
        ],
      ),
      Product(
        id: 'cat_3',
        name: 'Phụ Kiện',
        category: 'Accessories',
        price: 0,
        stock: 0,
        isParent: true,
        subProducts: [
          Product(id: 'prod_7', name: 'AirPods Pro', category: 'Audio', price: 5000000, stock: 100),
          Product(id: 'prod_8', name: 'Magic Mouse', category: 'Mouse', price: 2500000, stock: 80),
          Product(id: 'prod_9', name: 'USB-C Cable', category: 'Cable', price: 500000, stock: 200),
        ],
      ),
    ];
  }
}

/// Widget demo đơn giản
class SimpleHierarchicalDemo extends ConsumerWidget {
  const SimpleHierarchicalDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Hierarchical Table'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hướng dẫn
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Demo Hierarchical Table',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Nhấn vào mũi tên để mở/đóng sản phẩm con\n'
                    '• Hàng cha (danh mục) có màu trắng\n'
                    '• Hàng con (sản phẩm) có màu xám nhạt\n'
                    '• Có thể chọn nhiều sản phẩm',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Hierarchical Table
            Expanded(
              child: HierarchicalTable<Product>(
                tableProvider: demoTableProvider,
                hierarchicalColumns: [
                  HierarchicalTableColumnData.simple(
                    name: 'Tên sản phẩm',
                    key: 'name',
                    width: 200,
                    flex: 1,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Danh mục',
                    key: 'category',
                    width: 120,
                    flex: 0.6,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Giá',
                    key: 'price',
                    width: 120,
                    flex: 0.6,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Tồn kho',
                    key: 'stock',
                    width: 100,
                    flex: 0.5,
                  ),
                ],
                valueGetter: (product, columnIndex) {
                  switch (columnIndex) {
                    case 0: return product.name;
                    case 1: return product.category;
                    case 2: return product.price;
                    case 3: return product.stock;
                    default: return '';
                  }
                },
                cellBuilderByKey: (product, key) {
                  switch (key) {
                    case 'price':
                      if (product.price == 0) {
                        return TableCellData(
                          widget: Text(
                            'Danh mục',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      }
                      return TableCellData(
                        widget: Text(
                          '${product.price.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          )} VNĐ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    case 'stock':
                      if (product.stock == 0) {
                        return TableCellData(
                          widget: Text(
                            '-',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return TableCellData(
                        widget: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.stock > 50 ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: product.stock > 50 ? Colors.green.shade800 : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      );
                    default:
                      return null;
                  }
                },
                idGetter: (product) => product.id,
                rowIdGetter: (product) => product.id,
                isParentRowGetter: (product) => product.isParent,
                getChildItems: (product) => product.subProducts ?? [],
                showCheckboxColumn: true,
                showActionsColumn: false,
                enableRowSelection: true,
                enableRowHover: true,
                showAlternatingRowColors: true,
                childRowBackgroundColor: Colors.grey.shade50,
                childRowPadding: EdgeInsets.only(left: 24.0),
                enableCollapseAnimation: true,
                onRowTap: (product) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chọn: ${product.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            
            // Thông tin thêm
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                '💡 Tip: Thử nhấn vào các mũi tên để mở/đóng danh mục sản phẩm!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
