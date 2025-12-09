import 'package:flutter/material.dart';
import 'package:opentak_app/pages/home.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:opentak_app/db/app_database.dart';
import 'package:provider/provider.dart';
import 'package:opentak_app/save_data/_file_save.dart';

import 'package:opentak_app/models/_custom_map_overlay.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FMTCObjectBoxBackend().initialise();
  final database = AppDatabase();
  final storage = MapStorage();

  await FMTCStore('mapStore').manage.create();

  await Testing.testFunc(storage, database);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<MapStorage>.value(value: storage),
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


class Testing{
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
}