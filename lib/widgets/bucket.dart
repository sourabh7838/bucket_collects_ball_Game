import 'package:flutter/material.dart';
import 'dart:math' as math;

class Bucket extends StatelessWidget {
  final bool isActive;
  final int currentFill;
  final int capacity;
  final bool isEmptying;

  const Bucket({
    super.key,
    this.isActive = false,
    this.currentFill = 0,
    this.capacity = 5,
    this.isEmptying = false,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 85,
      height: 95,
      child: CustomPaint(
        size: Size(85, 95),
        painter: BucketPainter(),
      ),
    );
  }
}

class BucketPainter extends CustomPainter {
  const BucketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height * 0.92;

    // Define colors
    const bucketColor = Color(0xFF2C3E50);  // Dark blue-grey
    const rimColor = Color(0xFF34495E);     // Slightly lighter blue-grey
    const shadowColor = Color(0xFF1B2631);   // Darker shade for shadow

    // Calculate dimensions
    final topWidth = size.width * 0.85;
    final bottomWidth = size.width * 0.7;
    final topOffset = size.width * 0.075;

    // Draw shadow
    final shadowPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, height + 2),
          width: bottomWidth,
          height: 4,
        ),
      );
    canvas.drawPath(
      shadowPath,
      Paint()..color = shadowColor,
    );

    // Create bucket path
    final bucketPath = Path()
      ..moveTo(topOffset, 0)
      ..lineTo(topOffset + topWidth, 0)
      ..lineTo(size.width - ((size.width - bottomWidth) / 2), height)
      ..lineTo((size.width - bottomWidth) / 2, height)
      ..close();

    // Draw main bucket body
    canvas.drawPath(
      bucketPath,
      Paint()
        ..color = bucketColor
        ..style = PaintingStyle.fill,
    );

    // Draw rim
    canvas.drawPath(
      bucketPath,
      Paint()
        ..color = rimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Draw top rim highlight
    canvas.drawLine(
      Offset(topOffset, 0),
      Offset(topOffset + topWidth, 0),
      Paint()
        ..color = rimColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
  }

  @override
  bool shouldRepaint(covariant BucketPainter oldDelegate) => false;
} 