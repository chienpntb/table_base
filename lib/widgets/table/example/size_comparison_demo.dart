import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Demo để so sánh kích thước hàng cha và hàng con
class SizeComparisonDemo extends ConsumerWidget {
  const SizeComparisonDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('So sánh kích thước hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Demo so sánh kích thước hàng cha và hàng con',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: HierarchicalTable<TestItem>(
                tableProvider: sizeComparisonProvider,
                hierarchicalColumns: [
                  HierarchicalTableColumnData.simple(name: 'ID', key: 'id', width: 80),
                  HierarchicalTableColumnData.simple(name: 'Tên', key: 'name', width: 200),
                  HierarchicalTableColumnData.simple(name: 'Mô tả', key: 'description', width: 300),
                  HierarchicalTableColumnData.simple(name: 'Giá trị', key: 'value', width: 150),
                ],
                valueGetter: (item, columnIndex) {
                  switch (columnIndex) {
                    case 0: return item.id;
                    case 1: return item.name;
                    case 2: return item.description;
                    case 3: return item.value;
                    default: return '';
                  }
                },
                idGetter: (item) => item.id,
                rowIdGetter: (item) => item.id,
                isParentRowGetter: (item) => item.children?.isNotEmpty == true,
                getChildItems: (item) => item.children ?? [],
                enableCollapseAnimation: true,
                childRowBackgroundColor: Colors.blue.withOpacity(0.1),
                showActionsColumn: false,
                showCheckboxColumn: false,
                rowHeight: 50,
                borderColor: Colors.black,
                borderWidth: 2,
                cellPadding: const EdgeInsets.all(8),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hướng dẫn kiểm tra:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Hàng cha có viền đen dày 2px'),
                  Text('2. Hàng con có nền xanh nhạt và viền đen dày 2px'),
                  Text('3. Kích thước hàng con phải bằng hàng cha'),
                  Text('4. Click vào mũi tên để thu gọn/mở rộng'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider cho demo so sánh kích thước
final sizeComparisonProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<TestItem>, GenericTableState<TestItem>>(
  (ref) => SizeComparisonNotifier(),
);

/// Notifier cho demo so sánh kích thước
class SizeComparisonNotifier extends TableNotifier<TestItem> {
  @override
  Future<List<TestItem>> generateData() async {
    final data = [
      TestItem(
        id: '1',
        name: 'Hàng cha 1',
        description: 'Đây là hàng cha có con',
        value: '100',
        children: [
          TestItem(
            id: '1.1',
            name: 'Hàng con 1.1',
            description: 'Đây là hàng con của hàng cha 1',
            value: '50',
          ),
          TestItem(
            id: '1.2',
            name: 'Hàng con 1.2',
            description: 'Đây là hàng con thứ hai của hàng cha 1',
            value: '50',
          ),
        ],
      ),
      TestItem(
        id: '2',
        name: 'Hàng cha 2',
        description: 'Đây là hàng cha thứ hai có con',
        value: '200',
        children: [
          TestItem(
            id: '2.1',
            name: 'Hàng con 2.1',
            description: 'Đây là hàng con của hàng cha 2',
            value: '100',
          ),
        ],
      ),
      TestItem(
        id: '3',
        name: 'Hàng thường',
        description: 'Đây là hàng thường không có con',
        value: '300',
      ),
    ];

    state = state.copyWith(
      allData: data,
      filteredData: data,
      currentPageData: data,
      isLoading: false,
    );
    
    return data;
  }
}

/// Model cho demo so sánh kích thước
class TestItem {
  final String id;
  final String name;
  final String description;
  final String value;
  final List<TestItem>? children;

  TestItem({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    this.children,
  });
}
