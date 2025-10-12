import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final Axis axis;
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final double width;

  const DashedLine({
    super.key,
    this.axis = Axis.horizontal,
    this.color = Colors.black,
    this.dashWidth = 5,
    this.dashSpace = 3,
    this.thickness = 1,
    this.width = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(
        axis: axis,
        color: color,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        thickness: thickness,
      ),
      size: axis == Axis.horizontal
          ? Size(double.infinity, width) // ngang
          : Size(width, double.infinity), // dọc
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Axis axis;
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double thickness;

  _DashedLinePainter({
    required this.axis,
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;

    if (axis == Axis.horizontal) {
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, 0),
          Offset(startX + dashWidth, 0),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    } else {
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(0, startY),
          Offset(0, startY + dashWidth),
          paint,
        );
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
