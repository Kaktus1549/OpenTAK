import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatefulWidget {
  final void Function()? onTap;
  final void Function()? onTap2;
  final bool slidingPanelUp;
  final double longitude;
  final double latitude;
  const MapWidget({super.key, required this.onTap, required this.slidingPanelUp, required this.onTap2, required this.latitude, required this.longitude});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  double mapZoomLevel = 15.0;
  late double mapCenterLatitude;
  late double mapCenterLongitude;

  @override
  void initState() {
    super.initState();
    mapCenterLatitude = widget.latitude;
    mapCenterLongitude = widget.longitude;
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
    // assets/images/Mapa.png is a placeholder for the map image
    return GestureDetector(
      onTap: _handleTap,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(mapCenterLatitude, mapCenterLongitude), // Center the map over current coords
          initialZoom: mapZoomLevel,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            tileProvider: NetworkTileProvider(), // místo BuiltInMapCachingProvider
          )
        ],
      ),
    );
  }
}