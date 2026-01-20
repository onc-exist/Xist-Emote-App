import 'package:flutter/material.dart';

class RadialWheelPainter extends CustomPainter {
  final List<double> radii;

  RadialWheelPainter({required this.radii});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Paint for the main outer shell
    final shellPaint = Paint()
      ..color = Colors.white.withAlpha(10) // Very faint
      ..style = PaintingStyle.fill;

    // Paint for the inner icon track
    final trackPaint = Paint()
      ..color = Colors.white.withAlpha(15) // Slightly more visible
      ..style = PaintingStyle.fill;

    // Draw the outer shell first
    canvas.drawCircle(center, radii[1], shellPaint);

    // Draw the inner track on top
    canvas.drawCircle(center, radii[0], trackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
