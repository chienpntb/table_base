import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Demo sử dụng RiverpodTable với nested table
class NestedTableDemo extends ConsumerWidget {
  const NestedTableDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nested Table Demo'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Demo RiverpodTable với nested table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RiverpodTable<Department>(
                tableProvider: nestedTableProvider,
                columns: [
                  TableColumnData(name: 'ID', key: 'id', width: 100),
                  TableColumnData(name: 'Tên phòng ban', key: 'name', width: 200),
                  TableColumnData(name: 'Trưởng phòng', key: 'manager', width: 150),
                  TableColumnData(name: 'Số nhân viên', key: 'employeeCount', width: 120),
                ],
                valueGetter: (department, columnIndex) {
                  switch (columnIndex) {
                    case 0: return department.id;
                    case 1: return department.name;
                    case 2: return department.manager;
                    case 3: return department.employees.length;
                    default: return '';
                  }
                },
                idGetter: (department) => department.id,
                
                // === HIERARCHICAL FEATURES ===
                isParentRowGetter: (department) => department.employees.isNotEmpty,
                getChildItems: (department) => [], // Không cần vì dùng nested table
                rowIdGetter: (department) => department.id,
                enableCollapseAnimation: true,
                childRowBackgroundColor: Colors.purple.withOpacity(0.1),
                childRowPadding: const EdgeInsets.all(16.0),
                
                // 🆕 NESTED TABLE FEATURES
                showChildAsNestedTable: true,
                childTableBuilderAsync: (department) async {
                  // Simulate API call để lấy dữ liệu nhân viên
                  await Future.delayed(const Duration(milliseconds: 500));
                  return _buildNestedEmployeeTable(department.employees);
                },
                lazyLoadingDelay: const Duration(milliseconds: 500),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hướng dẫn sử dụng:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1. Click vào mũi tên để thu gọn/mở rộng'),
                  Text('2. Phần con hiển thị như nested table riêng biệt'),
                  Text('3. Nested table có thể có cấu trúc khác hoàn toàn'),
                  Text('4. Tất cả tính năng table vẫn hoạt động bình thường'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng nested table cho nhân viên
  Widget _buildNestedEmployeeTable(List<Employee> employees) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header của nested table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.people, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Danh sách nhân viên',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          
          // Nested table content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Chức vụ')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Lương')),
              ],
              rows: employees.map((employee) {
                return DataRow(
                  cells: [
                    DataCell(Text(employee.id)),
                    DataCell(Text(employee.name)),
                    DataCell(Text(employee.position)),
                    DataCell(Text(employee.email)),
                    DataCell(Text('${employee.salary.toStringAsFixed(0)} VNĐ')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider cho demo nested table
final nestedTableProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<Department>, GenericTableState<Department>>(
  (ref) => NestedTableNotifier(),
);

/// Notifier cho demo nested table
class NestedTableNotifier extends TableNotifier<Department> {
  @override
  Future<List<Department>> generateData() async {
    final data = [
      Department(
        id: 'DEPT1',
        name: 'Phòng Kỹ thuật',
        manager: 'Nguyễn Văn A',
        employees: [
          Employee(
            id: 'EMP1',
            name: 'Trần Thị B',
            position: 'Senior Developer',
            email: 'b@company.com',
            salary: 15000000,
          ),
          Employee(
            id: 'EMP2',
            name: 'Lê Văn C',
            position: 'Junior Developer',
            email: 'c@company.com',
            salary: 8000000,
          ),
          Employee(
            id: 'EMP3',
            name: 'Phạm Thị D',
            position: 'DevOps Engineer',
            email: 'd@company.com',
            salary: 12000000,
          ),
        ],
      ),
      Department(
        id: 'DEPT2',
        name: 'Phòng Nhân sự',
        manager: 'Hoàng Văn E',
        employees: [
          Employee(
            id: 'EMP4',
            name: 'Vũ Thị F',
            position: 'HR Manager',
            email: 'f@company.com',
            salary: 13000000,
          ),
          Employee(
            id: 'EMP5',
            name: 'Đặng Văn G',
            position: 'Recruiter',
            email: 'g@company.com',
            salary: 9000000,
          ),
        ],
      ),
      Department(
        id: 'DEPT3',
        name: 'Phòng Marketing',
        manager: 'Bùi Thị H',
        employees: [],
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

/// Model Department
class Department {
  final String id;
  final String name;
  final String manager;
  final List<Employee> employees;

  Department({
    required this.id,
    required this.name,
    required this.manager,
    required this.employees,
  });
}

/// Model Employee
class Employee {
  final String id;
  final String name;
  final String position;
  final String email;
  final double salary;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    required this.salary,
  });
}
