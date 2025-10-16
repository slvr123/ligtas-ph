// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Placeholder state for settings. You would typically use a State Management 
  // solution (like Provider or Riverpod) or SharedPreferences to manage these.
  bool _alertNotifications = true;
  bool _locationTracking = true;
  String _alertTone = 'Loud Chime';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // ------------------------------------
          // NOTIFICATION SETTINGS
          // ------------------------------------
          Text(
            'Alerts & Notifications',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),
          
          SwitchListTile(
            title: const Text('Real-time Disaster Alerts'),
            subtitle: const Text('Receive immediate push notifications for critical alerts.'),
            secondary: const Icon(Icons.notifications_active_outlined),
            value: _alertNotifications,
            onChanged: (bool value) {
              setState(() {
                _alertNotifications = value;
              });
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text('Alert Tone'),
            subtitle: Text(_alertTone),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              // TODO: Implement tone selection dialog/screen
            },
          ),

          const SizedBox(height: 30),

          // ------------------------------------
          // PRIVACY & LOCATION
          // ------------------------------------
          Text(
            'Privacy',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Background Location Tracking'),
            subtitle: const Text('Required for localized alerts and safety features.'),
            secondary: const Icon(Icons.location_on_outlined),
            value: _locationTracking,
            onChanged: (bool value) {
              setState(() {
                _locationTracking = value;
                // TODO: Implement native code to toggle background location
              });
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.lock_open_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              // TODO: Navigate to Privacy Policy web view
            },
          ),
        ],
      ),
    );
  }
}