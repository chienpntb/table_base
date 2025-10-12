import 'package:flutter/material.dart';

/// Widget xử lý việc resize cột
class ColumnResizeWidget extends StatelessWidget {
  /// Chỉ số cột
  final int columnIndex;

  /// Callback khi hover cột
  final void Function(int) onColumnHover;

  /// Callback khi không hover cột
  final void Function() onColumnHoverExit;

  /// Chỉ số cột đang được hover
  final int hoveredColumnIndex;

  /// Có đang resize cột không
  final bool isResizing;

  /// Callback khi bắt đầu resize
  final void Function(int, double) onStartResizing;

  /// Callback khi cập nhật preview width
  final void Function(double) onUpdatePreviewWidth;

  /// Callback khi kết thúc resize
  final void Function() onFinishResizing;

  const ColumnResizeWidget({
    super.key,
    required this.columnIndex,
    required this.onColumnHover,
    required this.onColumnHoverExit,
    required this.hoveredColumnIndex,
    required this.isResizing,
    required this.onStartResizing,
    required this.onUpdatePreviewWidth,
    required this.onFinishResizing,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        onStartResizing(columnIndex, details.position.dx);
      },
      onPointerMove: (details) {
        if (isResizing) {
          onUpdatePreviewWidth(details.position.dx);
        }
      },
      onPointerUp: (details) {
        if (isResizing) {
          onFinishResizing();
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        onEnter: (_) {
          if (!isResizing) {
            onColumnHover(columnIndex);
          }
        },
        onExit: (_) {
          if (!isResizing) {
            onColumnHoverExit();
          }
        },
        child: Container(color: Colors.transparent, height: double.infinity),
      ),
    );
  }
}
