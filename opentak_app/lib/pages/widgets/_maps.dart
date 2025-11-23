import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

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
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );
  double mapZoomLevel = 15.0;
  late bool gpsConnected;
  bool lastGPSStatus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gpsConnected == true){
      if (lastGPSStatus == false){
        // GPS just got connected, recenter the map
        _mapController.move(LatLng(widget.latitude, widget.longitude), mapZoomLevel);
        lastGPSStatus = true;
        return;
      }
    }
    // Whenever coordinates change, move the map center
    if ((widget.centered || widget.followHeading)) {
      if ((widget.latitude == oldWidget.latitude && widget.longitude == oldWidget.longitude) && widget.followHeading == false){
        return;
      }
      double heading = 0.0;
      if (widget.followHeading) {
        heading = -widget.heading;
      }
      _mapController.move(LatLng(widget.latitude, widget.longitude), mapZoomLevel);
      _mapController.rotate(heading);
    }
  }

  void _handleTap() {
    if (widget.onTap != null && !widget.slidingPanelUp) {
      widget.onTap!();
      return;
    }
    if (widget.onTap2 != null && widget.slidingPanelUp) {
      widget.onTap2!();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(widget.latitude, widget.longitude),
          initialZoom: mapZoomLevel,
          onTap: (tapPosition, point) => _handleTap(),
          // If a gesture moves the map while centered/followHeading is true, snap it back to the current coords.
          onPositionChanged: (pos, hasGesture) {
            if ((widget.centered || widget.followHeading) && hasGesture) {
              _mapController.move(LatLng(widget.latitude, widget.longitude), mapZoomLevel);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'OpenTAK',
            tileProvider: _tileProvider,
          ),
          MarkerLayer(
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
            ],
          ),
        ],
      );
  }
}