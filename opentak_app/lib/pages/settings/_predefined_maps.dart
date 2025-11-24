import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:opentak_app/pages/models/enums/_map_types.dart';
import 'package:opentak_app/pages/models/_maps_presets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:opentak_app/pages/widgets/_zoom_slider.dart';

class _MapDownloadState {
  final Stream<DownloadProgress> stream;
  final String storeId;
  final Object instanceId;
  final List<String> downloadedMaps;
  final void Function(String key) onComplete;
  final Future<void> Function(String key) deletePresetMap;
  bool paused = false;

  _MapDownloadState({
    required this.stream,
    required this.storeId,
    required this.instanceId,
    required this.downloadedMaps,
    required this.onComplete,
    required this.deletePresetMap,
  });
}

class PredefinedMapsSettingsPage extends StatefulWidget {
  final dynamic downloadedMaps;
  final void Function(String key) onComplete;
  final Future<void> Function(String key) deletePresetMap;

  const PredefinedMapsSettingsPage({
    super.key,
    required this.downloadedMaps,
    required this.onComplete,
    required this.deletePresetMap,
  });

  @override
  State<PredefinedMapsSettingsPage> createState() =>
      _PredefinedMapsSettingsPageState();
}

class _PredefinedMapsSettingsPageState extends State<PredefinedMapsSettingsPage> {
  late SharedPreferences _prefs;
  int minZoom = 1;
  int maxZoom = 18;

  final Map<String, _MapDownloadState> _downloads = {};

  String _mapKey(String id, String name) => '$id:$name';

  bool _isMapDownloaded(String id, String name) =>
      widget.downloadedMaps.contains(_mapKey(id, name));

  @override
  void initState(){
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {});
    minZoom = _prefs.getInt('minZoom') ?? 1;
    maxZoom = _prefs.getInt('maxZoom') ?? 18;

    if (_prefs.getInt('minZoom') == null) {
      _prefs.setInt('minZoom', minZoom);
    }
    if (_prefs.getInt('maxZoom') == null) {
      _prefs.setInt('maxZoom', maxZoom);
    }
  }
  
  Future<void> _downloadPresetMap(
    List<List<double>> coordinates,
    CustomMapType type,
    double? radius,
    String id,
    String name,
  ) async {
    final key = _mapKey(id, name);

    if (_downloads.containsKey(key)) return;

    late final BaseRegion region;

    if (type == CustomMapType.rectangle) {
      region = RectangleRegion(
        LatLngBounds(
          LatLng(coordinates[0][0], coordinates[0][1]),
          LatLng(coordinates[1][0], coordinates[1][1]),
        ),
      );
    } else if (type == CustomMapType.circle) {
      region = CircleRegion(
        LatLng(coordinates[0][0], coordinates[0][1]),
        radius ?? 1000,
      );
    } else if (type == CustomMapType.line) {
      region = LineRegion(
        coordinates.map((c) => LatLng(c[0], c[1])).toList(),
        radius ?? 1000,
      );
    } else if (type == CustomMapType.polygon) {
      region = CustomPolygonRegion(
        coordinates.map((c) => LatLng(c[0], c[1])).toList(),
      );
    } else {
      return;
    }

    final storeName = id;
    final store = FMTCStore(storeName);

    if (!await store.manage.ready) {
      await store.manage.create();
    }

    final downloadableRegion = region.toDownloadable(
      minZoom: minZoom,
      maxZoom: maxZoom,
      options: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'OpenTAK',
      ),
    );

    try {
      final (:downloadProgress, :tileEvents) =
          store.download.startForeground(
            region: downloadableRegion,
            instanceId: id,
          );

      setState(() {
        _downloads[key] = _MapDownloadState(
          stream: downloadProgress,
          storeId: storeName,
          instanceId: id,
          downloadedMaps: widget.downloadedMaps,
          onComplete: widget.onComplete,
          deletePresetMap: widget.deletePresetMap,
        );
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading map: $error')),
      );
    }
  }
  
  Future<void> _pauseDownload(String key) async {
    final state = _downloads[key];
    if (state == null) return;

    final store = FMTCStore(state.storeId);
    await store.download.pause(instanceId: state.instanceId);

    setState(() {
      state.paused = true;
    });
  }

  Future<void> _resumeDownload(String key) async {
    final state = _downloads[key];
    if (state == null) return;

    final store = FMTCStore(state.storeId);
    store.download.resume(instanceId: state.instanceId);

    setState(() {
      state.paused = false;
    });
  }

  Future<void> _cancelDownload(String key) async {
    final state = _downloads[key];
    if (state == null) return;

    final store = FMTCStore(state.storeId);
    await store.download.cancel(instanceId: state.instanceId);

    setState(() {
      _downloads.remove(key);
    });
  }

  Widget _buildDownloadIcon(PresetMap presetMap, String id) {
    final key = _mapKey(id, presetMap.name);
    final downloadState = _downloads[key];

    if (_isMapDownloaded(id, presetMap.name) && downloadState == null) {
      return SizedBox(
        width: 24,
        height: 24,
        child: IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 24,
          onPressed: () {
            setState(() {
              final id = presetMap.id;
              widget.deletePresetMap(id);
            });
          },
        ),
      );
    }

    if (downloadState != null) {
      return StreamBuilder<DownloadProgress>(
        stream: downloadState.stream,
        builder: (context, snapshot) {
        final progress = (snapshot.data?.percentageProgress ?? 0).clamp(0, 100);
        // auto-clean when done
        if (progress == 100 && _downloads.containsKey(key)) {
          Future.microtask(() {
            setState(() {
              _downloads.remove(key);
              widget.onComplete(key);
            });
          });
        }
        return SizedBox(
          width: 90,
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Circle with progress + pause/play on top
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (downloadState.paused) {
                    _resumeDownload(key);
                  } else {
                    _pauseDownload(key);
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: progress / 100,
                        strokeWidth: 3,
                      ),
                    ),
                    Icon(
                      downloadState.paused ? Icons.play_arrow : Icons.pause,
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // X button with proper tap area
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _cancelDownload(key),
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
      }
    return const Icon(Icons.download);
  }

  AbstractSettingsTile downloadMapTile(PresetMap presetMap) {
    final id = presetMap.id;
    final key = _mapKey(id, presetMap.name);

    return SettingsTile(
      title: Text(presetMap.name),
      description: presetMap.description.isNotEmpty
          ? Text(presetMap.description)
          : null,
      value: _buildDownloadIcon(presetMap, id),
      onPressed: (context) {
        // Map is fully downloaded and not currently downloading
        if (_isMapDownloaded(id, presetMap.name) &&
            !_downloads.containsKey(key)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Map "${presetMap.name}" is already downloaded.')),
          );
          return;
        }

        // If downloading already, tapping tile toggles pause/resume
        if (_downloads.containsKey(key)) {
          final state = _downloads[key]!;
          if (state.paused) {
            _resumeDownload(key);
          } else {
            _pauseDownload(key);
          }
          return;
        }

        // Start new download
        final downloadData = presetMap.downloadMap();
        _downloadPresetMap(
          downloadData[0] as List<List<double>>,
          downloadData[1] as CustomMapType,
          downloadData.length > 2 ? downloadData[2] as double? : null,
          downloadData.length > 3 ? downloadData[3] as String : id,
          presetMap.name,
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predefined Maps'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Settings'),
            tiles: [
              CustomSettingsTile(
                child: ZoomSlider(
                  minZoom: minZoom,
                  maxZoom: maxZoom,
                  onChanged: (newRange) {
                    setState(() {
                      minZoom = newRange.start.round();
                      maxZoom = newRange.end.round();
                      _prefs.setInt('minZoom', minZoom);
                      _prefs.setInt('maxZoom', maxZoom);
                    });
                  },
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Maps'),
            tiles: PresetMap.dummies().map((presetMap) {
              return downloadMapTile(presetMap);
            }).toList(),
          ),
        ],
      ),
    );
  }
}