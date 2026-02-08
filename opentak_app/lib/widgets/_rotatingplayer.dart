import 'dart:math' as math;
import 'package:flutter/material.dart';

class RotatingPlayer extends StatelessWidget {
  const RotatingPlayer({
    super.key,
    required this.name,
    required this.color,
    required this.directionDeg, // 0 = north, clockwise
    this.size = 34,
  });

  final String name;
  final Color color;
  final double directionDeg;
  final double size;

   @override
  Widget build(BuildContext context) {
    final dirRad = directionDeg * math.pi / 180.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size + 10,
              height: size + 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 140),
                shape: BoxShape.circle,
              ),
            ),

            Container(
              width: size + 6,
              height: size + 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 120), width: 1.5),
              ),
            ),

            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 220),
                shape: BoxShape.circle,
              ),
            ),

            Transform.rotate(
              angle: dirRad,
              child: Icon(
                Icons.navigation,
                size: size * 0.65,
                color: Colors.white,
              ),
            ),


          ],
        ),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 170),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 120), width: 1),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}