import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PatternBackground extends StatelessWidget {
  final Widget child;
  final Color? patternColor;
  final double opacity;

  const PatternBackground({
    super.key,
    required this.child,
    this.patternColor,
    this.opacity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _PatternPainter(
              color: patternColor ?? AppColors.primaryBlue,
              opacity: opacity,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _PatternPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
