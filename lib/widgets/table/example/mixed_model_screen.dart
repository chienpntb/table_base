import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_base/widgets/table/widgets/riverpod_table.dart';
import 'package:table_base/widgets/table/models/table_model.dart';
import 'mixed_model_example.dart';
import 'mixed_model_provider.dart';

/// Example screen cho mixed model table
class MixedModelExampleScreen extends ConsumerStatefulWidget {
  const MixedModelExampleScreen({super.key});

  @override
  ConsumerState<MixedModelExampleScreen> createState() => _MixedModelExampleScreenState();
}

class _MixedModelExampleScreenState extends ConsumerState<MixedModelExampleScreen> {
  @override
  void initState() {
    super.initState();
    // Load data khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mixedModelTableProvider.notifier).generateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mixed Model Table Example'),
        backgroundColor: Colors.blue,
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
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛒 Mixed Model Table Demo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Hàng cha: Order (Đơn hàng) với thông tin khách hàng\n'
                    '• Hàng con: OrderItem (Sản phẩm) với thông tin sản phẩm\n'
                    '• Hai model hoàn toàn khác nhau nhưng hiển thị trong cùng table\n'
                    '• Cột "Ngày" cho Order hiển thị ngày đặt hàng\n'
                    '• Cột "Ngày" cho OrderItem hiển thị danh mục sản phẩm',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Mixed Model Table
            Expanded(
              child: RiverpodTable<MixedTableItem>(
                tableProvider: mixedModelTableProvider,
                columns: [
                  TableColumnData(name: 'ID', key: 'id', width: 100),
                  TableColumnData(name: 'Tên/Khách hàng', key: 'name', width: 200),
                  TableColumnData(name: 'Ngày/Danh mục', key: 'date', width: 150),
                  TableColumnData(name: 'Số tiền', key: 'amount', width: 120),
                  TableColumnData(name: 'Trạng thái/Số lượng', key: 'status', width: 120),
                ],
                valueGetter: (item, columnIndex) {
                  switch (columnIndex) {
                    case 0: return item.id;
                    case 1: return item.name;
                    case 2: return item.date;
                    case 3: return item.amount;
                    case 4: return item.status;
                    default: return '';
                  }
                },
                idGetter: (item) => item.id,
                
                // === HIERARCHICAL PROPERTIES ===
                isParentRowGetter: (item) {
                  // Chỉ Order mới là parent row
                  return item.isOrder;
                },
                getChildItems: (item) {
                  // Trả về empty list vì đã flatten data
                  return <MixedTableItem>[];
                },
                rowIdGetter: (item) => item.id,
                enableCollapseAnimation: true,
                childRowBackgroundColor: Colors.orange.withOpacity(0.1),
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

  void _showEditDialog(BuildContext context, MixedTableItem item) {
    final isOrder = item.isOrder;
    final title = isOrder ? 'Chỉnh sửa đơn hàng' : 'Chỉnh sửa sản phẩm';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${item.id}'),
            Text('Tên: ${item.name}'),
            Text('Ngày/Danh mục: ${item.date}'),
            Text('Số tiền: ${item.amount}'),
            Text('Trạng thái/Số lượng: ${item.status}'),
          ],
        ),
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

  void _showDeleteDialog(BuildContext context, MixedTableItem item) {
    final isOrder = item.isOrder;
    final title = isOrder ? 'Xóa đơn hàng' : 'Xóa sản phẩm';
    
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
