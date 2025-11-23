import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';

class MapSourceSettingsPage extends StatelessWidget {
  const MapSourceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Source Settings'),
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
            title: const Text('Map Source'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.map),
                title: const Text('Select Map Source'),
                onPressed: (context) {
                  // Handle map source selection
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}