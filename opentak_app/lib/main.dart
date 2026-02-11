import 'package:flutter/material.dart';
import 'package:opentak_app/pages/home.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:opentak_app/db/app_database.dart';
import 'package:provider/provider.dart';
import 'package:opentak_app/save_data/_file_save.dart';
import 'package:opentak_app/settings/_predefined_maps.dart';
import 'package:opentak_app/models/_custom_map_overlay.dart';
import 'package:latlong2/latlong.dart';
import 'package:opentak_app/drawing/_paint_notifiers.dart';
import 'package:opentak_app/points/_point.dart';
import 'package:opentak_app/Utils/_web.dart';
import 'package:opentak_app/Utils/_mqtt.dart';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:opentak_app/pages/onboarding.dart';
import 'package:opentak_app/pages/register.dart';
import 'package:opentak_app/pages/login.dart';
import 'package:opentak_app/realtime/_realtime_sync.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';


Future<void> initLocalNotifications(FlutterLocalNotificationsPlugin fln) async {
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(
    iOS: iosInit,
    android: androidInit,
  );

  await fln.initialize(settings: initSettings);


  // iOS explicit permission request (safe to call)
  await fln
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fln = FlutterLocalNotificationsPlugin();
  await initLocalNotifications(fln);

  await FMTCObjectBoxBackend().initialise();
  final database = AppDatabase();
  final storage = MapStorage();

  late final OpenTAKMQTTClient mqttClient = OpenTAKMQTTClient();
  late final String? deviceId;
  late final Map<String, MapDownloadState> downloads;
  late final MapStrokeController strokeController;

  late final TakRealtimeSync rt = TakRealtimeSync(mqtt: mqttClient, roomId: "default", clientId: deviceId ?? "unknown-device");

  late Widget homeWidget;

  bool? onBoarded = await database.isOnBoarded();
  String? authToken = await database.getAuthToken();
  String? username = await database.getUsername();
  deviceId = await Helper.getId();

  void setHomeWidget(Widget widget) {
    homeWidget = widget;
  }


  if (onBoarded == false) {
    homeWidget = const OnBoardingScreen();
  } else if (authToken == null && username != null) {
    homeWidget = const Login();
  } else if (authToken == null && username == null) {
    homeWidget = const Register();
  }
  else {
    // Try to login, otherwise go to login screen
    homeWidget = HomePage();

    await Helper.testFunc(storage, database);

    final mqttInfo = await Helper.getMQTTBrokerTokenAndUsername(db: database, setHomeWidget: setHomeWidget);
    if (mqttInfo[1].isEmpty) {
      // No valid token, go to login screen
      homeWidget = const Login();
    }
    else{
      String mqttUrl = mqttInfo[0];
      String token = mqttInfo[1];
      String mqttUsername = mqttInfo[2];

      await mqttClient.connect(brokerHost: mqttUrl, password: token, clientId: '$mqttUsername-$deviceId');

      rt.setMqttClient(mqttClient);
    }
  }

  String? serverUrl = await database.getServerUrl();
  String? token = await database.getAuthToken();

  final host = OpenTAKHTTPClient.normalizeHost(serverUrl ?? "tak.kaktusgame.eu");
  final httpClient = OpenTAKHTTPClient(serverUrl: host, authToken: token ?? "");

  downloads = {};
  await FMTCStore('mapStore').manage.create();
  strokeController = MapStrokeController(currentColor: Colors.red, currentWidth: 4.0, isEraser: false);

  runApp(
    MultiProvider(
      providers: [
        Provider<String>.value(value: deviceId ?? "unknown-device"),
        Provider<OpenTAKMQTTClient>.value(value: mqttClient),
        Provider<OpenTAKHTTPClient>.value(value: httpClient),
        Provider<TakRealtimeSync>.value(value: rt),
        Provider<AppDatabase>.value(value: database),
        Provider<MapStorage>.value(value: storage),
        Provider<Map<String, MapDownloadState>>.value(value: downloads),
        ChangeNotifierProvider(create: (_) => DrawingController()),
        ChangeNotifierProvider<MapStrokeController>.value(value: strokeController),
        ChangeNotifierProvider<SelectedPointNotifier>.value(value: SelectedPointNotifier()),
      ],
      child: OpenTAKApp(home: homeWidget),
    ),
  );
}

class OpenTAKApp extends StatelessWidget {
  final Widget? home;
  const OpenTAKApp({super.key, this.home});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }
}


class Helper{
  static Future<void> testFunc(MapStorage storage, AppDatabase database) async {
    // Create two floors, one wiht assets/test/testMap.svg and second with assets/test/m.jpg. Then create a building with these two floors.

    String assetPath1 = await storage.writeAsset('assets/test/testMap.svg', 'testMap.svg').then((file) => file.path);
    String assetPath2 = await storage.writeAsset('assets/test/m.jpg', 'm.jpg').then((file) => file.path);

    FloorOverlay firstFloor = FloorOverlay(assetPath: assetPath1, topLeft: LatLng(50.133630753827774, 14.510051097636836), bottomRight: LatLng(50.133597737787255, 14.51021080053696), bottomLeft: LatLng(50.13357448862208, 14.510064591766461), floorNumber: 1, id: 1, buildingId: 1);
    FloorOverlay secondFloor = FloorOverlay(assetPath: assetPath2, topLeft: LatLng(50.133630753827774, 14.510051097636836), bottomRight: LatLng(50.133597737787255, 14.51021080053696), bottomLeft: LatLng(50.13357448862208, 14.510064591766461), floorNumber: 2, id: 2, buildingId: 1);

    CustomMapOverlay customOverlay = CustomMapOverlay(floorList: [ firstFloor, secondFloor ], floorHeight: 3.0, baseHeight: 0.0, buildingID: 1, name: "Test Building");


    // Save to database and file storage
    await database.insertBuildingWithFloors(customOverlay);
  }

  static Future<String?> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      return AndroidId().getId(); // unique ID on Android
    }
    return null;
  }

  static Future<List<String>> getMQTTBrokerTokenAndUsername({required AppDatabase db, Function(Widget)? setHomeWidget}) async {
    String serverUrl = await db.getServerUrl() ?? "https://tak.kaktusgame.eu";
    String? token = await db.getAuthToken();
    String username = await db.getUsername() ?? "N/A";
    String mqttUrl;
    if (token == null) {
      throw Exception("No auth token found in database"); 
    }

    OpenTAKHTTPClient client = OpenTAKHTTPClient(serverUrl: serverUrl, authToken: token);
    try {
      // Test the token by making a simple authenticated request, e.g., fetching user profile
      final profile = await client.get('login');
      if (profile.statusCode == 200) {
      } else {
        if (profile.statusCode == 401) {
          // Token is invalid, clear it from database and go to login screen
          await db.clearAuthToken();
          if (setHomeWidget != null) {
            setHomeWidget(const Login());
          }
          return ["", "", ""];
        } else {
          throw Exception("Failed to validate token: ${profile.statusCode} ${profile.body}");
        }
      }

      mqttUrl = await client.getMQTTBrokerUrl();
    } 
    catch (e) {      
      throw Exception("Token validation failed: $e");
    }

    return [mqttUrl, token, username];
  }
}