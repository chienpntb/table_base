import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/widgets/riverpod_table.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'hierarchical_example_model.dart';
import 'hierarchical_example_provider.dart';

/// Example screen cho hierarchical table
class HierarchicalExampleScreen extends ConsumerStatefulWidget {
  const HierarchicalExampleScreen({super.key});

  @override
  ConsumerState<HierarchicalExampleScreen> createState() => _HierarchicalExampleScreenState();
}

class _HierarchicalExampleScreenState extends ConsumerState<HierarchicalExampleScreen> {
  @override
  void initState() {
    super.initState();
    // Load data khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hierarchicalTableProvider.notifier).generateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hierarchical Table Example'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mô tả
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Hierarchical Table Demo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Click nút ▼ để mở rộng phòng ban\n'
                    '• Click nút ▲ để thu gọn phòng ban\n'
                    '• Hàng con sẽ hiển thị thụt lề với màu nền tím nhạt\n'
                    '• Mỗi hàng con hiển thị thông tin nhân viên riêng biệt',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Hierarchical Table
            Expanded(
              child: RiverpodTable<TableItem>(
                tableProvider: hierarchicalTableProvider,
                columns: [
                  TableColumnData(name: 'ID', key: 'id', width: 100),
                  TableColumnData(name: 'Tên', key: 'name', width: 200),
                  TableColumnData(name: 'Chức vụ/Trưởng phòng', key: 'manager', width: 150),
                  TableColumnData(name: 'Số nhân viên/Lương', key: 'employeeCount', width: 120),
                ],
                valueGetter: (item, columnIndex) {
                  switch (columnIndex) {
                    case 0: return item.id;
                    case 1: return item.name;
                    case 2: return item.manager;
                    case 3: return item.employeeCount;
                    default: return '';
                  }
                },
                idGetter: (item) => item.id,
                
                // === HIERARCHICAL PROPERTIES ===
                isParentRowGetter: (item) {
                  // Chỉ Department mới là parent row
                  return item.isDepartment;
                },
                getChildItems: (item) {
                  // Trả về empty list vì đã flatten data
                  return <TableItem>[];
                },
                rowIdGetter: (item) => item.id,
                enableCollapseAnimation: true,
                childRowBackgroundColor: Colors.purple.withOpacity(0.1),
                childRowPadding: const EdgeInsets.only(left: 32.0),
                
                // Styling
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                rowHeight: 50,
                
                // Actions
                showActionsColumn: true,
                onEdit: (item) {
                  _showEditDialog(context, item);
                },
                onDelete: (item) {
                  _showDeleteDialog(context, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TableItem item) {
    final isDepartment = item.isDepartment;
    final title = isDepartment ? 'Chỉnh sửa phòng ban' : 'Chỉnh sửa nhân viên';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Bạn muốn chỉnh sửa: ${item.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã chỉnh sửa ${item.name}')),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, TableItem item) {
    final isDepartment = item.isDepartment;
    final title = isDepartment ? 'Xóa phòng ban' : 'Xóa nhân viên';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('Bạn có chắc muốn xóa: ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa ${item.name}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
