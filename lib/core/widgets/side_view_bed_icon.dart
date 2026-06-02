import 'package:flutter/material.dart';

class SideViewBedIcon extends StatelessWidget {
  final double size;
  final Color color;

  const SideViewBedIcon({
    super.key,
    this.size = 24.0,
    this.color = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BedPainter(color: color),
      ),
    );
  }
}

class _BedPainter extends CustomPainter {
  final Color color;

  _BedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final headboardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.15, w * 0.12, h * 0.50),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(headboardRect, fillPaint);

    final bedFrameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.40, w * 0.82, h * 0.25),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(bedFrameRect, paint);

    final pillowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final pillowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.30, w * 0.20, h * 0.15),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(pillowRect, pillowPaint);

    canvas.drawLine(
      Offset(w * 0.82, h * 0.65),
      Offset(w * 0.82, h * 0.80),
      paint,
    );

    canvas.drawLine(
      Offset(w * 0.15, h * 0.65),
      Offset(w * 0.15, h * 0.80),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BedPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
