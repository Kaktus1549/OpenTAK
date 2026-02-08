import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

class Point {
  final LatLng location;
  final String name;
  final String id;

  // Generate a unique ID for the point
  Point({required this.location, required this.name, String? id}) : id = id ?? '${location.latitude}:${location.longitude}:$name:${DateTime.now().millisecondsSinceEpoch}'; 
}


class SelectedPointNotifier extends ChangeNotifier {
  String? _name;
  String? get name => _name;

  void setName(String? value) {
    _name = value;
    notifyListeners();
  }
}
