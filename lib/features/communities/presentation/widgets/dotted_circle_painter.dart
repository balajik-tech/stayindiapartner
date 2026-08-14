import 'dart:math' as math;

import 'package:flutter/cupertino.dart';


class DashedLineCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedLineCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.gapLength = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final circumference = 2 * math.pi * radius;
    final dashCount =
    (circumference / (dashLength + gapLength)).floor();

    final angleStep = 2 * math.pi / dashCount;
    final dashAngle = angleStep * (dashLength / (dashLength + gapLength));

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * angleStep;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedLineCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}