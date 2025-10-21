import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Model demo để test kích thước hàng con bằng hàng cha
class SizeTestItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int quantity;
  final bool isParent;
  final List<SizeTestItem>? children;

  SizeTestItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.quantity,
    this.isParent = false,
    this.children,
  });
}

/// Provider test kích thước
final sizeTestProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<SizeTestItem>, GenericTableState<SizeTestItem>>((ref) {
  return SizeTestNotifier();
});

class SizeTestNotifier extends TableNotifier<SizeTestItem> {
  @override
  Future<List<SizeTestItem>> generateData() async {
    return [
      SizeTestItem(
        id: 'parent1',
        name: 'Nhóm Điện Tử',
        category: 'Electronics',
        description: 'Các sản phẩm điện tử cao cấp',
        price: 0,
        quantity: 0,
        isParent: true,
        children: [
          SizeTestItem(
            id: 'child1',
            name: 'iPhone 15 Pro Max',
            category: 'Phone',
            description: 'Điện thoại thông minh cao cấp nhất',
            price: 35000000,
            quantity: 25,
          ),
          SizeTestItem(
            id: 'child2',
            name: 'Samsung Galaxy S24 Ultra',
            category: 'Phone',
            description: 'Điện thoại Android flagship',
            price: 28000000,
            quantity: 30,
          ),
          SizeTestItem(
            id: 'child3',
            name: 'MacBook Pro M3 Max',
            category: 'Laptop',
            description: 'Laptop chuyên nghiệp cho developer',
            price: 65000000,
            quantity: 15,
          ),
        ],
      ),
      SizeTestItem(
        id: 'parent2',
        name: 'Nhóm Thời Trang',
        category: 'Fashion',
        description: 'Quần áo và phụ kiện thời trang',
        price: 0,
        quantity: 0,
        isParent: true,
        children: [
          SizeTestItem(
            id: 'child4',
            name: 'Áo sơ mi công sở',
            category: 'Shirt',
            description: 'Áo sơ mi chất liệu cotton cao cấp',
            price: 500000,
            quantity: 100,
          ),
          SizeTestItem(
            id: 'child5',
            name: 'Quần âu nam',
            category: 'Pants',
            description: 'Quần âu thiết kế hiện đại',
            price: 800000,
            quantity: 80,
          ),
        ],
      ),
      SizeTestItem(
        id: 'parent3',
        name: 'Nhóm Gia Dụng',
        category: 'Home',
        description: 'Đồ dùng gia đình và nội thất',
        price: 0,
        quantity: 0,
        isParent: true,
        children: [
          SizeTestItem(
            id: 'child6',
            name: 'Tủ lạnh Samsung',
            category: 'Appliance',
            description: 'Tủ lạnh inverter tiết kiệm điện',
            price: 12000000,
            quantity: 20,
          ),
          SizeTestItem(
            id: 'child7',
            name: 'Máy giặt LG',
            category: 'Appliance',
            description: 'Máy giặt lồng ngang công nghệ AI',
            price: 15000000,
            quantity: 18,
          ),
          SizeTestItem(
            id: 'child8',
            name: 'Bàn làm việc gỗ',
            category: 'Furniture',
            description: 'Bàn làm việc gỗ tự nhiên cao cấp',
            price: 3500000,
            quantity: 35,
          ),
        ],
      ),
    ];
  }
}

/// Demo test kích thước hàng con bằng hàng cha
class SizeTestDemo extends ConsumerWidget {
  const SizeTestDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Kích Thước Hàng Con = Hàng Cha'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hướng dẫn
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Test Kích Thước Hàng Con = Hàng Cha',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Nhấn mũi tên để mở/đóng các nhóm con\n'
                    '• Quan sát: Tổng độ rộng hàng con = Tổng độ rộng hàng cha\n'
                    '• Hàng cha: màu trắng, hàng con: màu xám nhạt\n'
                    '• Tất cả các cột đều có kích thước nhất quán',
                    style: TextStyle(color: Colors.indigo),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Hierarchical Table với nhiều cột để test kích thước
            Expanded(
              child: HierarchicalTable<SizeTestItem>(
                tableProvider: sizeTestProvider,
                hierarchicalColumns: [
                  HierarchicalTableColumnData.simple(
                    name: 'Tên sản phẩm',
                    key: 'name',
                    width: 200,
                    flex: 1.5,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Danh mục',
                    key: 'category',
                    width: 120,
                    flex: 1,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Mô tả',
                    key: 'description',
                    width: 250,
                    flex: 2,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Giá',
                    key: 'price',
                    width: 120,
                    flex: 1,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Số lượng',
                    key: 'quantity',
                    width: 100,
                    flex: 0.8,
                  ),
                ],
                valueGetter: (item, columnIndex) {
                  switch (columnIndex) {
                    case 0: return item.name;
                    case 1: return item.category;
                    case 2: return item.description;
                    case 3: return item.price;
                    case 4: return item.quantity;
                    default: return '';
                  }
                },
                cellBuilderByKey: (item, key) {
                  switch (key) {
                    case 'name':
                      if (item.isParent) {
                        return TableCellData(
                          widget: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      return null;
                    case 'price':
                      if (item.price == 0) {
                        return TableCellData(
                          widget: Text(
                            'Nhóm',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                      return TableCellData(
                        widget: Text(
                          '${item.price.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          )} VNĐ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    case 'quantity':
                      if (item.quantity == 0) {
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
                            color: item.quantity > 50 ? Colors.green.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.quantity > 50 ? Colors.green.shade800 : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      );
                    default:
                      return null;
                  }
                },
                idGetter: (item) => item.id,
                rowIdGetter: (item) => item.id,
                isParentRowGetter: (item) => item.isParent,
                getChildItems: (item) => item.children ?? [],
                showCheckboxColumn: true,
                showActionsColumn: false,
                enableRowSelection: true,
                enableRowHover: true,
                showAlternatingRowColors: true,
                childRowBackgroundColor: Colors.indigo.shade50,
                childRowPadding: EdgeInsets.only(left: 0.0,),
                enableCollapseAnimation: true,
                onRowTap: (item) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chọn: ${item.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            
            // Thông tin test
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
                '✅ Test: Mở các nhóm và quan sát tổng độ rộng hàng con = hàng cha!',
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
