import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/widgets/expandable_riverpod_table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';

/// Example đơn giản sử dụng ExpandableRiverpodTable
class SimpleExpandableExample extends ConsumerStatefulWidget {
  const SimpleExpandableExample({super.key});

  @override
  ConsumerState<SimpleExpandableExample> createState() => _SimpleExpandableExampleState();
}

class _SimpleExpandableExampleState extends ConsumerState<SimpleExpandableExample> {
  @override
  void initState() {
    super.initState();
    // Load dữ liệu mẫu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSampleData();
    });
  }

  void _loadSampleData() {
    final sampleData = [
      {
        'id': '1',
        'name': 'Providenci Alten',
        'email': 'Alten@address.com',
        'registered': 'February 14, 2020',
        'rankings': 3.5,
        'status': 'Available',
        'transaction': 'ARB-8947',
        'division': 'Sales',
        'location': 'Chicago, IL',
        'progress': 98.0,
        'score': 15384,
      },
      {
        'id': '2',
        'name': 'John Doe',
        'email': 'john@example.com',
        'registered': 'March 15, 2020',
        'rankings': 4.0,
        'status': 'On project',
        'transaction': 'ARB-2560',
        'division': 'Marketing',
        'location': 'New York, NY',
        'progress': 100.0,
        'score': 32127,
      },
      {
        'id': '3',
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'registered': 'April 20, 2020',
        'rankings': 3.5,
        'status': 'No project',
        'transaction': 'ARB-1234',
        'division': 'Design',
        'location': 'Los Angeles, CA',
        'progress': 76.0,
        'score': 25000,
      },
    ];

    ref.read(expandableTableProvider.notifier).loadData(sampleData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable Table Demo'),
        backgroundColor: AppColor.greenLight,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Employee Table with Dessert Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ExpandableRiverpodTable<Map<String, dynamic>, Map<String, dynamic>>(
                tableProvider: expandableTableProvider,
                childDataGetter: _getChildData,
                childColumns: _getChildColumns(),
                columns: _getParentColumns(),
                valueGetter: _getValue,
                cellBuilderByKey: _buildCellByKey,
                childTableTitle: 'Dessert Details',
                childTableBackgroundColor: Colors.yellow.shade50,
                childTableMaxHeight: 200,
                showCheckboxColumn: true,
                showActionsColumn: true,
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
                onEdit: (employee) {
                  _showEditDialog(context, employee);
                },
                onDelete: (employee) {
                  _showDeleteDialog(context, employee);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy dữ liệu con từ dữ liệu cha
  List<Map<String, dynamic>>? _getChildData(Map<String, dynamic> employee) {
    // Simulate data - trả về dessert data cho employee
    return _getDessertsForEmployee(employee['id']);
  }

  /// Tạo columns cho table cha
  List<TableColumnData> _getParentColumns() {
    return [
      TableColumnData.simple(
        name: 'Employee',
        key: 'name',
        width: 200,
        flex: 1,
      ),
      TableColumnData.simple(
        name: 'Registered',
        key: 'registered',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Rankings',
        key: 'rankings',
        width: 100,
      ),
      TableColumnData.simple(
        name: 'Status',
        key: 'status',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Transaction',
        key: 'transaction',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Division',
        key: 'division',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Location',
        key: 'location',
        width: 150,
      ),
      TableColumnData.simple(
        name: 'Progress',
        key: 'progress',
        width: 100,
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
        name: 'Dessert',
        key: 'name',
        width: 200,
      ),
      TableColumnData.simple(
        name: 'Commits',
        key: 'commits',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Tasks',
        key: 'tasks',
        width: 100,
      ),
      TableColumnData.simple(
        name: 'Projects',
        key: 'projects',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Hours',
        key: 'hours',
        width: 120,
      ),
      TableColumnData.simple(
        name: 'Wins',
        key: 'wins',
        width: 100,
      ),
      TableColumnData.simple(
        name: 'Score',
        key: 'score',
        width: 100,
      ),
    ];
  }

  /// Lấy giá trị từ item theo column index
  dynamic _getValue(Map<String, dynamic> item, int columnIndex) {
    final keys = ['name', 'registered', 'rankings', 'status', 'transaction', 'division', 'location', 'progress', 'score'];
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
      case 'rankings':
        final rankings = (item['rankings'] as num?)?.toDouble() ?? 0.0;
        return TableCellData(
          widget: Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rankings ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                );
              }),
              const SizedBox(width: 4),
              Text('$rankings'),
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
      case 'progress':
        final progress = (item['progress'] as num?)?.toDouble() ?? 0.0;
        return TableCellData(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${progress}%'),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress),
                ),
              ),
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

  /// Lấy màu theo progress
  Color _getProgressColor(double progress) {
    if (progress >= 90) return Colors.green;
    if (progress >= 70) return Colors.orange;
    return Colors.red;
  }

  /// Lấy dữ liệu dessert cho employee
  List<Map<String, dynamic>> _getDessertsForEmployee(String employeeId) {
    // Simulate data - trả về dessert data khác nhau cho mỗi employee
    final allDesserts = [
      {
        'id': '1',
        'name': 'Bitka Coctail',
        'commits': 112.1,
        'tasks': 24,
        'projects': 24,
        'hours': 24000,
        'wins': 9.0,
        'score': 34.7,
      },
      {
        'id': '2',
        'name': 'Girl Scout Cookies',
        'commits': 2.1,
        'tasks': 37,
        'projects': 9,
        'hours': 8000,
        'wins': 112.1,
        'score': 2.1,
      },
      {
        'id': '3',
        'name': 'Nougat',
        'commits': 34.7,
        'tasks': 9,
        'projects': 49,
        'hours': 6000,
        'wins': 34.7,
        'score': 112.1,
      },
      {
        'id': '4',
        'name': 'Marshmallow',
        'commits': 45.2,
        'tasks': 15,
        'projects': 12,
        'hours': 12000,
        'wins': 25.3,
        'score': 67.8,
      },
      {
        'id': '5',
        'name': 'Lollipop',
        'commits': 78.9,
        'tasks': 8,
        'projects': 33,
        'hours': 15000,
        'wins': 45.6,
        'score': 89.2,
      },
    ];
    
    // Trả về một số dessert ngẫu nhiên cho mỗi employee
    final random = employeeId.hashCode % allDesserts.length;
    return allDesserts.take(random + 1).toList();
  }

  /// Hiển thị dialog edit
  void _showEditDialog(BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Text('Edit ${employee['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edited ${employee['name']}')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog delete
  void _showDeleteDialog(BuildContext context, Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Delete ${employee['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${employee['name']}')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Provider cho expandable table
final expandableTableProvider = StateNotifierProvider.autoDispose<TableNotifier<Map<String, dynamic>>, GenericTableState<Map<String, dynamic>>>(
  (ref) => TableNotifier<Map<String, dynamic>>(),
);
