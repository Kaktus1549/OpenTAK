import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:opentak_app/pages/widgets/_controlbuttons.dart';
import 'package:opentak_app/pages/widgets/_sosbutton.dart';
import 'package:opentak_app/pages/widgets/_maps.dart';
import 'package:opentak_app/pages/widgets/_statuswidget.dart';
import 'package:opentak_app/pages/widgets/_sliding_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:opentak_app/pages/Utils/_location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool navbarVisible = true;
  bool slidingPanelUp = false;
  bool draggable = false;
  bool gpsConnected = false;

  double lat = 0.0;
  double lon = 0.0;
  double altitude = 0.0;

  final PanelController panelController = PanelController();
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
  void _retryLocationLater() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _startListeningToLocation();
      }
    });
  }


  Future<void> _startListeningToLocation() async {
    try {
      await GeolocationUtils.ensurePermissions();

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
      );

      // Mark as connected immediately when stream starts
      setState(() => gpsConnected = true);

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        setState(() {
          lat = position.latitude;
          lon = position.longitude;
          altitude = position.altitude;
        });
      }, onError: (error) {
        debugPrint('Location stream error: $error');
        setState(() => gpsConnected = false);
        _retryLocationLater();
      });
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
      setState(() => gpsConnected = false);
      _retryLocationLater();
    }
}

  @override
  Widget build(BuildContext context) {
    const double bottomBarHeight = 80;

    void toggleBottomBar() {
      setState(() => navbarVisible = !navbarVisible);
    }

    void slidePanelDown() {
      panelController.close();
      FocusScope.of(context).unfocus();
      setState(() {
        slidingPanelUp = false;
        draggable = false;
      });
    }

    void slidePanelUp() {
      panelController.open();
      setState(() {
        slidingPanelUp = true;
        draggable = true;
      });
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          MapWidget(
            onTap: toggleBottomBar,
            slidingPanelUp: slidingPanelUp,
            onTap2: slidePanelDown,
            latitude: lat,
            longitude: lon,
          ),
          Positioned(
            top: 58,
            right: 16,
            child: const ControlButtonsContainer(),
          ),
          Positioned(
            top: 184,
            right: 16,
            child: const SOSButton(),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            right: 16,
            bottom: navbarVisible ? bottomBarHeight + 44 : 24,
            child: StatusWidget(
              lat: lat,
              lon: lon,
              altitude: altitude,
              gpsConnected: gpsConnected,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlidingPanelWidget(
              navbarVisible: navbarVisible,
              panelController: panelController,
              slidingPanelUp: slidingPanelUp,
              onTap: slidePanelUp,
              onClose: slidePanelDown,
              draggable: draggable,
            ),
          ),
        ],
      ),
    );
  }
}