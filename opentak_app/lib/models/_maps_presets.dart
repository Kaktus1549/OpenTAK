import 'package:opentak_app/models/enums/_map_types.dart';
import 'package:opentak_app/Utils/_web.dart';
import 'dart:convert';

class PresetMap {
  final String name;
  final String description;
  final String id;
  final CustomMapType type;
  final List<List<double>> coordinates; // [ [lat, lon], [lat, lon], ... ]
  final double? radius;

  PresetMap({
    required this.name,
    required this.id,
    required this.type,
    required this.coordinates,
    this.radius,
    this.description = '',
  });

  @override
  String toString() {
    return 'PresetMap(id: $id, name: $name, type: $type, coordinates: $coordinates, radius: $radius)';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      if (description.isNotEmpty) 'description': description,
      'type': type.toString().split('.').last,
      'coordinates': coordinates,
      'radius': radius,
    };
  }

  factory PresetMap.fromJson(Map<String, dynamic> json) {
    return PresetMap(
      name: json['name'] as String,
      id: json['id'] as String,
      description: json['description'] ?? '',
      type: CustomMapType.values.firstWhere(
        (e) => e.toString() == 'CustomMapType.${json['type']}',
      ),
      coordinates: List<List<double>>.from(
        (json['coordinates'] as List).map(
          (coordList) => List<double>.from(
            (coordList as List).map((e) => (e as num).toDouble()),
          ),
        ),
      ),
      radius:
          json['radius'] != null ? (json['radius'] as num).toDouble() : null,
    );
  }

  /// Note: id is required now
  factory PresetMap.fromString(String data, {required String id}) {
    final parts = data.split(';');
    final name = parts[0];
    final type = CustomMapType.values.firstWhere(
      (e) => e.toString() == 'CustomMapType.${parts[1]}',
    );

    final coordinates = parts[2]
        .split('|')
        .map((coord) {
          final latLon = coord.split(',');
          return [
            double.parse(latLon[0]),
            double.parse(latLon[1]),
          ];
        })
        .toList();

    double? radius;
    if (parts.length > 3) {
      radius = double.tryParse(parts[3]);
    }

    return PresetMap(
      name: name,
      id: id,
      type: type,
      coordinates: coordinates,
      radius: radius,
    );
  }

  List<dynamic> downloadMap() {
    return [coordinates, type, radius, id];
  }

  /// Dummy presets: rough rectangles around each city
  static Future<List<PresetMap>> getMaps(String? serverUrl, String? authToken) async {
    List<PresetMap> dummyMaps = [
        PresetMap(
          name: 'Prague',
          id: 'offline_prague',
          type: CustomMapType.rectangle,
          coordinates: [
            [50.02, 14.30],
            [50.12, 14.60],
          ],
          radius: null,
        ),
        PresetMap(
          name: 'Pardubice',
          id: 'offline_pardubice',
          type: CustomMapType.rectangle,
          coordinates: [
            [49.99, 15.73],
            [50.06, 15.84],
          ],
          radius: null,
        ),
        PresetMap(
          name: 'Lysa nad Labem',
          id: 'offline_lysa_nad_labem',
          type: CustomMapType.rectangle,
          coordinates: [
            [50.17, 14.81], 
            [50.23, 14.87], 
          ],
          radius: null,
        ),
        PresetMap(
          name: 'City Map',
          id: 'offline_city_map',
          type: CustomMapType.rectangle,
          coordinates: [
            [52.17, 14.81], 
            [53.23, 15.87], 
          ],
          radius: null,
        ),
      ];
    if (serverUrl == null || authToken == null) {
      return dummyMaps;
    } else {
      OpenTAKHTTPClient client = OpenTAKHTTPClient(serverUrl: serverUrl, authToken: authToken);
      // Get maps from server and convert them to PresetMap instances
      final response = await client.getAvailableMaps();
      List<PresetMap> serverMaps = response.map((mapData) => PresetMap.fromJson(jsonDecode(mapData) as Map<String, dynamic>)).toList();
      return [...dummyMaps, ...serverMaps];
    }
  }
}