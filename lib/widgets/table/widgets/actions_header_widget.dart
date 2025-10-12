import 'package:flutter/material.dart';
import 'package:table_base/core/themes/app_font.dart';

/// Widget hiển thị tiêu đề cho cột hành động
class ActionsHeaderWidget extends StatelessWidget {
  /// Màu text header
  final Color textHeaderColor;

  const ActionsHeaderWidget({super.key, required this.textHeaderColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Hành động',
        style: AppFont.buttonText.copyWith(color: textHeaderColor),
      ),
    );
  }
}
