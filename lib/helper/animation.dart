import 'dart:math';

import 'package:flutter/material.dart';

class PopInPopOutPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final Random random = Random(30);

  PopInPopOutPainter(this.animations);

  @override
  void paint(Canvas canvas, Size size) {
    final icon = Icons.settings;
    final paint = Paint();
    final iconSize = 24.0;

    for (int i = 0; i < animations.length; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final scale = animations[i].value;
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize * scale,
            fontFamily: icon.fontFamily,
            color: const Color.fromARGB(255, 42, 38, 38).withOpacity(0.5),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
