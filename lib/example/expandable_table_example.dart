import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';
import 'package:table_base/widgets/table/widgets/expandable_riverpod_table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Model cho Employee (dữ liệu cha)
class Employee {
  final String id;
  final String name;
  final String email;
  final String registered;
  final double rankings;
  final String status;
  final String transaction;
  final String division;
  final String location;
  final double progress;
  final int score;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.registered,
    required this.rankings,
    required this.status,
    required this.transaction,
    required this.division,
    required this.location,
    required this.progress,
    required this.score,
  });
}

/// Model cho Dessert (dữ liệu con)
class Dessert {
  final String id;
  final String name;
  final double commits;
  final int tasks;
  final int projects;
  final int hours;
  final double wins;
  final double score;

  const Dessert({
    required this.id,
    required this.name,
    required this.commits,
    required this.tasks,
    required this.projects,
    required this.hours,
    required this.wins,
    required this.score,
  });
}

/// Provider cho expandable table
final expandableTableProvider = StateNotifierProvider.autoDispose<TableNotifier<Employee>, GenericTableState<Employee>>(
  (ref) => TableNotifier<Employee>(),
);

/// Example sử dụng ExpandableRiverpodTable
class ExpandableTableExample extends ConsumerWidget {
  const ExpandableTableExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(expandableTableProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable Table Example'),
        backgroundColor: AppColor.greenLight,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('Reload button pressed in ExpandableTableExample');
              // Force reload data
              final sampleEmployees = [
                const Employee(
                  id: '1',
                  name: 'Providenci Alten',
                  email: 'Alten@address.com',
                  registered: 'February 14, 2020',
                  rankings: 3.5,
                  status: 'Available',
                  transaction: 'ARB-8947',
                  division: 'Sales',
                  location: 'Chicago, IL',
                  progress: 98.0,
                  score: 15384,
                ),
                const Employee(
                  id: '2',
                  name: 'John Doe',
                  email: 'john@example.com',
                  registered: 'March 15, 2020',
                  rankings: 4.0,
                  status: 'On project',
                  transaction: 'ARB-2560',
                  division: 'Marketing',
                  location: 'New York, NY',
                  progress: 100.0,
                  score: 32127,
                ),
                const Employee(
                  id: '3',
                  name: 'Jane Smith',
                  email: 'jane@example.com',
                  registered: 'April 20, 2020',
                  rankings: 3.5,
                  status: 'No project',
                  transaction: 'ARB-1234',
                  division: 'Design',
                  location: 'Los Angeles, CA',
                  progress: 76.0,
                  score: 25000,
                ),
                const Employee(
                  id: '4',
                  name: 'Bob Johnson',
                  email: 'bob@example.com',
                  registered: 'May 10, 2020',
                  rankings: 5.0,
                  status: 'Offline',
                  transaction: 'ARB-5678',
                  division: 'Engineering',
                  location: 'Seattle, WA',
                  progress: 81.0,
                  score: 45000,
                ),
              ];
              ref.read(expandableTableProvider.notifier).loadData(sampleEmployees);
            },
            tooltip: 'Reload Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Floating action button pressed - reloading data');
          final sampleEmployees = [
            const Employee(
              id: '1',
              name: 'Providenci Alten',
              email: 'Alten@address.com',
              registered: 'February 14, 2020',
              rankings: 3.5,
              status: 'Available',
              transaction: 'ARB-8947',
              division: 'Sales',
              location: 'Chicago, IL',
              progress: 98.0,
              score: 15384,
            ),
            const Employee(
              id: '2',
              name: 'John Doe',
              email: 'john@example.com',
              registered: 'March 15, 2020',
              rankings: 4.0,
              status: 'On project',
              transaction: 'ARB-2560',
              division: 'Marketing',
              location: 'New York, NY',
              progress: 100.0,
              score: 32127,
            ),
            const Employee(
              id: '3',
              name: 'Jane Smith',
              email: 'jane@example.com',
              registered: 'April 20, 2020',
              rankings: 3.5,
              status: 'No project',
              transaction: 'ARB-1234',
              division: 'Design',
              location: 'Los Angeles, CA',
              progress: 76.0,
              score: 25000,
            ),
            const Employee(
              id: '4',
              name: 'Bob Johnson',
              email: 'bob@example.com',
              registered: 'May 10, 2020',
              rankings: 5.0,
              status: 'Offline',
              transaction: 'ARB-5678',
              division: 'Engineering',
              location: 'Seattle, WA',
              progress: 81.0,
              score: 45000,
            ),
          ];
          ref.read(expandableTableProvider.notifier).loadData(sampleEmployees);
        },
        tooltip: 'Reload Data',
        child: const Icon(Icons.refresh),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Employee Table with Dessert Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Data: ${tableState.allData.length} items',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Loading: ${tableState.isLoading}',
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                    if (tableState.errorMessage != null)
                      Text(
                        'Error: ${tableState.errorMessage}',
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Debug buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    print('Manual load data button pressed');
                    final sampleEmployees = [
                      const Employee(
                        id: '1',
                        name: 'Providenci Alten',
                        email: 'Alten@address.com',
                        registered: 'February 14, 2020',
                        rankings: 3.5,
                        status: 'Available',
                        transaction: 'ARB-8947',
                        division: 'Sales',
                        location: 'Chicago, IL',
                        progress: 98.0,
                        score: 15384,
                      ),
                      const Employee(
                        id: '2',
                        name: 'John Doe',
                        email: 'john@example.com',
                        registered: 'March 15, 2020',
                        rankings: 4.0,
                        status: 'On project',
                        transaction: 'ARB-2560',
                        division: 'Marketing',
                        location: 'New York, NY',
                        progress: 100.0,
                        score: 32127,
                      ),
                      const Employee(
                        id: '3',
                        name: 'Jane Smith',
                        email: 'jane@example.com',
                        registered: 'April 20, 2020',
                        rankings: 3.5,
                        status: 'No project',
                        transaction: 'ARB-1234',
                        division: 'Design',
                        location: 'Los Angeles, CA',
                        progress: 76.0,
                        score: 25000,
                      ),
                      const Employee(
                        id: '4',
                        name: 'Bob Johnson',
                        email: 'bob@example.com',
                        registered: 'May 10, 2020',
                        rankings: 5.0,
                        status: 'Offline',
                        transaction: 'ARB-5678',
                        division: 'Engineering',
                        location: 'Seattle, WA',
                        progress: 81.0,
                        score: 45000,
                      ),
                    ];
                    ref.read(expandableTableProvider.notifier).loadData(sampleEmployees);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Load Sample Data'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    print('Reload data button pressed');
                    // Reload the same data
                    final sampleEmployees = [
                      const Employee(
                        id: '1',
                        name: 'Providenci Alten',
                        email: 'Alten@address.com',
                        registered: 'February 14, 2020',
                        rankings: 3.5,
                        status: 'Available',
                        transaction: 'ARB-8947',
                        division: 'Sales',
                        location: 'Chicago, IL',
                        progress: 98.0,
                        score: 15384,
                      ),
                      const Employee(
                        id: '2',
                        name: 'John Doe',
                        email: 'john@example.com',
                        registered: 'March 15, 2020',
                        rankings: 4.0,
                        status: 'On project',
                        transaction: 'ARB-2560',
                        division: 'Marketing',
                        location: 'New York, NY',
                        progress: 100.0,
                        score: 32127,
                      ),
                      const Employee(
                        id: '3',
                        name: 'Jane Smith',
                        email: 'jane@example.com',
                        registered: 'April 20, 2020',
                        rankings: 3.5,
                        status: 'No project',
                        transaction: 'ARB-1234',
                        division: 'Design',
                        location: 'Los Angeles, CA',
                        progress: 76.0,
                        score: 25000,
                      ),
                      const Employee(
                        id: '4',
                        name: 'Bob Johnson',
                        email: 'bob@example.com',
                        registered: 'May 10, 2020',
                        rankings: 5.0,
                        status: 'Offline',
                        transaction: 'ARB-5678',
                        division: 'Engineering',
                        location: 'Seattle, WA',
                        progress: 81.0,
                        score: 45000,
                      ),
                    ];
                    ref.read(expandableTableProvider.notifier).loadData(sampleEmployees);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reload Data'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    print('Clear data button pressed');
                    ref.read(expandableTableProvider.notifier).loadData([]);
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ExpandableRiverpodTable<Employee, Dessert>(
                tableProvider: expandableTableProvider,
                childDataGetter: _getChildData,
                childColumns: _getChildColumns(),
                columns: _getParentColumns(),
                valueGetter: _getValue,
                cellBuilderByKey: _buildCellByKey,
                childCellBuilder: _buildChildCell,
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
                  log('Selected: ${employee.name}');
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
  List<Dessert>? _getChildData(Employee employee) {
    // Simulate data - trong thực tế có thể lấy từ API
    final desserts = _getDessertsForEmployee(employee.id);
    return desserts;
  }

  /// Tạo cell cho child table
  TableCellData? _buildChildCell(Dessert dessert, String columnKey) {
    switch (columnKey) {
      case 'name':
        return TableCellData(
          widget: Text(
            dessert.name,
            style: const TextStyle(fontSize: 12),
          ),
        );
      case 'commits':
        return TableCellData(
          widget: Text(
            dessert.commits.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      case 'tasks':
        return TableCellData(
          widget: Text(
            dessert.tasks.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      case 'projects':
        return TableCellData(
          widget: Text(
            dessert.projects.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      case 'hours':
        return TableCellData(
          widget: Text(
            dessert.hours.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      case 'wins':
        return TableCellData(
          widget: Text(
            dessert.wins.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      case 'score':
        return TableCellData(
          widget: Text(
            dessert.score.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        );
      default:
        return null;
    }
  }

  /// Tạo columns cho table cha
  List<TableColumnData> _getParentColumns() {
    return [
      TableColumnData.select(
        name: 'Employee',
        key: 'name',
        width: 200,
        flex: 1,
        isFilterable: true,
      ),
      TableColumnData.select(
        name: 'Registered',
        key: 'registered',
        width: 120,
        isFilterable: true,
      ),
      TableColumnData.withFilter(
        name: 'Rankings',
        key: 'rankings',
        width: 100,
        isFilterable: true,
        filterType: FilterType.number,
      ),
      TableColumnData.withFilter(
        name: 'Status',
        key: 'status',
        width: 120,
        isFilterable: true,
        filterType: FilterType.select,
      ),
      TableColumnData.withFilter(
        name: 'Transaction',
        key: 'transaction',
        width: 120,
        isFilterable: true,
        filterType: FilterType.select,
      ),
      TableColumnData.withFilter(
        name: 'Division',
        key: 'division',
        width: 120,
        isFilterable: true,
        filterType: FilterType.select,
      ),
      TableColumnData.withFilter(
        name: 'Location',
        key: 'location',
        width: 150,
        isFilterable: true,
        filterType: FilterType.select,
      ),
      TableColumnData.withFilter(
        name: 'Progress',
        key: 'progress',
        width: 100,
        isFilterable: true,
        filterType: FilterType.number,
      ),
      TableColumnData(
        name: 'Score',
        key: 'score',
        width: 100,
      ),
    ];
  }

  /// Tạo columns cho table con
  List<TableColumnData> _getChildColumns() {
    return [
      TableColumnData(
        name: 'Dessert',
        key: 'name',
        width: 200,
      ),
      TableColumnData(
        name: 'Commits',
        key: 'commits',
        width: 120,
      ),
      TableColumnData(
        name: 'Tasks',
        key: 'tasks',
        width: 100,
      ),
      TableColumnData(
        name: 'Projects',
        key: 'projects',
        width: 120,
      ),
      TableColumnData(
        name: 'Hours',
        key: 'hours',
        width: 120,
      ),
      TableColumnData(
        name: 'Wins',
        key: 'wins',
        width: 100,
      ),
      TableColumnData(
        name: 'Score',
        key: 'score',
        width: 100,
      ),
    ];
  }

  /// Lấy giá trị từ item theo column index
  dynamic _getValue(Employee item, int columnIndex) {
    switch (columnIndex) {
      case 0: return item.name;
      case 1: return item.registered;
      case 2: return item.rankings;
      case 3: return item.status;
      case 4: return item.transaction;
      case 5: return item.division;
      case 6: return item.location;
      case 7: return item.progress;
      case 8: return item.score;
      default: return '';
    }
  }

  /// Tạo cell theo key
  TableCellData? _buildCellByKey(Employee item, String key) {
    switch (key) {
      case 'name':
        return TableCellData(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case 'rankings':
        return TableCellData(
          widget: Row(
            children: [
              // ...List.generate(5, (index) {
              //   return Icon(
              //     index < item.rankings ? Icons.star : Icons.star_border,
              //     size: 16,
              //     color: Colors.amber,
              //   );
              // }),
              // const SizedBox(width: 4),
              Text('${item.rankings}'),
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
                  color: _getStatusColor(item.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(item.status),
            ],
          ),
        );
      case 'progress':
        return TableCellData(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.progress}%'),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: item.progress / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(item.progress),
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
  List<Dessert> _getDessertsForEmployee(String employeeId) {
    // Simulate data - trong thực tế có thể lấy từ API
    final desserts = [
      const Dessert(
        id: '1',
        name: 'Bitka Coctail',
        commits: 112.1,
        tasks: 24,
        projects: 24,
        hours: 24000,
        wins: 9.0,
        score: 34.7,
      ),
      const Dessert(
        id: '2',
        name: 'Girl Scout Cookies',
        commits: 2.1,
        tasks: 37,
        projects: 9,
        hours: 8000,
        wins: 112.1,
        score: 2.1,
      ),
      const Dessert(
        id: '3',
        name: 'Nougat',
        commits: 34.7,
        tasks: 9,
        projects: 49,
        hours: 6000,
        wins: 34.7,
        score: 112.1,
      ),
      const Dessert(
        id: '4',
        name: 'Marshmallow',
        commits: 45.2,
        tasks: 15,
        projects: 12,
        hours: 12000,
        wins: 25.3,
        score: 67.8,
      ),
      const Dessert(
        id: '5',
        name: 'Lollipop',
        commits: 78.9,
        tasks: 8,
        projects: 33,
        hours: 15000,
        wins: 45.6,
        score: 89.2,
      ),
    ];
    
    // Trả về một số dessert ngẫu nhiên cho mỗi employee
    final random = employeeId.hashCode % desserts.length;
    return desserts.take(random + 1).toList();
  }

  /// Hiển thị dialog edit
  void _showEditDialog(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Text('Edit ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Edited ${employee.name}')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog delete
  void _showDeleteDialog(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${employee.name}')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Widget để khởi tạo dữ liệu mẫu
class ExpandableTableExampleWithData extends ConsumerStatefulWidget {
  const ExpandableTableExampleWithData({super.key});

  @override
  ConsumerState<ExpandableTableExampleWithData> createState() => 
      _ExpandableTableExampleWithDataState();
}

class _ExpandableTableExampleWithDataState extends ConsumerState<ExpandableTableExampleWithData> {
  @override
  void initState() {
    super.initState();
    print('ExpandableTableExampleWithData initState called');
    // Khởi tạo dữ liệu mẫu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('PostFrameCallback executed, loading sample data...');
      _loadSampleData();
    });
  }

  void _loadSampleData() {
    print('Loading sample data...');
    final sampleEmployees = [
      const Employee(
        id: '1',
        name: 'Providenci Alten',
        email: 'Alten@address.com',
        registered: 'February 14, 2020',
        rankings: 3.5,
        status: 'Available',
        transaction: 'ARB-8947',
        division: 'Sales',
        location: 'Chicago, IL',
        progress: 98.0,
        score: 15384,
      ),
      const Employee(
        id: '2',
        name: 'John Doe',
        email: 'john@example.com',
        registered: 'March 15, 2020',
        rankings: 4.0,
        status: 'On project',
        transaction: 'ARB-2560',
        division: 'Marketing',
        location: 'New York, NY',
        progress: 100.0,
        score: 32127,
      ),
      const Employee(
        id: '3',
        name: 'Jane Smith',
        email: 'jane@example.com',
        registered: 'April 20, 2020',
        rankings: 3.5,
        status: 'No project',
        transaction: 'ARB-1234',
        division: 'Design',
        location: 'Los Angeles, CA',
        progress: 76.0,
        score: 25000,
      ),
      const Employee(
        id: '4',
        name: 'Bob Johnson',
        email: 'bob@example.com',
        registered: 'May 10, 2020',
        rankings: 5.0,
        status: 'Offline',
        transaction: 'ARB-5678',
        division: 'Engineering',
        location: 'Seattle, WA',
        progress: 81.0,
        score: 45000,
      ),
    ];

    print('Sample data created with ${sampleEmployees.length} employees');
    ref.read(expandableTableProvider.notifier).loadData(sampleEmployees);
    print('Data loaded into provider');
  }

  @override
  Widget build(BuildContext context) {
    print('ExpandableTableExampleWithData build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expandable Table Example'),
        backgroundColor: AppColor.greenLight,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('Reload button pressed');
              _loadSampleData();
            },
            tooltip: 'Reload Data',
          ),
        ],
      ),
      body: const ExpandableTableExample(),
    );
  }
}
