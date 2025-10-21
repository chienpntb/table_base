import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/providers/table_notifier.dart';
import 'package:table_base/widgets/table/providers/table_state.dart';
import 'mixed_model_example.dart';

/// Provider cho mixed model table
final mixedModelTableProvider = AutoDisposeStateNotifierProvider<TableNotifier<MixedTableItem>, GenericTableState<MixedTableItem>>(
  (ref) => MixedModelTableNotifier(),
);

/// Notifier cho mixed model table
class MixedModelTableNotifier extends TableNotifier<MixedTableItem> {
  @override
  Future<List<MixedTableItem>> generateData() async {
    // Simulate loading
    state = state.copyWith(isLoading: true);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Load data và convert sang MixedTableItem
    final orders = MixedSampleData.getOrders();
    final List<MixedTableItem> tableItems = [];
    
    for (final order in orders) {
      // Thêm order
      tableItems.add(order.asMixedTableItem);
      
      // Thêm order items của order
      for (final item in order.items) {
        tableItems.add(item.asMixedTableItem);
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
