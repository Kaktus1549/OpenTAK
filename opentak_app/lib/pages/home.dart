import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:opentak_app/Utils/_mqtt.dart';
import 'package:opentak_app/widgets/_controlbuttons.dart';
import 'package:opentak_app/widgets/_sosbutton.dart';
import 'package:opentak_app/widgets/_maps.dart';
import 'package:opentak_app/widgets/_statuswidget.dart';
import 'package:opentak_app/widgets/_sliding_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:opentak_app/Utils/_location.dart';
import 'package:opentak_app/models/enums/_nav_status.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'package:opentak_app/db/app_database.dart';
import 'package:opentak_app/realtime/_realtime_sync.dart';
import 'package:opentak_app/main.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';

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
  double heading = 0.0;
  String username = 'N/A';

  late final TakRealtimeSync _rt;

  StreamSubscription<CompassEvent>? _headingSub;
  double? _smoothedHeading;

  static const _smoothingFactor = 0.12;
  static const _unlockThresholdDeg = 3.0;
  static const _relockDiffDeg = 1.0;
  static const _relockTimeout = Duration(milliseconds: 500);

  bool _headingLocked = true;
  DateTime _lastMovementTime = DateTime.fromMillisecondsSinceEpoch(0);


  final PanelController panelController = PanelController();
  StreamSubscription<Position>? _positionStreamSubscription;

  NavigationStates navigationState = NavigationStates.decentred;
  void _updateNavigationState(NavigationStates newState) {
    setState(() {
      navigationState = newState;
    });
  }

  @override
  void initState() {
    super.initState();
    _rt = context.read<TakRealtimeSync>();
    _startListeningToLocation();
    _startHeadingUpdates();
    _loadUsername();
    final db = context.read<AppDatabase>();

    // Check if MQTT is connected and if not try to reconnect
    OpenTAKMQTTClient client = context.read<OpenTAKMQTTClient>();
    if (!client.isTAKConnected()) {
      final mqttInfoFuture = Helper.getMQTTBrokerTokenAndUsername(db: db);
      final deviceIdFuture = Helper.getId();
      Future.wait([mqttInfoFuture, deviceIdFuture]).then((results) {
        final mqttInfo = results[0] as List<String>;
        final deviceId = results[1] as String;
        if (mqttInfo[1].isEmpty) {
          // No valid token, do nothing
          return;
        }
        String mqttUrl = mqttInfo[0];
        String token = mqttInfo[1];
        String mqttUsername = mqttInfo[2];

        client.connect(brokerHost: mqttUrl, password: token, clientId: '$mqttUsername-$deviceId');
        // Wait for the client to connect before starting the realtime sync
        Timer.periodic(const Duration(seconds: 2), (timer) {
          if (client.isTAKConnected()) {
            _rt.reset(client, 'default', '$mqttUsername-$deviceId');
            timer.cancel();
          }
        });
      });
    }

    db.getUsername().then((name) {
      if (mounted) {
        setState(() {
          username = name ?? 'N/A';
        });
        _rt.startHeartbeat(name ?? 'N/A', () => LatLng(lat, lon), () => heading);
      }
    });
  }

  Future<void> _loadUsername() async {
    final name = await context.read<AppDatabase>().getUsername() ?? 'N/A';
    if (mounted) {
      setState(() {
        username = name;
      });
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _headingSub?.cancel();
    _rt.dispose();
    super.dispose();
  }
  
  void _retryLocationLater() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _startListeningToLocation();
      }
    });
  }

  void _startHeadingUpdates() {
    _headingSub = FlutterCompass.events!.listen((event) {
      final dir = event.heading;
      if (dir == null) return;

      _updateSmoothedHeading(dir);
    });
  }

  void _updateSmoothedHeading(double newHeading) {
    newHeading = _normalizeAngle(newHeading);

    if (_smoothedHeading == null) {
      _smoothedHeading = newHeading;
      _headingLocked = true;

      setState(() {
        heading = newHeading;
      });
      return;
    }

    final sensorDiff = _angleDiff(_smoothedHeading!, newHeading).abs();


    if (_headingLocked) {
      if (sensorDiff < _unlockThresholdDeg) {
        return;
      }

      _headingLocked = false;
      _lastMovementTime = DateTime.now();
    }

    final diff = _angleDiff(_smoothedHeading!, newHeading);
    _smoothedHeading = _normalizeAngle(
      _smoothedHeading! + diff * _smoothingFactor,
    );

    _lastMovementTime = DateTime.now();

    setState(() {
      heading = _smoothedHeading!;
    });

    final diffToSensor = _angleDiff(_smoothedHeading!, newHeading).abs();
    final stillForLongEnough =
        DateTime.now().difference(_lastMovementTime) > _relockTimeout;

    if (diffToSensor < _relockDiffDeg && stillForLongEnough) {
      _headingLocked = true;
    }
  }

  double _normalizeAngle(double angle) {
    angle = angle % 360;
    if (angle < 0) angle += 360;
    return angle;
  }

  double _angleDiff(double from, double to) {
    double diff = (to - from + 540) % 360 - 180;
    return diff;
  }

  Future<void> _startListeningToLocation() async {
    try {
      await GeolocationUtils.ensurePermissions();

      final locationSettings = Platform.isIOS
        ? AppleSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            activityType: ActivityType.otherNavigation,
            distanceFilter: 0,
            pauseLocationUpdatesAutomatically: false,
          )
        : AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 1),
          );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        setState(() {
          lat = position.latitude;
          lon = position.longitude;
          altitude = position.altitude;
          gpsConnected = true;
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
            centered: navigationState == NavigationStates.centred,
            followHeading: navigationState == NavigationStates.heading,
            heading: heading,
            gpsConnected: gpsConnected,
            altitude: altitude,
            username: username,
          ),
          Positioned(
            top: 58,
            right: 16,
            child: ControlButtonsContainer(
              currentState: navigationState,
              navigationUpdate: _updateNavigationState,
            ),
          ),
          Positioned(
            top: 184,
            right: 16,
            child: SOSButton(rt: _rt, username: username),
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
              username: username,
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