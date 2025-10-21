import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/widgets/expandable_riverpod_table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';

/// Demo đơn giản cho expandable table
class DemoExpandableTable extends ConsumerStatefulWidget {
  const DemoExpandableTable({super.key});

  @override
  ConsumerState<DemoExpandableTable> createState() => _DemoExpandableTableState();
}

class _DemoExpandableTableState extends ConsumerState<DemoExpandableTable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDemoData();
    });
  }

  void _loadDemoData() {
    final demoData = [
      {
        'id': '1',
        'name': 'Providenci Alten',
        'email': 'Alten@address.com',
        'status': 'Available',
        'department': 'Sales',
        'score': 15384,
      },
      {
        'id': '2',
        'name': 'John Doe',
        'email': 'john@example.com',
        'status': 'On project',
        'department': 'Marketing',
        'score': 32127,
      },
    ];

    ref.read(demoTableProvider.notifier).loadData(demoData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Expandable Table'),
        backgroundColor: AppColor.greenLight,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Click on arrow to expand/collapse rows',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ExpandableRiverpodTable<Map<String, dynamic>, Map<String, dynamic>>(
                tableProvider: demoTableProvider,
                childDataGetter: _getChildData,
                childColumns: _getChildColumns(),
                columns: _getParentColumns(),
                valueGetter: _getValue,
                cellBuilderByKey: _buildCellByKey,
                childTableTitle: 'Project Details',
                childTableBackgroundColor: Colors.blue.shade50,
                childTableMaxHeight: 150,
                showCheckboxColumn: false,
                showActionsColumn: false,
                enableRowSelection: true,
                enableRowHover: true,
                showAlternatingRowColors: true,
                alternateColor: Colors.grey.shade50,
                hoverColor: Colors.blue.shade50,
                selectedRowColor: Colors.blue.shade100,
                onRowTap: (employee) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: ${employee['name']}')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy dữ liệu con
  List<Map<String, dynamic>>? _getChildData(Map<String, dynamic> employee) {
    return _getProjectsForEmployee(employee['id']);
  }

  /// Tạo columns cho table cha
  List<TableColumnData> _getParentColumns() {
    return [
      TableColumnData.simple(
        name: 'Employee',
        key: 'name',
        width: 200,
      ),
      TableColumnData.simple(
        name: 'Status',
        key: 'status',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Department',
        key: 'department',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Score',
        key: 'score',
        width: 100,
      ),
    ];
  }

  /// Tạo columns cho table con
  List<TableColumnData> _getChildColumns() {
    return [
      TableColumnData.simple(
        name: 'Project',
        key: 'name',
        width: 200,
      ),
      TableColumnData.simple(
        name: 'Duration',
        key: 'duration',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Progress',
        key: 'progress',
        width: 100,
      ),
      TableColumnData.simple(
        name: 'Budget',
        key: 'budget',
        width: 120,
      ),
    ];
  }

  /// Lấy giá trị theo index
  dynamic _getValue(Map<String, dynamic> item, int columnIndex) {
    final keys = ['name', 'status', 'department', 'score'];
    if (columnIndex < keys.length) {
      return item[keys[columnIndex]];
    }
    return '';
  }

  /// Tạo cell theo key
  TableCellData? _buildCellByKey(Map<String, dynamic> item, String key) {
    switch (key) {
      case 'name':
        return TableCellData(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item['email'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      case 'status':
        return TableCellData(
          widget: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(item['status'] ?? ''),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(item['status'] ?? ''),
            ],
          ),
        );
      default:
        return null;
    }
  }

  /// Lấy màu theo status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on project':
        return Colors.blue;
      case 'available':
        return Colors.green;
      case 'no project':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Lấy dữ liệu project cho employee
  List<Map<String, dynamic>> _getProjectsForEmployee(String employeeId) {
    final allProjects = [
      {
        'id': '1',
        'name': 'Website Redesign',
        'duration': '3 months',
        'progress': 75,
        'budget': 50000,
      },
      {
        'id': '2',
        'name': 'Mobile App',
        'duration': '6 months',
        'progress': 45,
        'budget': 80000,
      },
      {
        'id': '3',
        'name': 'Database Migration',
        'duration': '2 months',
        'progress': 90,
        'budget': 30000,
      },
    ];
    
    // Trả về một số project ngẫu nhiên
    final random = employeeId.hashCode % allProjects.length;
    return allProjects.take(random + 1).toList();
  }
}

/// Provider cho demo table
final demoTableProvider = StateNotifierProvider.autoDispose<TableNotifier<Map<String, dynamic>>, GenericTableState<Map<String, dynamic>>>(
  (ref) => TableNotifier<Map<String, dynamic>>(),
);
