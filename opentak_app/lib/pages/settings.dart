import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:opentak_app/settings/_map_source.dart';
import 'package:opentak_app/settings/_offline_maps.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                    MaterialPageRoute(builder: (context) => const OfflineMapsSettingsPage()),
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