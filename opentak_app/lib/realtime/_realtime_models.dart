import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

String colorToHex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}'; // Helped by ChatGPT
Color hexToColor(String s) {
  final hex = s.replaceFirst('#', '');
  final v = int.parse(hex, radix: 16);
  return Color(v);
}

class NetSOSEvent {
  final String id;
  final String username;
  final int ts;

  NetSOSEvent({
    required this.id,
    required this.username,
    required this.ts,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'ts': ts,
      };

  static NetSOSEvent fromJson(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return NetSOSEvent(
      id: m['id'] as String,
      username: m['username'] as String,
      ts: (m['ts'] as num).toInt(),
    );
  }
}

class NetMarkerEvent {
  final String op; // upsert, delete
  final String id;
  final String? name;
  final double? lat;
  final double? lon;
  final int ts;

  NetMarkerEvent({
    required this.op,
    required this.id,
    required this.ts,
    this.name,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() => {
        'op': op,
        'id': id,
        if (name != null) 'name': name,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        'ts': ts,
      };

  static NetMarkerEvent fromJson(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return NetMarkerEvent(
      op: m['op'] as String,
      id: m['id'] as String,
      name: m['name'] as String?,
      lat: (m['lat'] as num?)?.toDouble(),
      lon: (m['lon'] as num?)?.toDouble(),
      ts: (m['ts'] as num).toInt(),
    );
  }
}

class NetStrokeChunk {
  final String id; // stroke id
  final String op; // stroke
  final String color; // #AARRGGBB
  final double width;
  final bool eraser;
  final List<List<double>> pts; // [[lat, lon], ...]
  final bool done;
  final int ts;

  NetStrokeChunk({
    required this.id,
    required this.op,
    required this.color,
    required this.width,
    required this.eraser,
    required this.pts,
    required this.done,
    required this.ts,
  });

  Map<String, dynamic> toJson() => {
        'op': op,
        'id': id,
        'color': color,
        'width': width,
        'eraser': eraser,
        'pts': pts,
        'done': done,
        'ts': ts,
      };

  static NetStrokeChunk fromJson(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return NetStrokeChunk(
      op: m['op'] as String,
      id: m['id'] as String,
      color: m['color'] as String,
      width: (m['width'] as num).toDouble(),
      eraser: m['eraser'] as bool,
      pts: (m['pts'] as List)
          .map((e) => (e as List).map((n) => (n as num).toDouble()).toList())
          .map((p) => [p[0], p[1]])
          .toList(),
      done: m['done'] as bool,
      ts: (m['ts'] as num).toInt(),
    );
  }

  List<LatLng> toLatLngs() => pts.map((p) => LatLng(p[0], p[1])).toList();
}


class NetPlayerEvent{
  final String op; // upsert, delete
  final String name;
  final double direction; // in degrees, 0 = north, clockwise
  final double? lat;
  final double? lon;
  final int ts;

  NetPlayerEvent({
    required this.op,
    required this.name,
    required this.ts,
    required this.direction,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() => {
        'op': op,
        'name': name,
        'direction': direction,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        'ts': ts,
  };

  static NetPlayerEvent fromJson(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return NetPlayerEvent(
      op: m['op'] as String,
      name: m['name'] as String,
      direction: (m['direction'] as num).toDouble(),
      lat: (m['lat'] as num?)?.toDouble(),
      lon: (m['lon'] as num?)?.toDouble(),
      ts: (m['ts'] as num).toInt(),
    );
  }
  

}