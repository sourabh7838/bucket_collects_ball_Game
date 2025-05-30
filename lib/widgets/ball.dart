import 'package:flutter/material.dart';
import 'dart:math' as math;

class Ball extends StatelessWidget {
  static const double size = 24.0;
  final Color color;
  final bool isGlowing;
  final double rotation;

  const Ball({
    super.key,
    this.color = Colors.white,
    this.isGlowing = false,
    this.rotation = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(size, size),
        painter: BallPainter(
          color: color,
          isGlowing: isGlowing,
        ),
      ),
    );
  }
}

class BallPainter extends CustomPainter {
  final Color color;
  final bool isGlowing;

  BallPainter({
    required this.color,
    required this.isGlowing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base shadow (solid)
    final shadowPaint = Paint()
      ..color = Colors.black
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(
      center.translate(1, 1),
      radius - 1,
      shadowPaint,
    );

    // Base ball color (solid)
    final ballPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, ballPaint);

    // Add darker edge for depth
    final edgePaint = Paint()
      ..color = color.darken(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, edgePaint);

    // Add highlight (solid white with sharp edge)
    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        center.dx - radius * 0.3,
        center.dy - radius * 0.3,
      ),
      radius * 0.2,
      highlightPaint,
    );

    // Add small secondary highlight
    canvas.drawCircle(
      Offset(
        center.dx + radius * 0.2,
        center.dy + radius * 0.2,
      ),
      radius * 0.1,
      highlightPaint,
    );

    if (isGlowing) {
      final outlinePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius + 1, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BallPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isGlowing != isGlowing;
  }
}

extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
} 