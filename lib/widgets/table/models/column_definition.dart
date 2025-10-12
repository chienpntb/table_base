
import 'package:table_base/widgets/table/models/table_model.dart';

typedef TableCellBuilder = TableCellData Function(dynamic item);

class ColumnDefinition {
  final TableColumnData config;
  final TableCellBuilder builder;

  ColumnDefinition({required this.config, required this.builder});
}


