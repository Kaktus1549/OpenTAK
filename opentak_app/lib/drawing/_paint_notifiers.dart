import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapStroke {
  MapStroke({
    required this.color,
    required this.width,
    required this.isEraser,
  });

  final Color color;
  final double width;
  final bool isEraser;
  final List<LatLng> points = [];
}

class DrawingController extends ChangeNotifier {
  final List<MapStroke> _strokes = [];
  final List<MapStroke> _redo = [];
  MapStroke? _current;

  List<MapStroke> get strokes => _strokes;
  MapStroke? get current => _current;

  void startStroke({required Color color, required double width, required bool eraser}) {
    _current = MapStroke(color: color, width: width, isEraser: eraser);
    _redo.clear();
    notifyListeners();
  }

  void addPoint(LatLng p) {
    if (_current == null) return;
    _current!.points.add(p);
    notifyListeners();
  }

  void endStroke() {
    if (_current == null) return;
    if (_current!.points.length >= 2) _strokes.add(_current!);
    _current = null;
    notifyListeners();
  }

  void undo() {
    if (_strokes.isEmpty) return;
    _redo.add(_strokes.removeLast());
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _strokes.add(_redo.removeLast());
    notifyListeners();
  }

  void clear() {
    _strokes.clear();
    _redo.clear();
    _current = null;
    notifyListeners();
  }
}

class MapStrokeController extends ChangeNotifier {
  late Color currentColor;
  late double currentWidth;
  late bool isEraser;
  late bool isDrawingEnabled;

  MapStrokeController({
    required this.currentColor,
    required this.currentWidth,
    required this.isEraser,
    this.isDrawingEnabled = false,
  });

  void setColor(Color color) {
    currentColor = color;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    currentWidth = width;
    notifyListeners();
  }

  void setEraser() {
    isEraser = true;
    notifyListeners();
  }

  void setPen() {
    isEraser = false;
    notifyListeners();
  }

  void setDrawingEnabled(bool enabled) {
    isDrawingEnabled = enabled;
    notifyListeners();
  }

  Map<String, dynamic> getCurrentSettings() {
    return {
      'color': currentColor,
      'width': currentWidth,
      'isEraser': isEraser,
    };
  }
}