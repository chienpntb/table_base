import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';

// Model ví dụ cho dữ liệu
class Employee {
  final String id;
  final String name;
  final String department;
  final double salary;
  final List<Task>? tasks; // Children data

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.salary,
    this.tasks,
  });
}

class Task {
  final String id;
  final String title;
  final String status;
  final DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.dueDate,
  });
}

// Provider cho expandable table
final expandableTableProvider = StateNotifierProvider.autoDispose<
    ExpandableTableNotifier<dynamic>, ExpandableTableState<dynamic>>(
  (ref) => ExpandableTableNotifier<dynamic>(
    idGetter: (item) {
      if (item is Employee) return item.id;
      if (item is Task) return item.id;
      return '';
    },
  ),
);

class ExpandableTableDemo extends ConsumerStatefulWidget {
  const ExpandableTableDemo({super.key});

  @override
  ConsumerState<ExpandableTableDemo> createState() => _ExpandableTableDemoState();
}

class _ExpandableTableDemoState extends ConsumerState<ExpandableTableDemo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSampleData();
    });
  }

  void _loadSampleData() {
    // Tạo sample data
    final employees = [
      Employee(
        id: '1',
        name: 'Nguyễn Văn A',
        department: 'IT',
        salary: 20000000,
        tasks: [
          Task(
            id: 't1',
            title: 'Phát triển tính năng đăng nhập',
            status: 'Đang thực hiện',
            dueDate: DateTime.now().add(const Duration(days: 7)),
          ),
          Task(
            id: 't2',
            title: 'Viết tài liệu API',
            status: 'Hoàn thành',
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
      Employee(
        id: '2',
        name: 'Trần Thị B',
        department: 'Marketing',
        salary: 15000000,
        tasks: [
          Task(
            id: 't3',
            title: 'Lên kế hoạch campaign Q4',
            status: 'Mới tạo',
            dueDate: DateTime.now().add(const Duration(days: 14)),
          ),
        ],
      ),
      Employee(
        id: '3',
        name: 'Lê Văn C',
        department: 'Sales',
        salary: 18000000,
        tasks: [
          Task(
            id: 't4',
            title: 'Gặp khách hàng tiềm năng',
            status: 'Đang thực hiện',
            dueDate: DateTime.now().add(const Duration(days: 3)),
          ),
          Task(
            id: 't5',
            title: 'Cập nhật CRM',
            status: 'Hoàn thành',
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];

    // Chuyển đổi thành ExpandableRowData với dynamic type
    final expandableData = employees.map((employee) => 
      ExpandableRowData<dynamic>(
        parentData: employee,
        id: employee.id,
        // Không dùng children property, dùng childrenGetter trong widget
      )
    ).toList();
    
    ref.read(expandableTableProvider.notifier).initializeData(expandableData);
  }

  // Value getter để lấy giá trị từ item
  dynamic valueGetter(dynamic item, int columnIndex) {
    if (item is Employee) {
      switch (columnIndex) {
        case 0: return item.name;
        case 1: return item.department;
        case 2: return '${item.salary.toStringAsFixed(0)} VNĐ';
        default: return '';
      }
    } else if (item is Task) {
      switch (columnIndex) {
        case 0: return item.title;
        case 1: return item.status;
        case 2: return item.dueDate.toString().substring(0, 10);
        default: return '';
      }
    }
    return '';
  }

  Widget buildCell(BuildContext context, dynamic item, int columnIndex) {
    final value = valueGetter(item, columnIndex);
    
    if (item is Task && columnIndex == 1) {
      // Status chip cho Task
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(item.status),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    
    return Text(value.toString());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hoàn thành':
        return Colors.green;
      case 'Đang thực hiện':
        return Colors.orange;
      case 'Mới tạo':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable Table Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.expand_more),
            onPressed: () => ref.read(expandableTableProvider.notifier).expandAll(),
            tooltip: 'Expand All',
          ),
          IconButton(
            icon: const Icon(Icons.expand_less),
            onPressed: () => ref.read(expandableTableProvider.notifier).collapseAll(),
            tooltip: 'Collapse All',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer(
          builder: (context, ref, child) {
            final tableState = ref.watch(expandableTableProvider);
            
            if (tableState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (tableState.error != null) {
              return Center(
                child: Text(
                  'Error: ${tableState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            
            return ExpandableTable<dynamic>(
              tableProvider: expandableTableProvider,
              valueGetter: valueGetter,
              childrenGetter: (item) {
                if (item is Employee) {
                  return item.tasks?.cast<dynamic>();
                }
                return null;
              },
              columns: [
                TableColumnData(
                  key: 'name',
                  name: 'Tên / Tiêu đề',
                  width: 200,
                ),
                TableColumnData(
                  key: 'department',
                  name: 'Phòng ban / Trạng thái',
                  width: 150,
                ),
                TableColumnData(
                  key: 'salary',
                  name: 'Lương / Ngày hết hạn',
                  width: 150,
                ),
              ],
              cellBuilderByKey: (item, key) {
                switch (key) {
                  case 'name':
                    return TableCellData(widget: buildCell(context, item, 0));
                  case 'department':
                    return TableCellData(widget: buildCell(context, item, 1));
                  case 'salary':
                    return TableCellData(widget: buildCell(context, item, 2));
                  default:
                    return null;
                }
              },
            );
          },
        ),
      ),
    );
  }
}