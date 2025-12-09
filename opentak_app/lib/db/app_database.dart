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


@DriftDatabase(tables: [BuildingRows, FloorOverlayRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
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

}