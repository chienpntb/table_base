import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';
import 'hierarchical_example_model.dart';

/// Provider cho hierarchical table
final hierarchicalTableProvider = AutoDisposeStateNotifierProvider<TableNotifier<TableItem>, GenericTableState<TableItem>>(
  (ref) => HierarchicalTableNotifier(),
);

/// Notifier cho hierarchical table
class HierarchicalTableNotifier extends TableNotifier<TableItem> {
  @override
  Future<List<TableItem>> generateData() async {
    // Simulate loading
    state = state.copyWith(isLoading: true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Load data và convert sang TableItem
    final departments = SampleData.getDepartments();
    final List<TableItem> tableItems = [];
    
    for (final department in departments) {
      // Thêm department
      tableItems.add(department.asTableItem);
      
      // Thêm employees của department
      for (final employee in department.employees) {
        tableItems.add(employee.asTableItem);
      }
    }
    
    state = state.copyWith(
      allData: tableItems,
      filteredData: tableItems,
      currentPageData: tableItems,
      isLoading: false,
    );
    
    return tableItems;
  }
}
