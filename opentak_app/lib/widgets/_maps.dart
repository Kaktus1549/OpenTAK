import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:opentak_app/db/app_database.dart';

import 'package:opentak_app/models/_custom_map_overlay.dart';
import 'package:provider/provider.dart';
import 'package:opentak_app/save_data/_file_save.dart';
import 'package:opentak_app/drawing/_paint_notifiers.dart';
import 'package:opentak_app/drawing/_painter.dart';
import 'package:opentak_app/points/_point.dart';
import 'package:opentak_app/points/_pointMarker.dart';
import 'package:opentak_app/realtime/_realtime_sync.dart';
import 'package:opentak_app/Utils/_mqtt.dart';

import 'package:opentak_app/widgets/_rotatingplayer.dart';


class MapWidget extends StatefulWidget {
  final void Function()? onTap;
  final void Function()? onTap2;
  final bool slidingPanelUp;
  final double longitude;
  final double latitude;
  final bool centered;
  final bool followHeading;
  final double heading;
  final bool gpsConnected;
  final double altitude;
  final String username;

  const MapWidget({
    super.key,
    required this.onTap,
    required this.slidingPanelUp,
    required this.onTap2,
    required this.latitude,
    required this.longitude,
    required this.centered,
    required this.followHeading,
    required this.heading,
    required this.gpsConnected,
    required this.altitude,
    required this.username,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  List<String> _downloadedMaps = [];
  late FMTCTileProvider _tileProvider = FMTCTileProvider(
    stores: const {},
    otherStoresStrategy: BrowseStoreStrategy.read,
  );

  FloorOverlay firstFloor = FloorOverlay(assetPath: "assets/test/testMap.svg", topLeft: LatLng(50.133630753827774, 14.510051097636836), bottomRight: LatLng(50.133597737787255, 14.51021080053696), bottomLeft: LatLng(50.13357448862208, 14.510064591766461), floorNumber: 1, id: 1, buildingId: 1);
  FloorOverlay secondFloor = FloorOverlay(assetPath: "assets/test/m.jpg", topLeft: LatLng(50.133630753827774, 14.510051097636836), bottomRight: LatLng(50.133597737787255, 14.51021080053696), bottomLeft: LatLng(50.13357448862208, 14.510064591766461), floorNumber: 2, id: 2, buildingId: 1);

  late CustomMapOverlay customOverlay;
  late AppDatabase database;
  List<CustomMapOverlay> buildingOverlays = [];
  
  List<RotatedOverlayImage> _overlayImages = [];
  LatLng? _lastOverlayPosition;
  bool _isLoadingOverlays = false;
  
  double mapZoomLevel = 15.0;
  late bool gpsConnected;
  bool lastGPSStatus = false;

  late bool _drawMode;
  bool _mapReady = false;

  late DrawingController drawing;

  final List<Point> points = [];
  late String? selectedPointName;

  TakRealtimeSync? _rt;
  StreamSubscription? _rtSub;

  late OpenTAKMQTTClient mqtt;
  late String deviceId;
  final String roomId = "default";


  void _setSelectedPoint(String? name) {
    setState(() {
      selectedPointName = name;
    });
  }

  Future<void> _loadDownloadedMaps() async {
    _downloadedMaps = await database.getDownloadedMaps();
    setState(() {
      _tileProvider = FMTCTileProvider(
        stores: {
          for (final id in _downloadedMaps)
            id.split(':')[0]: BrowseStoreStrategy.readUpdateCreate,
        },
        otherStoresStrategy: null,
      );
    });
  }
  
  Future<void> _reloadBuildingOverlays(LatLng position) async {
    const minDistanceMeters = 10.0;
    if (_lastOverlayPosition != null) {
      final dist = const Distance()(position, _lastOverlayPosition!);
      if (dist < minDistanceMeters) {
        return;
      }
    }


    if (_isLoadingOverlays) return;
    _isLoadingOverlays = true;

    final db = context.read<AppDatabase>();
    final storage = context.read<MapStorage>();


    final nearbyBuildings =
    await db.getOverlaysNearPosition(position, radiusKm: 0.1);

    final newImages = await CustomMapOverlayUtils.renderActiveOverlays(
      nearbyBuildings,
      widget.altitude,
      storage,
    );


    if (!mounted) return;

    setState(() {
      _overlayImages = newImages;
      buildingOverlays = nearbyBuildings; 
      _lastOverlayPosition = position;
      _isLoadingOverlays = false;
    });

  }
  
  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (_drawMode) return;
    if (selectedPointName != null) {
      setState(() {
        points.add(Point(location: point, name: selectedPointName!));
        _rt?.publishMarkerUpsert(Point(location: point, name: selectedPointName!));
      });
      return;
    }
    if (widget.onTap != null && !widget.slidingPanelUp) {
      widget.onTap!();
      return;
    }
    if (widget.onTap2 != null && widget.slidingPanelUp) {
      widget.onTap2!();
      return;
    }
  }

  void setDrawMode(bool value) {
    setState(() => _drawMode = value);
  }

  void _safeMapAction(VoidCallback fn) {
    if (!_mapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_mapReady) return;
        fn();
      });
      return;
    }
    fn();
  }
  
  MapStroke toMapStroke(RemoteStroke rs) {
    final s = MapStroke(color: rs.color, width: rs.width, isEraser: rs.isEraser);
    s.points.addAll(rs.points);
    return s;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _mapReady = true);
    });

    
    selectedPointName = context.read<SelectedPointNotifier>().name;
    context.read<SelectedPointNotifier>().addListener(() {
      _setSelectedPoint(context.read<SelectedPointNotifier>().name);
    });

    MapStrokeController strokeController = context.read<MapStrokeController>();
    _drawMode = strokeController.isDrawingEnabled;
    strokeController.addListener(() {
      setDrawMode(strokeController.isDrawingEnabled);
    });

    database = context.read<AppDatabase>();
    customOverlay = CustomMapOverlay(floorList: [ firstFloor, secondFloor ], floorHeight: 3.0, baseHeight: 0.0, buildingID: 1, name: "Test Building");
    _loadDownloadedMaps();

    mqtt = context.read<OpenTAKMQTTClient>();
    deviceId = context.read<String>();

    _rt = TakRealtimeSync(mqtt: mqtt, roomId: roomId, clientId: deviceId)..start();
    _rtSub = _rt!.changed.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _rtSub?.cancel();
    _rt?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentPos = LatLng(widget.latitude, widget.longitude);


    if (widget.gpsConnected == true && lastGPSStatus == false) {
      _safeMapAction(() {_mapController.move(currentPos, mapZoomLevel);});
      lastGPSStatus = true;
      _safeMapAction(() {_reloadBuildingOverlays(currentPos);});
      return;
    }

    // Send update about player position to other clients
    if (widget.gpsConnected) {
      _rt?.publishPlayerUpdate(widget.username, currentPos, widget.heading);
    }

    if ((widget.centered || widget.followHeading)) {
      double heading = 0.0;
      if (widget.followHeading) {
        heading = -widget.heading;
      }
      final currentZoom = _mapController.camera.zoom;
      _safeMapAction(() {
        _mapController.move(currentPos, currentZoom);
        _mapController.rotate(heading);
        _reloadBuildingOverlays(currentPos);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    drawing = context.watch<DrawingController>();
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.latitude, widget.longitude),
            initialZoom: mapZoomLevel,
            onTap: (tapPosition, point) => _handleTap(tapPosition, point),

            interactionOptions: InteractionOptions(
              flags: _drawMode
                  ? InteractiveFlag.none
                  : ((widget.centered || widget.followHeading)
                      ? (InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom)
                      : InteractiveFlag.all),
            ),
            onPositionChanged: (pos, hasGesture) {
              if (hasGesture && !_drawMode && !(widget.centered || widget.followHeading)) {
                _reloadBuildingOverlays(pos.center);
              }
            },
          ),
          children: [
            TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'OpenTAK',
            tileProvider: _tileProvider,
          ),
            if (_overlayImages.isNotEmpty) OverlayImageLayer(overlayImages: _overlayImages),
            StreamBuilder(
              stream: _mapController.mapEventStream,
              builder: (_, __) {
                final zoom = _mapController.camera.zoom;
                final size = sizeForZoom(zoom);
                final showDeleteButton = zoom >= 15.0;

                return MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(widget.latitude, widget.longitude),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 36,
                      ),
                    ),

                    ...points.map((point) => Marker(
                      width: 40,
                      height: 40,
                      point: point.location,
                      alignment: Alignment.center,
                      child: DeletablePointMarker(
                        point: point,
                        iconSize: size,
                        showDeleteButton: showDeleteButton,
                        onDelete: () {
                        setState(() {
                          points.removeWhere((x) => x.id == point.id);
                        });
                        _rt?.publishMarkerDelete(point.id);
                      },
                      ),
                      )),

                    ...?_rt?.remoteMarkers.values.map((p) => Marker(
                      width: 40,
                      height: 40,
                      point: p.location,
                      child: DeletablePointMarker(
                        point: p, 
                        onDelete: () {}, 
                        iconSize: size, 
                        showDeleteButton: showDeleteButton
                        )
                    )),

                    ...?_rt?.remotePlayers.values.map((p) => Marker(
                      width: 120,   
                      height: 80,
                      point: p.location,
                      alignment: Alignment.topCenter,
                      child: RotatingPlayer(
                        name: p.name,
                        color: p.color,
                        directionDeg: p.direction,
                        size: 34,
                      ),
                    )),
                  ],
                );
              },
            ),  
          ],
        ),

        if (_mapReady)
          StreamBuilder(
            stream: _mapController.mapEventStream,
            builder: (_, _) => Positioned.fill(
              child: IgnorePointer(
                ignoring: !_drawMode,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) {
                    final ll = _mapController.camera.screenOffsetToLatLng(d.localPosition);
                    MapStrokeController strokeController = context.read<MapStrokeController>();
                    drawing.startStroke(
                      color: strokeController.currentColor,
                      width: strokeController.currentWidth,      
                      eraser: strokeController.isEraser,
                    );
                    _rt?.beginStroke(drawing.current!);
                    drawing.addPoint(ll);
                  },
                  onPanUpdate: (d) {
                    final ll = _mapController.camera.screenOffsetToLatLng(d.localPosition);
                    drawing.addPoint(ll);
                    _rt?.addStrokePoint(ll);
                  },
                  onPanEnd: (_) {
                    drawing.endStroke();
                    _rt?.endStroke();
                  },
                  child: AnimatedBuilder(
                    animation: drawing,
                    builder: (_, _) => CustomPaint(
                      painter: MapStrokesPainter(
                        camera: _mapController.camera,
                        strokes: [
                          ...drawing.strokes,
                          ...(_rt?.remoteStrokes.values.map(toMapStroke) ?? const Iterable.empty()),
                        ],
                        current: drawing.current,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}