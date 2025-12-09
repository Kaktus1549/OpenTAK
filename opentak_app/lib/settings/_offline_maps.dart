import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opentak_app/settings/_predefined_maps.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class OfflineMapsSettingsPage extends StatefulWidget {
  const OfflineMapsSettingsPage({super.key});

  @override
  State<OfflineMapsSettingsPage> createState() =>
      _OfflineMapsSettingsPageState();
}

class _OfflineMapsSettingsPageState extends State<OfflineMapsSettingsPage> {
  late SharedPreferences _prefs;
  bool _prefsLoaded = false;
  List<String> _downloadedMaps = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadedMaps =
          _prefs.getStringList('downloaded_offline_maps') ?? [];
      _prefsLoaded = true;
    });
  }

  Future<void> _deletePresetMap(String id) async {
    final storeName = id;
    final store = FMTCStore(storeName);

    try {
      
      setState(() {
        // List: "id:mapName"
        _downloadedMaps.removeWhere((element) => element.startsWith('$id:'));
        _prefs.setStringList('downloaded_offline_maps', _downloadedMaps);
      });

      if (await store.manage.ready) {
        await store.manage.delete();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted offline map: $id')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting $id: $e')),
      );
    }
  }

  void _onComplete(String key) {
    if (!_downloadedMaps.contains(key)) {
      if (!mounted) return;
      setState(() {
        _downloadedMaps.add(key);
        _prefs.setStringList('downloaded_offline_maps', _downloadedMaps);
      });
      
    }
  }

  List<AbstractSettingsTile> _buildDownloadedMapTiles() {
    if (!_prefsLoaded) {
      return [
        const CustomSettingsTile(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ];
    }

    if (_downloadedMaps.isEmpty) {
      return [
        SettingsTile(
          title: Text('No offline maps downloaded'),
        ),
      ];
    }

    return _downloadedMaps.map((mapName) {
      return SettingsTile(
        title: Text(mapName.split(':')[1]),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: Colors.red,
          onPressed: () {
            // Trigger deletion; _deletePresetMap updates state when done.
            final id = mapName.split(':')[0];
            _deletePresetMap(id);
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Maps Settings'),
        backgroundColor: const Color(0xFF121212),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Manage Offline Maps'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.draw),
                title: const Text('Define Map'),
                onPressed: (context) {
                  // Implement download logic here
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Predefined Maps'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PredefinedMapsSettingsPage(
                            downloadedMaps: _downloadedMaps,
                            onComplete: _onComplete,
                            deletePresetMap: _deletePresetMap,
                          ),
                    ),
                  );
                },
              ),
            ]
          ),
          SettingsSection(
            title: const Text('Downloaded Maps'),
            tiles: _buildDownloadedMapTiles(),
          ),
        ],
      ),
    );
  }
}