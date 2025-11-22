import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StatusWidget extends StatelessWidget {
  final double lat;
  final double lon;
  final double altitude;
  final bool gpsConnected;
  const StatusWidget({super.key, required this.lat, required this.lon, required this.altitude, required this.gpsConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      height: 75,
      decoration: BoxDecoration(
        color: const Color.fromARGB(203, 0, 0, 0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // GPS Signal Status will be at the top right corner of the container
          Positioned(top: 4, right: 8, child: GPSSignalStatus(gpsConnected: gpsConnected)),
          // User stats will be at the top left corner of the container
          Positioned(top: 8, left: 8, child: UserStats(username: 'User123', teamName: 'Team Alpha')),
          // GPS stats will be at the bottom left corner of the container
          Positioned(bottom: 8, left: 8, child: GPSStats(latitude: lat, longitude: lon, altitude: altitude)),
        ],
      ),
    );
  }
}

class GPSSignalStatus extends StatefulWidget {
  final bool gpsConnected;
  const GPSSignalStatus({super.key, required this.gpsConnected});

  @override
  State<GPSSignalStatus> createState() => _GPSSignalStatusState();
}

class _GPSSignalStatusState extends State<GPSSignalStatus> {
  late bool _gpsConnected;

  void updateGPSSignalStatus(bool status) {
    setState(() {
      _gpsConnected = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _gpsConnected = widget.gpsConnected;
  }

  @override
  void didUpdateWidget(covariant GPSSignalStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gpsConnected != widget.gpsConnected) {
      setState(() {
        _gpsConnected = widget.gpsConnected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String assetPath = _gpsConnected
        ? 'assets/icons/gps_connected.svg'
        : 'assets/icons/gps_disconnected.svg';
    return SvgPicture.asset(
      assetPath,
      width: 32,
      height: 32,
    );
  }
}

// User stats: Username, Team name
// GPS stats: Latitude, Longitude, Altitude

class UserStats extends StatelessWidget {
  final String username;
  final String teamName;

  const UserStats({
    super.key,
    required this.username,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          username,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.0),
        ),
        Text(
          teamName,
          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.0),
        ),
      ],
    );
  }
}

class GPSStats extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double altitude;

  const GPSStats({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  @override
  State<GPSStats> createState() => _GPSStatsState();
}

class _GPSStatsState extends State<GPSStats> {
  @override
  Widget build(BuildContext context) {
    // <Latitude>, <Longitude>
    // <Altitude>

    int altitudeRounded = widget.altitude.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.0),
        ),
        Text(
          '$altitudeRounded m ASL',
          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.0),
        ),
      ],
    );
  }
}