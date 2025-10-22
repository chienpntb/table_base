import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/widgets/expandable_riverpod_table_v2.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';

/// Simple test cho expandable table
class SimpleExpandableTest extends ConsumerStatefulWidget {
  const SimpleExpandableTest({super.key});

  @override
  ConsumerState<SimpleExpandableTest> createState() => _SimpleExpandableTestState();
}

class _SimpleExpandableTestState extends ConsumerState<SimpleExpandableTest> {
  /// Set các item đã được chọn
  final Set<String> _selectedItems = <String>{};
  
  @override
  void initState() {
    super.initState();
    // Thử load data ngay lập tức
    _loadTestData();
    
    // Và cũng load sau khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('PostFrameCallback triggered');
      _loadTestData();
    });
  }

  void _loadTestData() {
    final testData = [
      {
        'id': '1',
        'name': 'Test Employee 1',
        'email': 'test1@example.com',
        'status': 'Available',
        'department': 'Sales',
        'score': 1000,
      },
      {
        'id': '2',
        'name': 'Test Employee 2',
        'email': 'test2@example.com',
        'status': 'On project',
        'department': 'Marketing',
        'score': 2000,
      },
    ];

    print('Loading test data: ${testData.length} items');
    
    // Debug: Kiểm tra provider state trước khi load
    final currentState = ref.read(testTableProvider);
    print('Current state before load: isLoading=${currentState.isLoading}, dataCount=${currentState.currentPageData.length}');
    
    // Load data
    ref.read(testTableProvider.notifier).loadData(testData);
    
    // Debug: Kiểm tra provider state sau khi load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newState = ref.read(testTableProvider);
      print('State after load: isLoading=${newState.isLoading}, dataCount=${newState.currentPageData.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final tableState = ref.watch(testTableProvider);
    print('Table state: isLoading=${tableState.isLoading}, dataCount=${tableState.currentPageData.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Expandable Test'),
        backgroundColor: AppColor.greenLight,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data count: ${tableState.currentPageData.length}'),
                    Text('Selected: ${_selectedItems.length} items'),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Manual reload triggered');
                    _loadTestData();
                  },
                  child: const Text('Reload Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ExpandableRiverpodTable<Map<String, dynamic>, Map<String, dynamic>>(
                tableProvider: testTableProvider,
                childDataGetter: _getChildData,
                childColumns: _getChildColumns(),
                columns: _getParentColumns(),
                valueGetter: _getValue,
                cellBuilderByKey: _buildCellByKey,
                childTableTitle: 'Project Details',
                childTableBackgroundColor: Colors.blue.shade50,
                childTableMaxHeight: 150,
                showCheckboxColumn: true,
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
                idGetter: (employee) => employee['id'],
                onCheckboxChanged: (employee, isSelected) {
                  _toggleSelection(employee['id'] ?? '');
                },
                isItemSelected: (employee) {
                  return _isSelected(employee['id'] ?? '');
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
    final childData = _getProjectsForEmployee(employee['id']);
    print('_getChildData for ${employee['name']}: ${childData.length} items');
    for (final item in childData) {
      print('  - ${item['name']}: ${item['duration']} (${item['progress']}%)');
    }
    return childData;
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
      },
      {
        'id': '2',
        'name': 'Mobile App',
        'duration': '6 months',
        'progress': 45,
      },
      {
        'id': '3',
        'name': 'Database Migration',
        'duration': '2 months',
        'progress': 90,
      },
    ];
    
    // Trả về tất cả projects để test
    print('Child data for employee $employeeId: ${allProjects.length} projects');
    for (final project in allProjects) {
      print('  - ${project['name']}: ${project['duration']} (${project['progress']}%)');
    }
    return allProjects;
  }

  /// Toggle selection của một item
  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
    print('Selected items: $_selectedItems');
  }

  /// Kiểm tra item có được chọn không
  bool _isSelected(String itemId) {
    return _selectedItems.contains(itemId);
  }
}

/// Provider cho test table
final testTableProvider = StateNotifierProvider.autoDispose<TableNotifier<Map<String, dynamic>>, GenericTableState<Map<String, dynamic>>>(
  (ref) => TableNotifier<Map<String, dynamic>>(),
);
