import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/table/example/hierarchical_table_example.dart';
import 'widgets/table/example/simple_hierarchical_demo.dart';
import 'widgets/table/example/ultra_simple_demo.dart';
import 'widgets/table/example/size_test_demo.dart';
import 'widgets/table/example/size_comparison_demo.dart';
import 'widgets/table/example/riverpod_hierarchical_demo.dart';
import 'widgets/table/example/mixed_model_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hierarchical Table Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ExampleSelector(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget chọn ví dụ để demo
class ExampleSelector extends StatelessWidget {
  const ExampleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hierarchical Table Examples'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Chọn ví dụ để demo:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),
              
              // Ví dụ đơn giản
              _buildExampleCard(
                context,
                title: 'Demo Đơn Giản',
                description: 'Ví dụ cơ bản với dữ liệu sản phẩm\nDễ hiểu và test nhanh',
                icon: Icons.shopping_cart,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SimpleHierarchicalDemo()),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Ví dụ cực đơn giản
              _buildExampleCard(
                context,
                title: 'Demo Cực Đơn Giản',
                description: 'Ví dụ tối giản nhất\nChỉ có 2 cột, dễ hiểu',
                icon: Icons.lightbulb,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UltraSimpleDemo()),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Test kích thước
              _buildExampleCard(
                context,
                title: 'Test Kích Thước',
                description: 'Demo kích thước hàng con = hàng cha\nNhiều cột để test rõ ràng',
                icon: Icons.straighten,
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SizeTestDemo()),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // So sánh kích thước
              _buildExampleCard(
                context,
                title: 'So Sánh Kích Thước',
                description: 'Demo rõ ràng để kiểm tra\nKích thước hàng con = hàng cha',
                icon: Icons.compare_arrows,
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SizeComparisonDemo()),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // RiverpodTable Hierarchical
              _buildExampleCard(
                context,
                title: 'RiverpodTable Hierarchical',
                description: 'Sử dụng RiverpodTable cũ\nChỉ thêm 3 thuộc tính để có hierarchical',
                icon: Icons.table_chart,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RiverpodHierarchicalDemo()),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Nested Table Demo
                  _buildExampleCard(
                    context,
                    title: 'Mixed Model Example',
                    description: 'Order và OrderItem khác model\nNhưng hiển thị trong cùng table',
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MixedModelExampleScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
              
              const SizedBox(height: 20),
              _buildExampleCard(
                context,
                title: 'Ví Dụ Đầy Đủ',
                description: 'Ví dụ hoàn chỉnh với nhân viên\nCó đầy đủ tính năng và tùy chỉnh',
                icon: Icons.people,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HierarchicalTableExample()),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Thông tin
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🎯 Tính Năng Hierarchical Table',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Collapse/Expand với animation mượt mà\n'
                      '• Hiển thị phân cấp với indentation\n'
                      '• Màu sắc phân biệt hàng cha/con\n'
                      '• Tương thích với tất cả tính năng table hiện tại',
                      style: TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
