import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Demo sử dụng RiverpodTable với tính năng hierarchical
class RiverpodHierarchicalDemo extends ConsumerWidget {
  const RiverpodHierarchicalDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RiverpodTable Hierarchical Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Demo RiverpodTable với tính năng hierarchical',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RiverpodTable<Employee>(
                tableProvider: riverpodHierarchicalProvider,
                columns: [
                  TableColumnData(name: 'ID', key: 'id', width: 80),
                  TableColumnData(name: 'Tên', key: 'name', width: 200),
                  TableColumnData(name: 'Chức vụ', key: 'position', width: 150),
                  TableColumnData(name: 'Email', key: 'email', width: 250),
                  TableColumnData(name: 'Phòng ban', key: 'department', width: 150),
                ],
                valueGetter: (employee, columnIndex) {
                  switch (columnIndex) {
                    case 0: return employee.id;
                    case 1: return employee.name;
                    case 2: return employee.position;
                    case 3: return employee.email;
                    case 4: return employee.department;
                    default: return '';
                  }
                },
                idGetter: (employee) => employee.id,
                
                // === HIERARCHICAL FEATURES ===
                isParentRowGetter: (employee) => employee.subordinates?.isNotEmpty == true,
                getChildItems: (employee) => employee.subordinates ?? [],
                rowIdGetter: (employee) => employee.id,
                enableCollapseAnimation: true,
                childRowBackgroundColor: Colors.blue.withOpacity(0.1),
                childRowPadding: const EdgeInsets.only(left: 32.0),
                
                // Các tính năng khác
                showActionsColumn: true,
                onEdit: (employee) => print('Edit ${employee.name}'),
                onDelete: (employee) => print('Delete ${employee.name}'),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
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
                  Text('2. Hàng con có nền xanh nhạt'),
                  Text('3. Tất cả tính năng cũ vẫn hoạt động bình thường'),
                  Text('4. Chỉ cần thêm 3 thuộc tính để có hierarchical'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider cho demo RiverpodTable hierarchical
final riverpodHierarchicalProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<Employee>, GenericTableState<Employee>>(
  (ref) => RiverpodHierarchicalNotifier(),
);

/// Notifier cho demo RiverpodTable hierarchical
class RiverpodHierarchicalNotifier extends TableNotifier<Employee> {
  @override
  Future<List<Employee>> generateData() async {
    final data = [
      Employee(
        id: '1',
        name: 'Nguyễn Văn A',
        position: 'Giám đốc',
        email: 'a@company.com',
        department: 'Quản lý',
        subordinates: [
          Employee(
            id: '1.1',
            name: 'Trần Thị B',
            position: 'Trưởng phòng',
            email: 'b@company.com',
            department: 'Nhân sự',
          ),
          Employee(
            id: '1.2',
            name: 'Lê Văn C',
            position: 'Trưởng phòng',
            email: 'c@company.com',
            department: 'Kỹ thuật',
          ),
        ],
      ),
      Employee(
        id: '2',
        name: 'Phạm Thị D',
        position: 'Phó giám đốc',
        email: 'd@company.com',
        department: 'Quản lý',
        subordinates: [
          Employee(
            id: '2.1',
            name: 'Hoàng Văn E',
            position: 'Nhân viên',
            email: 'e@company.com',
            department: 'Kế toán',
          ),
        ],
      ),
      Employee(
        id: '3',
        name: 'Vũ Thị F',
        position: 'Nhân viên',
        email: 'f@company.com',
        department: 'Marketing',
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

/// Model Employee
class Employee {
  final String id;
  final String name;
  final String position;
  final String email;
  final String department;
  final List<Employee>? subordinates;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    required this.department,
    this.subordinates,
  });
}
