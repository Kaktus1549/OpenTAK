import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:opentak_app/models/_custom_map_overlay.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

part 'app_database.g.dart';

class BuildingRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  RealColumn get floorHeight => real()();
  RealColumn get baseHeight => real()();

  // bounding box for fast spatial queries
  RealColumn get minLat => real()();
  RealColumn get maxLat => real()();
  RealColumn get minLng => real()();
  RealColumn get maxLng => real()();
}

class FloorOverlayRows extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get buildingId =>
      integer().references(BuildingRows, #id, onDelete: KeyAction.cascade)();

  TextColumn get assetPath => text()();

  RealColumn get topLeftLat => real()();
  RealColumn get topLeftLng => real()();
  RealColumn get bottomLeftLat => real()();
  RealColumn get bottomLeftLng => real()();
  RealColumn get bottomRightLat => real()();
  RealColumn get bottomRightLng => real()();

  IntColumn get floorNumber => integer()();
}

class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get email => text()();
  TextColumn get serverUrl => text()();
  TextColumn get authToken => text()();
  TextColumn get refreshToken => text()(); // For now its not implemented, but we can store it for later use
}

class DownloadedOfflineMaps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mapId => text()(); // e.g. "preset1" or "custom3"
  TextColumn get mapName => text()(); // e.g. "City Center Map"
}

@DriftDatabase(tables: [BuildingRows, FloorOverlayRows, UserSettings, DownloadedOfflineMaps])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'OpenTAKDb',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  // ---------- INSERT BUILDING + FLOORS ----------

  Future<int> insertBuildingWithFloors(CustomMapOverlay overlay) async {
    // compute bounds from all floor corners
    final coords = <LatLng>[];
    for (final f in overlay.floorList) {
      coords.addAll([f.topLeft, f.bottomLeft, f.bottomRight]);
    }

    final minLat =
        coords.map((c) => c.latitude).reduce((a, b) => a < b ? a : b);
    final maxLat =
        coords.map((c) => c.latitude).reduce((a, b) => a > b ? a : b);
    final minLng =
        coords.map((c) => c.longitude).reduce((a, b) => a < b ? a : b);
    final maxLng =
        coords.map((c) => c.longitude).reduce((a, b) => a > b ? a : b);

    return transaction(() async {
      final buildingCompanion = BuildingRowsCompanion.insert(
        name: overlay.name,
        floorHeight: overlay.floorHeight,
        baseHeight: overlay.baseHeight,
        minLat: minLat,
        maxLat: maxLat,
        minLng: minLng,
        maxLng: maxLng,
      );

      final buildingId =
          await into(buildingRows).insert(buildingCompanion);

      for (final f in overlay.floorList) {
        final floorCompanion = FloorOverlayRowsCompanion.insert(
          buildingId: buildingId,
          assetPath: f.assetPath,
          topLeftLat: f.topLeft.latitude,
          topLeftLng: f.topLeft.longitude,
          bottomLeftLat: f.bottomLeft.latitude,
          bottomLeftLng: f.bottomLeft.longitude,
          bottomRightLat: f.bottomRight.latitude,
          bottomRightLng: f.bottomRight.longitude,
          floorNumber: f.floorNumber,
        );
        await into(floorOverlayRows).insert(floorCompanion);
      }

      return buildingId;
    });
  }


  Future<void> deleteBuilding(int id) async {
    await (delete(buildingRows)..where((b) => b.id.equals(id))).go();
  }
  // ---------- LOAD ONE BUILDING + FLOORS ----------

  Future<CustomMapOverlay?> getBuilding(int id) async {
    final building = await (select(buildingRows)
          ..where((b) => b.id.equals(id)))
        .getSingleOrNull();

    if (building == null) return null;

    final floors = await (select(floorOverlayRows)
          ..where((f) => f.buildingId.equals(id))
          ..orderBy([(f) => OrderingTerm(expression: f.floorNumber)]))
        .get();

    final floorList = floors.map(_floorRowToDomain).toList();

    return CustomMapOverlay(
      buildingID: building.id,
      name: building.name,
      floorHeight: building.floorHeight,
      baseHeight: building.baseHeight,
      floorList: floorList,
    );
  }

  FloorOverlay _floorRowToDomain(FloorOverlayRow row) {
    return FloorOverlay(
      id: row.id,
      buildingId: row.buildingId,
      assetPath: row.assetPath,
      topLeft: LatLng(row.topLeftLat, row.topLeftLng),
      bottomLeft: LatLng(row.bottomLeftLat, row.bottomLeftLng),
      bottomRight: LatLng(row.bottomRightLat, row.bottomRightLng),
      floorNumber: row.floorNumber,
    );
  }
  // ---------- QUERY BUILDINGS NEAR POSITION ----------

  Future<List<CustomMapOverlay>> getOverlaysNearPosition(
    LatLng position, {
    double radiusKm = 25.0,
  }) async {
    // same bbox math as before
    const metersPerDegLat = 111320.0;
    final radiusMeters = radiusKm * 1000.0;
    final deltaLat = radiusMeters / metersPerDegLat;

    final latRad = position.latitude * math.pi / 180.0;
    final metersPerDegLng = metersPerDegLat * math.cos(latRad);
    final deltaLng = radiusMeters / metersPerDegLng;

    final minLat = position.latitude - deltaLat;
    final maxLat = position.latitude + deltaLat;
    final minLng = position.longitude - deltaLng;
    final maxLng = position.longitude + deltaLng;

    final query = select(buildingRows)
    ..where(
      (b) =>
          b.maxLat.isBiggerOrEqualValue(minLat) &
          b.minLat.isSmallerOrEqualValue(maxLat) &
          b.maxLng.isBiggerOrEqualValue(minLng) &
          b.minLng.isSmallerOrEqualValue(maxLng),
    );

    final buildings = await query.get();

    final result = <CustomMapOverlay>[];
    for (final b in buildings) {
      final floors = await (select(floorOverlayRows)
            ..where((f) => f.buildingId.equals(b.id))
            ..orderBy([(f) => OrderingTerm(expression: f.floorNumber)]))
          .get();

      final floorList = floors.map(_floorRowToDomain).toList();

      result.add(
        CustomMapOverlay(
          buildingID: b.id,
          name: b.name,
          floorHeight: b.floorHeight,
          baseHeight: b.baseHeight,
          floorList: floorList,
        ),
      );
    }

    return result;
  }

  // ---------- USER SETTINGS ---------- 

  Future<int> insertOrUpdateUserSettings({
    String? username,
    String? email,
    String? serverUrl,
    String? authToken,
    String? refreshToken,
  }) async {
    final existing = await select(userSettings).getSingleOrNull();

    if (existing == null) {
      if (username == null || email == null || serverUrl == null || authToken == null || refreshToken == null) {
        throw ArgumentError('All fields must be provided for initial insert');
      }
      final companion = UserSettingsCompanion.insert(
        username: username,
        email: email,
        serverUrl: serverUrl,
        authToken: authToken,
        refreshToken: refreshToken,
      );
      return into(userSettings).insert(companion);
    } else {
      final companion = UserSettingsCompanion(
        id: Value(existing.id),
        username: username != null && username.isNotEmpty ? Value(username) : Value(existing.username),
        email: email != null && email.isNotEmpty ? Value(email) : Value(existing.email),
        serverUrl: serverUrl != null && serverUrl.isNotEmpty ? Value(serverUrl) : Value(existing.serverUrl),
        authToken: authToken != null && authToken.isNotEmpty ? Value(authToken) : Value(existing.authToken),
        refreshToken: refreshToken != null && refreshToken.isNotEmpty ? Value(refreshToken) : Value(existing.refreshToken),
      );
      await update(userSettings).replace(companion);
      return existing.id;
    }
  }

  Future<String?> getAuthToken() async {
    final settings = await select(userSettings).getSingleOrNull();
    return settings?.authToken;
  }

  Future<String?> getRefreshToken() async {
    final settings = await select(userSettings).getSingleOrNull();
    return settings?.refreshToken;
  }

  Future<String?> getUsername() async {
    final settings = await select(userSettings).getSingleOrNull();
    return settings?.username;
  }

  Future<String?> getEmail() async {
    final settings = await select(userSettings).getSingleOrNull();
    return settings?.email;
  }

  Future<String?> getServerUrl() async {
    final settings = await select(userSettings).getSingleOrNull();
    return settings?.serverUrl;
  }


  // ---------- DOWNLOADED OFFLINE MAPS ----------

  Future<int> insertDownloadedMap(String mapIdAndName) async {
    final parts = mapIdAndName.split(':');
    final mapId = parts[0];
    final mapName = parts[1];
    final companion = DownloadedOfflineMapsCompanion.insert(
      mapId: mapId,
      mapName: mapName,
    );
    return into(downloadedOfflineMaps).insert(companion);
  }

  Future<void> deleteDownloadedMap(String mapId) async {
    await (delete(downloadedOfflineMaps)..where((m) => m.mapId.equals(mapId))).go();
  }

  // Returns list of "mapId:mapName"
  Future<List<String>> getDownloadedMaps() async {
    final maps = await select(downloadedOfflineMaps).get();
    return maps.map((m) => '${m.mapId}:${m.mapName}').toList();
  }

}