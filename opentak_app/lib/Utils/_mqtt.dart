import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class CursorUpdate {
  final String targetId;
  final String clientId;
  final double lat;
  final double lon;
  final double? heading; // optional
  final int ts; // unix ms

  CursorUpdate({
    required this.targetId,
    required this.clientId,
    required this.lat,
    required this.lon,
    required this.ts,
    this.heading,
  });

  factory CursorUpdate.fromJson(String targetId, String clientId, String jsonStr) {
    final m = jsonDecode(jsonStr) as Map<String, dynamic>;
    return CursorUpdate(
      targetId: targetId,
      clientId: clientId,
      lat: (m['lat'] as num).toDouble(),
      lon: (m['lon'] as num).toDouble(),
      heading: m['heading'] == null ? null : (m['heading'] as num).toDouble(),
      ts: (m['ts'] as num).toInt(),
    );
  }

  String toJson() => jsonEncode({
        'lat': lat,
        'lon': lon,
        if (heading != null) 'heading': heading,
        'ts': ts,
      });
}

class OpenTAKMQTTClient {
  MqttServerClient? _client;

  final _cursorController = StreamController<CursorUpdate>.broadcast();
  Stream<CursorUpdate> get cursorUpdates => _cursorController.stream;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  /// brokerHost examples:
  /// - "mqtt.kaktusgame.eu" (tcp 1883 by default)
  /// - "10.0.0.5"
  Future<void> connect({
    required String brokerHost,
    int port = 1883,
    required String clientId,
    String? username,
    String? password,
    bool useTLS = false,
    bool cleanSession = true,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final c = MqttServerClient(brokerHost, clientId);
    _client = c;

    c.port = port;
    c.secure = useTLS;
    c.setProtocolV311();
    c.keepAlivePeriod = 20;
    c.logging(on: false);

    c.onDisconnected = _onDisconnected;
    c.onConnected = _onConnected;

    final conn = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean() // clean session
        .withWillQos(MqttQos.atLeastOnce);

    c.connectionMessage = cleanSession ? conn : conn.withWillRetain();

    try {
      await c.connect(username, password).timeout(timeout);
    } catch (e) {
      c.disconnect();
      rethrow;
    }

    if (!isConnected) {
      throw Exception('MQTT connect failed: ${c.connectionStatus}');
    }

    // Listen for incoming messages
    c.updates?.listen(_handleMessages);
  }

  void disconnect() {
    _client?.disconnect();
  }

  /// Subscribe to all cursor updates for a target
  void subscribeToTargetCursors(String targetId) {
    final topic = 'tak/$targetId/+/cursor';
    _client?.subscribe(topic, MqttQos.atLeastOnce);
  }

  /// Publish your cursor for a target
  void publishCursor({
    required String targetId,
    required String clientId,
    required double lat,
    required double lon,
    double? heading,
    int? ts,
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    final c = _client;
    if (c == null || !isConnected) return;

    final update = CursorUpdate(
      targetId: targetId,
      clientId: clientId,
      lat: lat,
      lon: lon,
      heading: heading,
      ts: ts ?? DateTime.now().millisecondsSinceEpoch,
    );

    final builder = MqttClientPayloadBuilder()
      ..addString(update.toJson());

    final topic = 'tak/$targetId/$clientId/cursor';
    c.publishMessage(topic, qos, builder.payload!, retain: retain);
  }

  // ---- internals ----

  void _handleMessages(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final e in events) {
      final topic = e.topic; // tak/<targetId>/<clientId>/cursor
      final msg = e.payload as MqttPublishMessage;

      final payload =
          MqttPublishPayload.bytesToStringAsString(msg.payload.message);

      final parts = topic.split('/');
      if (parts.length == 4 && parts[0] == 'tak' && parts[3] == 'cursor') {
        final targetId = parts[1];
        final clientId = parts[2];
        try {
          final update = CursorUpdate.fromJson(targetId, clientId, payload);
          _cursorController.add(update);
        } catch (_) {
          // ignore bad payloads
        }
      }
    }
  }

  void _onConnected() {}
  void _onDisconnected() {}
}