import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/table/table.dart';
import '../widgets/table/widgets/expandable_riverpod_table_complete.dart';
import '../widgets/table/providers/table_notifier.dart';

// Demo data models
class TestItem {
  final String id;
  final String name;
  final String status;
  final int quantity;
  final List<TestChildItem> children;

  TestItem({
    required this.id,
    required this.name,
    required this.status,
    required this.quantity,
    required this.children,
  });
}

class TestChildItem {
  final String id;
  final String detail;
  final String value;

  TestChildItem({
    required this.id,
    required this.detail,
    required this.value,
  });
}

// Test data
final testData = [
  TestItem(
    id: '1',
    name: 'Item 1',
    status: 'Active',
    quantity: 10,
    children: [
      TestChildItem(id: '1-1', detail: 'Child 1-1', value: 'Value A'),
      TestChildItem(id: '1-2', detail: 'Child 1-2', value: 'Value B'),
    ],
  ),
  TestItem(
    id: '2',
    name: 'Item 2',
    status: 'Inactive',
    quantity: 5,
    children: [
      TestChildItem(id: '2-1', detail: 'Child 2-1', value: 'Value C'),
    ],
  ),
  TestItem(
    id: '3',
    name: 'Item 3',
    status: 'Active',
    quantity: 15,
    children: [], // No children
  ),
];

// Table provider sử dụng TableNotifier có sẵn
final testTableProvider = StateNotifierProvider.autoDispose<TableNotifier<TestItem>, GenericTableState<TestItem>>(
  (ref) {
    final notifier = TableNotifier<TestItem>();
    // Initialize với data
    notifier.initialize(
      columnWidths: {
        'expand': 50,
        'name': 200,
        'status': 150,
        'quantity': 120,
      },
      valueGetter: (item, columnIndex) {
        switch (columnIndex) {
          case 0: return ''; // expand column
          case 1: return item.name;
          case 2: return item.status;
          case 3: return item.quantity;
          default: return '';
        }
      },
      itemsPerPage: 50,
    );
    // Load data
    notifier.loadData(testData);
    return notifier;
  },
);

class ExpandableTableTestPage extends ConsumerWidget {
  const ExpandableTableTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable Table Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpandableRiverpodTableComplete<TestItem, TestChildItem>(
          tableProvider: testTableProvider,
          columns: [
            TableColumnData(
              name: 'Tên',
              key: 'name',
              width: 200,
              isSortable: true,
            ),
            TableColumnData(
              name: 'Trạng thái',
              key: 'status',
              width: 150,
              isSortable: true,
            ),
            TableColumnData(
              name: 'Số lượng',
              key: 'quantity',
              width: 120,
              isSortable: true,
            ),
          ],
          childColumns: [
            TableColumnData(
              name: 'Chi tiết',
              key: 'detail',
              width: 200,
            ),
            TableColumnData(
              name: 'Giá trị',
              key: 'value',
              width: 150,
            ),
          ],
          childDataGetter: (item) => item.children,
          idGetter: (item) => item.id,
          cellBuilderByKey: (item, key) {
            switch (key) {
              case 'name':
                return TableCellData(
                  widget: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              case 'status':
                return TableCellData(
                  widget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == 'Active' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              case 'quantity':
                return TableCellData(
                  widget: Text(
                    item.quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              default:
                return null;
            }
          },
          childCellBuilder: (childItem, key) {
            switch (key) {
              case 'detail':
                return TableCellData(
                  widget: Text(
                    childItem.detail,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              case 'value':
                return TableCellData(
                  widget: Text(
                    childItem.value,
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                );
              default:
                return null;
            }
          },
          showCheckboxColumn: false,
          showActionsColumn: false,
          enableColumnResize: true,
          headerHeight: 50,
          rowHeight: 48,
          maxHeight: 600,
          childTableMaxHeight: 200,
          childTableTitle: 'Chi tiết',
          headerColor: Colors.blue.shade600,
          textHeaderColor: Colors.white,
          borderColor: Colors.grey.shade300,
          selectedRowColor: Colors.blue.shade50,
          childTableBackgroundColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}