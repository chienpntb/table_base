import 'package:flutter/material.dart';
import 'package:table_base/core/themes/app_color.dart';
import 'package:table_base/core/themes/app_font.dart';

/// Widget hiển thị trạng thái không có dữ liệu
class EmptyStateWidget extends StatelessWidget {
  /// Thông báo hiển thị khi không có dữ liệu
  final String emptyMessage;

  /// Icon hiển thị khi không có dữ liệu
  final IconData emptyIcon;

  /// Kích thước icon
  final double iconSize;

  /// Màu icon
  final Color iconColor;

  const EmptyStateWidget({
    super.key,
    this.emptyMessage = 'Không có dữ liệu để hiển thị',
    this.emptyIcon = Icons.inbox_outlined,
    this.iconSize = 48,
    this.iconColor = AppColor.textGrey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: iconSize, color: iconColor),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppFont.titleMedium.copyWith(
                color: AppColor.textGrey,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
