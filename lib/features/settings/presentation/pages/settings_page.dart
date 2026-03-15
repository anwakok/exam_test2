import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:game/injection.dart';
import 'package:game/features/settings/data/settings_service.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settings = getIt<SettingsService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _settings.isDarkMode,
            onChanged: (value) async {
              await _settings.setDarkMode(value);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('Sound'),
            value: _settings.soundEnabled,
            onChanged: (value) async {
              await _settings.setSoundEnabled(value);
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: _settings.language,
              onChanged: (value) async {
                if (value != null) {
                  await _settings.setLanguage(value);
                  setState(() {});
                }
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'th', child: Text('Thai')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Clear Cache'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _settings.clear();
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
