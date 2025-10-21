import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/table.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';

/// Model dữ liệu mẫu cho ví dụ hierarchical table
class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final double salary;
  final DateTime joinDate;
  final bool isManager;
  final List<Employee>? subordinates;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.salary,
    required this.joinDate,
    this.isManager = false,
    this.subordinates,
  });
}

/// Provider tạo dữ liệu mẫu
final sampleDataProvider = Provider<List<Employee>>((ref) {
  return [
    Employee(
      id: 'emp_001',
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@company.com',
      department: 'IT',
      position: 'Manager',
      salary: 15000000,
      joinDate: DateTime(2020, 1, 15),
      isManager: true,
      subordinates: [
        Employee(
          id: 'emp_002',
          name: 'Trần Thị B',
          email: 'tranthib@company.com',
          department: 'IT',
          position: 'Developer',
          salary: 12000000,
          joinDate: DateTime(2021, 3, 10),
        ),
        Employee(
          id: 'emp_003',
          name: 'Lê Văn C',
          email: 'levanc@company.com',
          department: 'IT',
          position: 'Developer',
          salary: 11000000,
          joinDate: DateTime(2021, 6, 20),
        ),
        Employee(
          id: 'emp_004',
          name: 'Phạm Thị D',
          email: 'phamthid@company.com',
          department: 'IT',
          position: 'Tester',
          salary: 10000000,
          joinDate: DateTime(2022, 2, 5),
        ),
      ],
    ),
    Employee(
      id: 'emp_005',
      name: 'Hoàng Văn E',
      email: 'hoangvane@company.com',
      department: 'HR',
      position: 'Manager',
      salary: 14000000,
      joinDate: DateTime(2019, 8, 12),
      isManager: true,
      subordinates: [
        Employee(
          id: 'emp_006',
          name: 'Vũ Thị F',
          email: 'vuthif@company.com',
          department: 'HR',
          position: 'Recruiter',
          salary: 9000000,
          joinDate: DateTime(2020, 11, 3),
        ),
        Employee(
          id: 'emp_007',
          name: 'Đặng Văn G',
          email: 'dangvang@company.com',
          department: 'HR',
          position: 'HR Specialist',
          salary: 8500000,
          joinDate: DateTime(2021, 4, 18),
        ),
      ],
    ),
    Employee(
      id: 'emp_008',
      name: 'Bùi Thị H',
      email: 'buithih@company.com',
      department: 'Finance',
      position: 'Accountant',
      salary: 8000000,
      joinDate: DateTime(2022, 1, 10),
    ),
    Employee(
      id: 'emp_009',
      name: 'Ngô Văn I',
      email: 'ngovani@company.com',
      department: 'Marketing',
      position: 'Manager',
      salary: 13000000,
      joinDate: DateTime(2020, 5, 25),
      isManager: true,
      subordinates: [
        Employee(
          id: 'emp_010',
          name: 'Đinh Thị K',
          email: 'dinhthik@company.com',
          department: 'Marketing',
          position: 'Marketing Specialist',
          salary: 7500000,
          joinDate: DateTime(2021, 9, 8),
        ),
      ],
    ),
  ];
});

/// Provider quản lý trạng thái bảng
final hierarchicalTableProvider = AutoDisposeStateNotifierProvider<TableNotifierInterface<Employee>, GenericTableState<Employee>>((ref) {
  return HierarchicalTableNotifier();
});

/// Notifier tùy chỉnh cho hierarchical table
class HierarchicalTableNotifier extends TableNotifier<Employee> {
  @override
  Future<List<Employee>> generateData() async {
    // Trả về dữ liệu mẫu
    return [
      Employee(
        id: 'emp_001',
        name: 'Nguyễn Văn A',
        email: 'nguyenvana@company.com',
        department: 'IT',
        position: 'Manager',
        salary: 15000000,
        joinDate: DateTime(2020, 1, 15),
        isManager: true,
        subordinates: [
          Employee(
            id: 'emp_002',
            name: 'Trần Thị B',
            email: 'tranthib@company.com',
            department: 'IT',
            position: 'Developer',
            salary: 12000000,
            joinDate: DateTime(2021, 3, 10),
          ),
          Employee(
            id: 'emp_003',
            name: 'Lê Văn C',
            email: 'levanc@company.com',
            department: 'IT',
            position: 'Developer',
            salary: 11000000,
            joinDate: DateTime(2021, 6, 20),
          ),
          Employee(
            id: 'emp_004',
            name: 'Phạm Thị D',
            email: 'phamthid@company.com',
            department: 'IT',
            position: 'Tester',
            salary: 10000000,
            joinDate: DateTime(2022, 2, 5),
          ),
        ],
      ),
      Employee(
        id: 'emp_005',
        name: 'Hoàng Văn E',
        email: 'hoangvane@company.com',
        department: 'HR',
        position: 'Manager',
        salary: 14000000,
        joinDate: DateTime(2019, 8, 12),
        isManager: true,
        subordinates: [
          Employee(
            id: 'emp_006',
            name: 'Vũ Thị F',
            email: 'vuthif@company.com',
            department: 'HR',
            position: 'Recruiter',
            salary: 9000000,
            joinDate: DateTime(2020, 11, 3),
          ),
          Employee(
            id: 'emp_007',
            name: 'Đặng Văn G',
            email: 'dangvang@company.com',
            department: 'HR',
            position: 'HR Specialist',
            salary: 8500000,
            joinDate: DateTime(2021, 4, 18),
          ),
        ],
      ),
      Employee(
        id: 'emp_008',
        name: 'Bùi Thị H',
        email: 'buithih@company.com',
        department: 'Finance',
        position: 'Accountant',
        salary: 8000000,
        joinDate: DateTime(2022, 1, 10),
      ),
      Employee(
        id: 'emp_009',
        name: 'Ngô Văn I',
        email: 'ngovani@company.com',
        department: 'Marketing',
        position: 'Manager',
        salary: 13000000,
        joinDate: DateTime(2020, 5, 25),
        isManager: true,
        subordinates: [
          Employee(
            id: 'emp_010',
            name: 'Đinh Thị K',
            email: 'dinhthik@company.com',
            department: 'Marketing',
            position: 'Marketing Specialist',
            salary: 7500000,
            joinDate: DateTime(2021, 9, 8),
          ),
        ],
      ),
    ];
  }
}

/// Widget ví dụ sử dụng HierarchicalTable
class HierarchicalTableExample extends ConsumerWidget {
  const HierarchicalTableExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hierarchical Table Example'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tiêu đề và mô tả
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bảng Phân Cấp với Collapse/Expand',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Nhấn vào mũi tên để mở/đóng các hàng con\n'
                    '• Hàng cha có màu trắng, hàng con có màu xám nhạt\n'
                    '• Hỗ trợ animation mượt mà khi collapse/expand\n'
                    '• Có thể chọn nhiều hàng với checkbox',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Hierarchical Table
            Expanded(
              child: HierarchicalTable<Employee>(
                tableProvider: hierarchicalTableProvider,
                hierarchicalColumns: [
                  HierarchicalTableColumnData.simple(
                    name: 'Tên nhân viên',
                    key: 'name',
                    width: 200,
                    flex: 1,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Email',
                    key: 'email',
                    width: 250,
                    flex: 1,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Phòng ban',
                    key: 'department',
                    width: 120,
                    flex: 0.5,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Vị trí',
                    key: 'position',
                    width: 150,
                    flex: 0.8,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Lương',
                    key: 'salary',
                    width: 120,
                    flex: 0.6,
                  ),
                  HierarchicalTableColumnData.simple(
                    name: 'Ngày vào',
                    key: 'joinDate',
                    width: 120,
                    flex: 0.6,
                  ),
                ],
                valueGetter: (employee, columnIndex) {
                  switch (columnIndex) {
                    case 0: return employee.name;
                    case 1: return employee.email;
                    case 2: return employee.department;
                    case 3: return employee.position;
                    case 4: return employee.salary;
                    case 5: return employee.joinDate;
                    default: return '';
                  }
                },
                cellBuilderByKey: (employee, key) {
                  switch (key) {
                    case 'salary':
                      return TableCellData(
                        widget: Text(
                          '${employee.salary.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          )} VNĐ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    case 'joinDate':
                      return TableCellData(
                        widget: Text(
                          '${employee.joinDate.day}/${employee.joinDate.month}/${employee.joinDate.year}',
                        ),
                      );
                    default:
                      return null;
                  }
                },
                idGetter: (employee) => employee.id,
                rowIdGetter: (employee) => employee.id,
                isParentRowGetter: (employee) => employee.isManager,
                getChildItems: (employee) => employee.subordinates ?? [],
                showCheckboxColumn: true,
                showActionsColumn: true,
                enableRowSelection: true,
                enableRowHover: true,
                showAlternatingRowColors: true,
                childRowBackgroundColor: Colors.grey.shade100,
                childRowPadding: const EdgeInsets.only(left: 0.0),
                enableCollapseAnimation: true,
                onEdit: (employee) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sửa nhân viên: ${employee.name}')),
                  );
                },
                onDelete: (employee) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Xóa nhân viên: ${employee.name}')),
                  );
                },
                onRowTap: (employee) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Chọn nhân viên: ${employee.name}')),
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
