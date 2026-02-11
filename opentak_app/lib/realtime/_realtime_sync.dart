import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:opentak_app/realtime/_realtime_models.dart';
import 'package:opentak_app/points/_point.dart';
import 'package:opentak_app/drawing/_paint_notifiers.dart';
import 'package:opentak_app/Utils/_mqtt.dart'; 
import 'package:opentak_app/notifications/test.dart';
import 'dart:convert';
import 'dart:typed_data';

class MqttEnvelope {
  final String topic;
  final Uint8List payload;

  MqttEnvelope(this.topic, this.payload);
}

Map<String, dynamic>? _tryDecodeJson(String topic, String payload) {
  try {

    final v = jsonDecode(payload);
    if (v is Map<String, dynamic>) return v;

    debugPrint('Skipping non-object JSON on $topic: ${v.runtimeType}');
    return null;
  } catch (e) {
    debugPrint('Skipping bad JSON on $topic: $e');
    debugPrint(payload);
    return null;
  }
}



class RemoteStroke {
  RemoteStroke({
    required this.id,
    required this.color,
    required this.width,
    required this.isEraser,
  });

  final String id;
  final Color color;
  final double width;
  final bool isEraser;
  final List<LatLng> points = [];
}

class RemotePlayer {
  RemotePlayer({
    required this.name,
    required this.color,
    required this.location,
    required this.direction,
  });

  final String name;
  final Color color; // TODO: In feature replace with profile picture or something, color is just for testing
  final LatLng location;
  final double direction; // in degrees, 0 = north, clockwise
}

class TakRealtimeSync {
  TakRealtimeSync({
    required this.mqtt,
    required this.roomId,
    required this.clientId,
  });

  late OpenTAKMQTTClient mqtt;
  late String roomId;
  late String clientId;

  final Map<String, Point> remoteMarkers = {};      // markerId -> Point
  final Map<String, RemoteStroke> remoteStrokes = {}; // strokeId -> stroke
  final Map<String, RemotePlayer> remotePlayers = {}; // playerName -> Player

  final Map<String, int> _lastSeen = {}; // name -> lastSeenMs
  Timer? _pruneTimer;

  Timer? _heartbeat;

  final _changed = StreamController<void>.broadcast();
  Stream<void> get changed => _changed.stream;

  StreamSubscription? _sub;

  final List<LatLng> _pendingPts = [];
  Timer? _flushTimer;
  String? _activeStrokeId;
  Color? _activeColor;
  double? _activeWidth;
  bool? _activeEraser;

  void setMqttClient(OpenTAKMQTTClient newClient) {
    if (mqtt.isConnected) {
      mqtt.incoming.drain();
      mqtt.cursorUpdates.drain();
    }
    _sub?.cancel();
    mqtt = newClient;
    start();
  }

  void startHeartbeat(String name, LatLng Function() getPos, double Function() getDir) {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 5), (_) {
      publishPlayerUpdate(name, getPos(), getDir());
    });
  }

  void stopHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  void start() {
    mqtt.subscribe('tak/$roomId/marker/+');
    mqtt.subscribe('tak/$roomId/stroke/+');
    mqtt.subscribe('tak/$roomId/player/+');
    mqtt.subscribe('tak/$roomId/sos/+');

    // Start pruning ONCE
    _pruneTimer?.cancel();
    _pruneTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      const timeoutMs = 15000;

      final toRemove = _lastSeen.entries
          .where((e) => now - e.value > timeoutMs)
          .map((e) => e.key)
          .toList();

      for (final name in toRemove) {
        _lastSeen.remove(name);
        remotePlayers.remove(name);
      }

      if (toRemove.isNotEmpty) _changed.add(null);
    });

    _sub = mqtt.incoming.listen((env) {
      final raw = env.payload;

      String text;
      try {
        text = utf8.decode(raw, allowMalformed: false);
      } catch (_) {
        debugPrint('Dropping non-UTF8 payload on ${env.topic} len=${raw.length}');
        return;
      }

      _handle(env.topic, text);
    });
  }

  void dispose() {
    publishPlayerDelete(clientId);
    _sub?.cancel();
    _flushTimer?.cancel();
    _changed.close();
    _pruneTimer?.cancel();
  }

  void reset(OpenTAKMQTTClient newClient, String newRoomId, String newClientId) {
    _sub?.cancel();
    mqtt = newClient;
    roomId = newRoomId;
    clientId = newClientId;
    remoteMarkers.clear();
    remoteStrokes.clear();
    remotePlayers.clear();
    _lastSeen.clear();
    start();
  }

  // ---------- SOS (publish) ----------

  void publishSOS(String username) {
    final evt = NetSOSEvent(
      id: clientId,
      username: username,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    mqtt.publishJson('tak/$roomId/sos/$clientId', evt.toJson());
  }

  // ---------- MARKERS (publish) ----------

  void publishMarkerUpsert(Point p) {
    final evt = NetMarkerEvent(
      op: 'upsert',
      id: p.id,
      name: p.name,
      lat: p.location.latitude,
      lon: p.location.longitude,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    mqtt.publishJson('tak/$roomId/marker/$clientId', evt.toJson());
  }

  void publishMarkerDelete(String markerId) {
    final evt = NetMarkerEvent(
      op: 'delete',
      id: markerId,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    mqtt.publishJson('tak/$roomId/marker/$clientId', evt.toJson());
  }

  // ---------- DRAWING (publish) ----------

  void beginStroke(MapStroke stroke) {
    _activeStrokeId = 's_${clientId}_${DateTime.now().millisecondsSinceEpoch}';
    _activeColor = stroke.color;
    _activeWidth = stroke.width;
    _activeEraser = stroke.isEraser;

    _pendingPts.clear();
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      _flushStrokeChunk(done: false);
    });
  }

  void addStrokePoint(LatLng p) {
    if (_activeStrokeId == null) return;
    _pendingPts.add(p);

    // simple chunk limit
    if (_pendingPts.length >= 25) {
      _flushStrokeChunk(done: false);
    }
  }

  void endStroke() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _flushStrokeChunk(done: true);

    _activeStrokeId = null;
    _activeColor = null;
    _activeWidth = null;
    _activeEraser = null;
    _pendingPts.clear();
  }

  void _flushStrokeChunk({required bool done}) {
    final id = _activeStrokeId;
    if (id == null) return;

    // Send even if done and no points? no.
    if (_pendingPts.isEmpty && !done) return;

    final chunk = NetStrokeChunk(
      op: 'stroke',
      id: id,
      color: colorToHex(_activeColor ?? const Color(0xFFFFFFFF)),
      width: _activeWidth ?? 3.0,
      eraser: _activeEraser ?? false,
      pts: _pendingPts
          .map((p) => [p.latitude, p.longitude])
          .toList(growable: false),
      done: done,
      ts: DateTime.now().millisecondsSinceEpoch,
    );

    mqtt.publishJson('tak/$roomId/stroke/$clientId', chunk.toJson());
    _pendingPts.clear();
  }

  // ---------- PLAYERS (publish) ----------

  void publishPlayerUpdate(String name, LatLng? location, double? direction) {
    final evt = NetPlayerEvent(
      op: 'upsert',
      name: name,
      lat: location?.latitude,
      lon: location?.longitude,
      direction: direction ?? 0.0,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    mqtt.publishJson('tak/$roomId/player/$clientId', evt.toJson());
  }

  void publishPlayerDelete(String name) {
    final evt = NetPlayerEvent(
      op: 'delete',
      name: name,
      direction: 0.0,
      ts: DateTime.now().millisecondsSinceEpoch,
    );
    mqtt.publishJson('tak/$roomId/player/$clientId', evt.toJson());
  }
  
  
  // ---------- INCOMING (apply to remote state) ----------

  void _handle(String topic, String payload) {
    final parts = topic.split('/');
    payload = payload.trimLeft();
    if (payload.startsWith('flutter:')) {
      payload = payload.substring('flutter:'.length).trimLeft();
    }

    // tak/<room>/<kind>/<sender>
    if (parts.length != 4 || parts[0] != 'tak' || parts[1] != roomId) return;

    final kind = parts[2];
    final sender = parts[3];

    // Ignore our own messages
    if (sender == clientId) return;

    if (kind == 'marker') {
      final evt = NetMarkerEvent.fromJson(payload);

      if (evt.op == 'delete') {
        remoteMarkers.remove(evt.id);
      } else if (evt.op == 'upsert' && evt.lat != null && evt.lon != null && evt.name != null) {
        remoteMarkers[evt.id] = Point(
          id: evt.id,
          location: LatLng(evt.lat!, evt.lon!),
          name: evt.name!,
        );
      }
      _changed.add(null);
      return;
    }

    if (kind == 'stroke') {
      final m = _tryDecodeJson(topic, payload);
      if (m == null) return;
      final chunk = NetStrokeChunk.fromJson(payload);
      if (chunk.op != 'stroke') return;

      final stroke = remoteStrokes.putIfAbsent(
        chunk.id,
        () => RemoteStroke(
          id: chunk.id,
          color: hexToColor(chunk.color),
          width: chunk.width,
          isEraser: chunk.eraser,
        ),
      );

      stroke.points.addAll(chunk.toLatLngs());

      _changed.add(null);
      return;
    }

    if (kind == 'player') {
      final m = _tryDecodeJson(topic, payload);
      if (m == null) return;

      final evt = NetPlayerEvent(
        op: m['op'] as String,
        name: (m['name'] as String?) ?? '',
        direction: ((m['direction'] as num?) ?? 0).toDouble(),
        lat: (m['lat'] as num?)?.toDouble(),
        lon: (m['lon'] as num?)?.toDouble(),
        ts: ((m['ts'] as num?) ?? 0).toInt(),
      );

      if (evt.op == 'delete') {
        debugPrint('Removing player ${evt.name}');
        remotePlayers.remove(evt.name);
      } else if (evt.op == 'upsert' && evt.name.isNotEmpty && evt.lat != null && evt.lon != null) {
        _lastSeen[evt.name] = DateTime.now().millisecondsSinceEpoch;
        remotePlayers[evt.name] = RemotePlayer(
          name: evt.name,
          color: Colors.primaries[evt.name.hashCode % Colors.primaries.length], // assign color based on name hash
          location: LatLng(evt.lat!, evt.lon!),
          direction: evt.direction,
        );
      }
      _changed.add(null);
      return;
    } 

    if (kind == 'sos') {
      final m = _tryDecodeJson(topic, payload);
      if (m == null) return;

      final evt = NetSOSEvent(
        id: (m['id'] as String?) ?? sender,
        username: (m['username'] as String?) ?? '',
        ts: ((m['ts'] as num?) ?? 0).toInt(),
      );

      if (evt.username.isNotEmpty) {
        playNotifAndShowHello('Some idiot (${evt.username}) almost die, help him');
      }
    }
  }
}