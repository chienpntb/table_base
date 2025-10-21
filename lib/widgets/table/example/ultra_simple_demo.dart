import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Model dữ liệu cực kỳ đơn giản
class SimpleItem {
  final String id;
  final String name;
  final String value;
  final bool isParent;
  final List<SimpleItem>? children;

  SimpleItem({
    required this.id,
    required this.name,
    required this.value,
    this.isParent = false,
    this.children,
  });
}

/// Provider đơn giản
final simpleProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<SimpleItem>, GenericTableState<SimpleItem>>((ref) {
  return SimpleNotifier();
});

class SimpleNotifier extends TableNotifier<SimpleItem> {
  @override
  Future<List<SimpleItem>> generateData() async {
    return [
      SimpleItem(
        id: 'parent1',
        name: 'Nhóm A',
        value: 'Group A',
        isParent: true,
        children: [
          SimpleItem(id: 'child1', name: 'Item A1', value: 'Value A1'),
          SimpleItem(id: 'child2', name: 'Item A2', value: 'Value A2'),
          SimpleItem(id: 'child3', name: 'Item A3', value: 'Value A3'),
        ],
      ),
      SimpleItem(
        id: 'parent2',
        name: 'Nhóm B',
        value: 'Group B',
        isParent: true,
        children: [
          SimpleItem(id: 'child4', name: 'Item B1', value: 'Value B1'),
          SimpleItem(id: 'child5', name: 'Item B2', value: 'Value B2'),
        ],
      ),
      SimpleItem(
        id: 'parent3',
        name: 'Nhóm C',
        value: 'Group C',
        isParent: true,
        children: [
          SimpleItem(id: 'child6', name: 'Item C1', value: 'Value C1'),
          SimpleItem(id: 'child7', name: 'Item C2', value: 'Value C2'),
          SimpleItem(id: 'child8', name: 'Item C3', value: 'Value C3'),
          SimpleItem(id: 'child9', name: 'Item C4', value: 'Value C4'),
        ],
      ),
    ];
  }
}

/// Demo cực kỳ đơn giản
class UltraSimpleDemo extends ConsumerWidget {
  const UltraSimpleDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Cực Đơn Giản'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hướng dẫn ngắn gọn
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Text(
                '🎯 Nhấn vào mũi tên để mở/đóng các nhóm con!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            
            // Hierarchical Table đơn giản
            Expanded(
              child: HierarchicalTable<SimpleItem>(
                tableProvider: simpleProvider,
                hierarchicalColumns: [
                  HierarchicalTableColumnData.simple(
                    name: 'Tên',
                    key: 'name',
                    width: 200,
                    flex: 1,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Giá trị',
                    key: 'value',
                    width: 200,
                    flex: 1,
                  ),
                ],
                valueGetter: (item, columnIndex) {
                  return columnIndex == 0 ? item.name : item.value;
                },
                cellBuilderByKey: (item, key) {
                  if (key == 'name' && item.isParent) {
                    return TableCellData(
                      widget: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                idGetter: (item) => item.id,
                rowIdGetter: (item) => item.id,
                isParentRowGetter: (item) => item.isParent,
                getChildItems: (item) => item.children ?? [],
                showCheckboxColumn: false,
                showActionsColumn: false,
                enableRowSelection: false,
                enableRowHover: true,
                showAlternatingRowColors: true,
                childRowBackgroundColor: Colors.purple.shade50,
                childRowPadding: const EdgeInsets.only(left: 20.0),
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
          ],
        ),
      ),
    );
  }
}
