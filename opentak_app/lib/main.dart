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
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  final database = AppDatabase();
  final storage = MapStorage();

  OpenTAKMQTTClient mqttClient = OpenTAKMQTTClient();

  await Helper.testFunc(storage, database);

  final mqttInfo = await Helper.getMQTTBrokerTokenAndUsername(db: database);
  String mqttUrl = mqttInfo[0];
  String token = mqttInfo[1];
  String username = mqttInfo[2];

  String? deviceId = await Helper._getId();

  await mqttClient.connect(brokerHost: mqttUrl, password: token, clientId: '$username-$deviceId');


  Map<String, MapDownloadState> downloads = {};
  await FMTCStore('mapStore').manage.create();

  MapStrokeController strokeController = MapStrokeController(currentColor: Colors.red, currentWidth: 4.0, isEraser: false);

  runApp(
    MultiProvider(
      providers: [
        Provider<String>.value(value: deviceId ?? "unknown-device"),
        Provider<OpenTAKMQTTClient>.value(value: mqttClient),
        Provider<AppDatabase>.value(value: database),
        Provider<MapStorage>.value(value: storage),
        Provider<Map<String, MapDownloadState>>.value(value: downloads),
        ChangeNotifierProvider(create: (_) => DrawingController()),
        ChangeNotifierProvider<MapStrokeController>.value(value: strokeController),
        ChangeNotifierProvider<SelectedPointNotifier>.value(value: SelectedPointNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
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
    //Register and login a user using OpenTAKHTTPClient, then save the username to the database and print it out. Use username
    // "TestUser", "TestUser@example.com", "password123" as credentials and no secret code for registration.
    OpenTAKHTTPClient client = OpenTAKHTTPClient(serverUrl: "https://tak.kaktusgame.eu", authToken: "");
    try {
      await client.register("TestUser", "TestUser@example.com", "password123", "8a2b5b6d4c7ae22101bb9eca20d0d66e538a0fcdbf0ddc54b55886de4ffea712");
      String? token = await client.login("TestUser", "password123");
      if (token != null) {
        print("Login successful, token: $token");
        // Save the token to the database
            await database.insertOrUpdateUserSettings(username: "TestUser", email: "TestUser@example.com", authToken: token, serverUrl: "https://tak.kaktusgame.eu", refreshToken: "");
      } else {
        print("Login failed");
      }
    } catch (e) {
      print("Error during registration/login: $e");
      exit(1);
    }


    // Save to database and file storage
    await database.insertBuildingWithFloors(customOverlay);
  }

  static Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      return AndroidId().getId(); // unique ID on Android
    }
    return null;
  }

  static Future<List<String>> getMQTTBrokerTokenAndUsername({required AppDatabase db}) async {
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
        print("Token is valid. User profile: ${profile.body}");
      } else {
        if (profile.statusCode == 401) {
          // TODO: Force user to re-login and update token in database via UI
          String? token = await client.login("TestUser", "password123");
          if (token != null) {
            print("Re-login successful, new token: $token");
            // Save the new token to the database
            await db.insertOrUpdateUserSettings(username: "TestUser", email: "TestUser@example.com", authToken: token, serverUrl: "https://tak.kaktusgame.eu", refreshToken: "");
          } else {
            print("Re-login failed");
            throw Exception("Token validation failed and re-login failed");
          }
        } else {
          print("Unexpected response while validating token: ${profile.statusCode} - ${profile.body}");
        }
      }

      mqttUrl = await client.getMQTTBrokerUrl();
      print("MQTT Broker URL: $mqttUrl");
    } 
    catch (e) {      
      print("Error validating token: $e");
      throw Exception("Token validation failed: $e");
    }

    return [mqttUrl, token, username];
  }
}