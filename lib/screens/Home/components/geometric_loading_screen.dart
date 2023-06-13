import 'dart:math';

import 'package:flutter/material.dart';

class GeometricLoadingScreen extends StatefulWidget {
  @override
  _GeometricLoadingScreenState createState() => _GeometricLoadingScreenState();
}

class _GeometricLoadingScreenState extends State<GeometricLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: CustomPaint(
                painter: GeometricPainter(),
                child: SizedBox(
                  width: 100,
                  height: 100,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GeometricPainter extends CustomPainter {
  final int sides = 6;
  final double initialAngle = pi / 6;
  final double strokeWidth = 3;
  final Color strokeColor = Colors.blue;
  final double rotationSpeed = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final path = Path();

    for (var i = 0; i < sides; i++) {
      final angle = initialAngle + i * 2 * pi / sides;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = strokeColor;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
