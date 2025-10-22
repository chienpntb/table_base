import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_base/core/themes/app_icon_svg.dart';

/// Widget hiển thị các nút hành động cho mỗi hàng (sửa/xóa/tùy chỉnh)
class TableActionsWidget<T> extends StatelessWidget {
  /// Item dữ liệu của hàng
  final T item;

  /// Callback khi nhấn nút sửa
  final void Function(T)? onEdit;

  /// Callback khi nhấn nút xóa
  final void Function(T)? onDelete;

  /// Danh sách các nút hành động tùy chỉnh
  final List<CustomAction<T>>? customActions;

  const TableActionsWidget({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
    this.customActions,
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
        // Nút xóa
        if (onDelete != null) _buildDeleteButton(),
        // Các nút tùy chỉnh
        if (customActions != null) ..._buildCustomActions(),
      ],
    );
  }

  /// Xây dựng nút sửa
  Widget _buildEditButton() {
    return Tooltip(
      message: 'Sửa',
      child: InkWell(
        onTap: () => onEdit!(item),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: SvgPicture.asset(
            AppIconSvg.iconPencilLine,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  /// Xây dựng nút xóa
  Widget _buildDeleteButton() {
    return Tooltip(
      message: 'Xóa',
      child: InkWell(
        onTap: () => onDelete!(item),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(
            AppIconSvg.iconTrash2,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Colors.redAccent,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng danh sách các nút tùy chỉnh
  List<Widget> _buildCustomActions() {
    return customActions!.map((action) {
      return Tooltip(
        message: action.tooltip,
        child: InkWell(
          onTap: () => action.onPressed(item),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              action.iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                action.color ?? Colors.redAccent,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Lớp đại diện cho một hành động tùy chỉnh
class CustomAction<T> {
  final String iconPath;
  final void Function(T) onPressed;
  final Color? color;
  final String? tooltip;

  CustomAction({
    required this.iconPath,
    required this.onPressed,
    this.color,
    this.tooltip,
  });
}
