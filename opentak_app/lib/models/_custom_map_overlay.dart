import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' show Svg;
import 'package:opentak_app/save_data/_file_save.dart';


class FloorOverlay{
  final String assetPath;
  final LatLng topLeft;
  final LatLng bottomRight;
  final LatLng bottomLeft;
  final int floorNumber;
  final int id;
  final int buildingId;

  const FloorOverlay({
    required this.assetPath,
    required this.topLeft,
    required this.bottomRight,
    required this.bottomLeft,
    required this.floorNumber,
    required this.id,
    required this.buildingId,
  });
}

class CustomMapOverlay{
  final List<FloorOverlay> floorList;
  final double floorHeight;
  final double baseHeight;
  final int buildingID;
  final String name;

  const CustomMapOverlay({
    required this.floorList,
    required this.buildingID,
    required this.name,
    required this.floorHeight,
    required this.baseHeight,
  });

  FloorOverlay? getFloorOverlay(double currentHeight){
    // If there is one floor return the first floor
    if(floorList.length == 1){
      return floorList.first;
    }
    int floorIndex = ((currentHeight - baseHeight) / floorHeight).floor();
    if(floorIndex < 0){
      return floorList.first;
    }
    if(floorIndex >= floorList.length){
      return floorList.last;
    }
    return floorList[floorIndex];
  }

  LatLng getTopLeftCorner(int floorNumber){
    for(var floor in floorList){
      if(floor.floorNumber == floorNumber){
        return floor.topLeft;
      }
    }
    throw Exception("Floor number $floorNumber not found");
  }

  LatLng getBottomLeftCorner(int floorNumber){
    for(var floor in floorList){
      if(floor.floorNumber == floorNumber){
        return floor.bottomLeft;
      }
    }
    throw Exception("Floor number $floorNumber not found");
  }

  LatLng getBottomRightCorner(int floorNumber){
    for(var floor in floorList){
      if(floor.floorNumber == floorNumber){
        return floor.bottomRight;
      }
    }
    throw Exception("Floor number $floorNumber not found");
  }

  bool addFloorOverlay(FloorOverlay newFloor){
    for(var floor in floorList){
      if(floor.floorNumber == newFloor.floorNumber){
        return false; // Floor with same number already exists
      }
    }
    floorList.add(newFloor);
    return true;
  }

  bool updateFloorOverlay(FloorOverlay updatedFloor){
    for(int i = 0; i < floorList.length; i++){
      if(floorList[i].floorNumber == updatedFloor.floorNumber){
        floorList[i] = updatedFloor;
        return true; // Floor updated
      }
    }
    return false; // Floor not found
  }

  bool removeFloorOverlay(int floorNumber){
    for(int i = 0; i < floorList.length; i++){
      if(floorList[i].floorNumber == floorNumber){
        floorList.removeAt(i);
        return true; // Floor removed
      }
    }
    return false; // Floor not found
  }

  LatLng getCenter(){
    // Calculate center based on the first floor's corners
    if(floorList.isEmpty){
      throw Exception("No floors available to calculate center");
    }
    var firstFloor = floorList.first;
    double centerLat = (firstFloor.topLeft.latitude + firstFloor.bottomRight.latitude) / 2;
    double centerLng = (firstFloor.topLeft.longitude + firstFloor.bottomRight.longitude) / 2;
    return LatLng(centerLat, centerLng);
  }

}

class CustomMapOverlayUtils {
  static Future<List<RotatedOverlayImage>> renderActiveOverlays(List<CustomMapOverlay> activeOverlays, double currentHeight, MapStorage storage) async {
    List<RotatedOverlayImage> overlayImages = [];
    for (var overlay in activeOverlays) {
      FloorOverlay? floorOverlay = overlay.getFloorOverlay(currentHeight);
      if (floorOverlay != null) {
        String? assetPath = await storage.getFilePath(floorOverlay.assetPath);
        if (assetPath == null) {
          continue; // File not found, skip this overlay
        }
        overlayImages.add(
          RotatedOverlayImage(
            topLeftCorner: floorOverlay.topLeft,
            bottomRightCorner: floorOverlay.bottomRight,
            bottomLeftCorner: floorOverlay.bottomLeft,
            imageProvider: floorOverlay.assetPath.endsWith('.svg')
                ? Svg(assetPath) // Placeholder for SVG handling
                : AssetImage(assetPath),
          ),
        );
      }
    }
    return overlayImages;
  }
}