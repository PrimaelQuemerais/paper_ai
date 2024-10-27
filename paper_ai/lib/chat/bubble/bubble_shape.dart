import 'package:flutter/material.dart';

class BubbleShape extends ShapeBorder {
  final bool isAI;

  const BubbleShape({required this.isAI});

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    if (isAI) {
      path.moveTo(rect.left + 10, rect.top);
      path.lineTo(rect.right, rect.top);
      path.lineTo(rect.right, rect.bottom);
      path.lineTo(rect.left + 10, rect.bottom);
      path.lineTo(rect.left, rect.bottom - 10);
      path.lineTo(rect.left + 10, rect.bottom - 10);
      path.close();
    } else {
      path.moveTo(rect.right - 10, rect.top);
      path.lineTo(rect.left, rect.top);
      path.lineTo(rect.left, rect.bottom);
      path.lineTo(rect.right - 10, rect.bottom);
      path.lineTo(rect.right, rect.bottom - 10);
      path.lineTo(rect.right - 10, rect.bottom - 10);
      path.close();
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }
}
