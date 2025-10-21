/// Model dữ liệu cho hierarchical table example
class Department {
  final String id;
  final String name;
  final String manager;
  final int employeeCount;
  final List<Employee> employees;

  Department({
    required this.id,
    required this.name,
    required this.manager,
    required this.employeeCount,
    required this.employees,
  });
}

class Employee {
  final String id;
  final String name;
  final String position;
  final String email;
  final int salary;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    required this.salary,
  });
}

/// Union type để hiển thị cả Department và Employee
abstract class TableItem {
  String get id;
  String get name;
  String get manager;
  String get employeeCount;
  bool get isDepartment; // Thêm property để phân biệt
}

/// Extension để Department implement TableItem
extension DepartmentAsTableItem on Department {
  TableItem get asTableItem => _DepartmentTableItem(this);
}

/// Extension để Employee implement TableItem
extension EmployeeAsTableItem on Employee {
  TableItem get asTableItem => _EmployeeTableItem(this);
}

/// Wrapper cho Department
class _DepartmentTableItem implements TableItem {
  final Department _department;
  
  _DepartmentTableItem(this._department);
  
  @override
  String get id => _department.id;
  
  @override
  String get name => _department.name;
  
  @override
  String get manager => _department.manager;
  
  @override
  String get employeeCount => _department.employeeCount.toString();
  
  @override
  bool get isDepartment => true;
}

/// Wrapper cho Employee
class _EmployeeTableItem implements TableItem {
  final Employee _employee;
  
  _EmployeeTableItem(this._employee);
  
  @override
  String get id => _employee.id;
  
  @override
  String get name => _employee.name;
  
  @override
  String get manager => _employee.position;
  
  @override
  String get employeeCount => _employee.salary.toString();
  
  @override
  bool get isDepartment => false;
}

/// Dữ liệu mẫu
class SampleData {
  static List<Department> getDepartments() {
    return [
      Department(
        id: 'DEPT001',
        name: 'Phòng IT',
        manager: 'Nguyễn Văn A',
        employeeCount: 5,
        employees: [
          Employee(
            id: 'EMP001',
            name: 'Trần Thị B',
            position: 'Developer',
            email: 'b@company.com',
            salary: 15000000,
          ),
          Employee(
            id: 'EMP002',
            name: 'Lê Văn C',
            position: 'Tester',
            email: 'c@company.com',
            salary: 12000000,
          ),
        ],
      ),
      Department(
        id: 'DEPT002',
        name: 'Phòng Marketing',
        manager: 'Phạm Thị D',
        employeeCount: 3,
        employees: [
          Employee(
            id: 'EMP003',
            name: 'Hoàng Văn E',
            position: 'Designer',
            email: 'e@company.com',
            salary: 13000000,
          ),
        ],
      ),
      Department(
        id: 'DEPT003',
        name: 'Phòng HR',
        manager: 'Võ Thị F',
        employeeCount: 2,
        employees: [],
      ),
    ];
  }
}
