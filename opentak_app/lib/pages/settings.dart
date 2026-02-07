import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:opentak_app/settings/_map_source.dart';
import 'package:opentak_app/settings/_offline_maps.dart';
import 'package:opentak_app/db/app_database.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.db});

  final AppDatabase db;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String? serverUrl = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from the database or other sources
    final dbUrl = await widget.db.getServerUrl() ?? 'https://tak.kaktusgame.eu';
    setState(() {
      serverUrl = dbUrl;
    });
  }

  // Update server URL in the database
  Future<void> _updateServerUrl(String newUrl) async {
    await widget.db.insertOrUpdateUserSettings(
      username: null, // Keep existing username
      email: null, // Keep existing email
      serverUrl: newUrl,
      authToken: null, // Keep existing auth token
      refreshToken: null, // Keep existing refresh token
    );
    setState(() {
      serverUrl = newUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (serverUrl == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF121212), // dark background for high contrast
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
            title: const Text('General'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
                onPressed: (context) {
                  // Handle language change
                },
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                initialValue: false,
                onToggle: (value) {
                  // Handle dark mode toggle
                },
              ),
              // Server URL setting
              SettingsTile(
                leading: const Icon(Icons.cloud),
                title: const Text('Server URL'),
                value: Text(serverUrl ?? ''),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String newUrl = serverUrl ?? '';
                      return AlertDialog(
                        title: const Text('Edit Server URL'),
                        content: TextField(
                          onChanged: (value) {
                            newUrl = value;
                          },
                          controller: TextEditingController(text: serverUrl),
                          decoration: const InputDecoration(
                            hintText: 'Enter server URL',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _updateServerUrl(newUrl);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Save'),
                          ),  
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Map related'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.map),
                title: const Text('Map Source'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapSourceSettingsPage()),
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.save),
                title: const Text('Offline Maps'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OfflineMapsSettingsPage(context: context)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}