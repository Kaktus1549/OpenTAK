import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:opentak_app/drawing/_paint_notifiers.dart';
import 'package:flutter_map/flutter_map.dart';


class MapStrokesPainter extends CustomPainter {
  MapStrokesPainter({
    required this.camera,
    required this.strokes,
    required this.current,
  });

  final MapCamera camera;
  final List<MapStroke> strokes;
  final MapStroke? current;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    void paintStroke(MapStroke s) {
      if (s.points.length < 2) return;

      final paint = Paint()
        ..strokeWidth = s.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (s.isEraser) {
        paint
          ..blendMode = BlendMode.clear
          ..color = const Color(0x00000000);
      } else {
        paint
          ..blendMode = BlendMode.srcOver
          ..color = s.color;
      }

      final path = ui.Path();
      final first = camera.latLngToScreenOffset(s.points.first);
      path.moveTo(first.dx, first.dy);
      for (final ll in s.points.skip(1)) {
        final o = camera.latLngToScreenOffset(ll);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final s in strokes) {
      paintStroke(s);
    }
    if (current != null) paintStroke(current!);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MapStrokesPainter old) => true;
}
