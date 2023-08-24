import 'package:flutter/material.dart';

class MapPinPainter extends CustomPainter {
  const MapPinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.black;

    Path path = Path();
    path.moveTo(size.width, size.height * 0.4);
    path.cubicTo(size.width, size.height * 0.47, size.width * 0.98, size.height * 0.53, size.width * 0.94, size.height * 0.59);
    path.cubicTo(size.width * 0.83, size.height * 0.78, size.width * 0.55, size.height, size.width / 2, size.height);
    path.cubicTo(size.width * 0.44, size.height, size.width * 0.08, size.height * 0.7, size.width * 0.02, size.height / 2);
    path.cubicTo(size.width * 0.01, size.height * 0.47, 0, size.height * 0.44, 0, size.height * 0.4);
    path.cubicTo(0, size.height * 0.18, size.width * 0.22, 0, size.width / 2, 0);
    path.cubicTo(size.width * 0.78, 0, size.width, size.height * 0.18, size.width, size.height * 0.4);
    path.cubicTo(size.width, size.height * 0.4, size.width, size.height * 0.4, size.width, size.height * 0.4);
    path.lineTo(size.width / 2, size.height * 0.75);
    path.cubicTo(size.width * 0.72, size.height * 0.75, size.width * 0.91, size.height * 0.6, size.width * 0.91, size.height * 0.41);
    path.cubicTo(size.width * 0.91, size.height * 0.23, size.width * 0.72, size.height * 0.08, size.width / 2, size.height * 0.08);
    path.cubicTo(size.width * 0.28, size.height * 0.08, size.width * 0.09, size.height * 0.23, size.width * 0.09, size.height * 0.41);
    path.cubicTo(size.width * 0.09, size.height * 0.6, size.width * 0.28, size.height * 0.75, size.width / 2, size.height * 0.75);
    path.cubicTo(size.width / 2, size.height * 0.75, size.width / 2, size.height * 0.75, size.width / 2, size.height * 0.75);
    canvas.drawPath(path, paint);  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}