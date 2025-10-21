import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expandable_table_model.dart';
import '../providers/expandable_table_notifier.dart';
import '../models/table_model.dart';

/// Simple ExpandableTable widget
class ExpandableTable<T> extends ConsumerWidget {
  final AutoDisposeStateNotifierProvider<
    ExpandableTableNotifier<T>,
    ExpandableTableState<T>
  > tableProvider;
  
  final List<TableColumnData> columns;
  final dynamic Function(T item, int columnIndex) valueGetter;
  final List<T>? Function(T parent)? childrenGetter;
  final TableCellData? Function(T item, String key)? cellBuilderByKey;
  final double indentSize;

  const ExpandableTable({
    super.key,
    required this.tableProvider,
    required this.columns,
    required this.valueGetter,
    this.childrenGetter,
    this.cellBuilderByKey,
    this.indentSize = 24.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    
    if (tableState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (tableState.error != null) {
      return Center(
        child: Text('Error: ${tableState.error}'),
      );
    }
    
    if (tableState.expandableData?.displayItems == null || 
        tableState.expandableData!.displayItems.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }
    
    return SingleChildScrollView(
      child: _buildTable(context, ref, tableState),
    );
  }
  
  Widget _buildTable(BuildContext context, WidgetRef ref, ExpandableTableState<T> tableState) {
    final displayItems = tableState.expandableData!.displayItems;
    
    return Column(
      children: [
        // Header
        Container(
          color: Colors.blue,
          child: Row(
            children: [
              // Expand icon column
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.expand_more,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              // Data columns
              ...columns.map((column) => Container(
                width: column.width,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  column.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
            ],
          ),
        ),
        
        // Body
        ...displayItems.map((displayItem) => _buildRow(
          context, ref, displayItem, displayItems.indexOf(displayItem)
        )),
      ],
    );
  }
  
  Widget _buildRow(BuildContext context, WidgetRef ref, ExpandableDisplayItem<T> displayItem, int index) {
    final isEven = index % 2 == 0;
    final backgroundColor = isEven ? Colors.white : Colors.grey[50];
    
    return Container(
      color: backgroundColor,
      child: Row(
        children: [
          // Expand icon column
          Container(
            width: 48,
            height: 48,
            padding: EdgeInsets.only(left: displayItem.level * indentSize),
            child: displayItem.isParent && displayItem.hasChildren
                ? IconButton(
                    icon: Icon(
                      displayItem.isExpanded 
                          ? Icons.expand_less 
                          : Icons.expand_more,
                      size: 20,
                    ),
                    onPressed: () {
                      final itemId = displayItem.itemId ?? '';
                      ref.read(tableProvider.notifier).toggleExpand(itemId);
                    },
                  )
                : const SizedBox.shrink(),
          ),
          
          // Data columns  
          ...columns.asMap().entries.map((entry) {
            final columnIndex = entry.key;
            final column = entry.value;
            
            Widget cellContent;
            
            if (cellBuilderByKey != null) {
              final cellData = cellBuilderByKey!(displayItem.data, column.key);
              cellContent = cellData?.widget ?? Text(valueGetter(displayItem.data, columnIndex).toString());
            } else {
              cellContent = Text(valueGetter(displayItem.data, columnIndex).toString());
            }
            
            return Container(
              width: column.width,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: cellContent,
            );
          }),
        ],
      ),
    );
  }
}