import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_base/core/themes/app_icon_svg.dart';

/// Widget hiển thị các nút hành động cho mỗi hàng (sửa/xóa)
class TableActionsWidget<T> extends StatelessWidget {
  /// Item dữ liệu của hàng
  final T item;

  /// Callback khi nhấn nút sửa
  final void Function(T)? onEdit;

  /// Callback khi nhấn nút xóa
  final void Function(T)? onDelete;

  const TableActionsWidget({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nút sửa
        if (onEdit != null) _buildEditButton(),
        if (onDelete != null) _buildDeleteButton(),
      ],
    );
  }

  /// Xây dựng nút sửa
  Widget _buildEditButton() {
    return InkWell(
      onTap: () => onEdit!(item),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          AppIconSvg.iconPencilLine,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
        ),
      ),
    );
  }

  /// Xây dựng nút xóa
  Widget _buildDeleteButton() {
    return InkWell(
      onTap: () => onDelete!(item),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: SvgPicture.asset(
          AppIconSvg.iconTrash2,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.redAccent,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}