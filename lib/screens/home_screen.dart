// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:disaster_awareness_app/screens/alerts_screen.dart';
import 'package:disaster_awareness_app/screens/checklist_screen.dart';
import 'package:disaster_awareness_app/screens/health_safety_screen.dart';
import 'package:disaster_awareness_app/screens/hotlines_screen.dart';
import 'package:disaster_awareness_app/screens/news_updates_screen.dart';
import 'package:disaster_awareness_app/screens/community_screen.dart';
import 'package:disaster_awareness_app/widgets/disaster_alert_card.dart';
import 'package:disaster_awareness_app/widgets/home_grid_button.dart';
import 'package:disaster_awareness_app/widgets/sos_button.dart';
import 'package:disaster_awareness_app/services/alert_service.dart';
import 'location_setup_screen.dart';
import 'package:disaster_awareness_app/screens/profile_screen.dart';
import 'package:disaster_awareness_app/screens/settings_screen.dart';
import 'package:disaster_awareness_app/screens/user_service.dart';
import 'package:disaster_awareness_app/screens/login_page.dart';

class HomeScreen extends StatefulWidget {
  final String location;
  final double latitude;
  final double longitude;

  const HomeScreen({
    super.key,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Alert? _highestPriorityAlert;
  bool _isLoadingAlert = true;

  @override
  void initState() {
    super.initState();
    _loadHighestPriorityAlert();
  }

  Future<void> _loadHighestPriorityAlert() async {
    try {
      print('📍 Loading highest priority alert for ${widget.location}...');
      final alertService = AlertService();
      final alert = await alertService.getHighestPriorityAlert(widget.location);

      if (mounted) {
        setState(() {
          _highestPriorityAlert = alert;
          _isLoadingAlert = false;
        });
      }

      if (alert != null) {
        print('🚨 Highest priority alert: ${alert.title} (${alert.level})');
      } else {
        print('✅ No alerts for ${widget.location}');
      }
    } catch (e) {
      print('❌ Error loading alert: $e');
      if (mounted) {
        setState(() {
          _isLoadingAlert = false;
        });
      }
    }
  }

  Color _getAlertColor(String level) {
    switch (level.toUpperCase()) {
      case 'SEVERE':
        return Colors.red.shade700;
      case 'MODERATE':
        return Colors.orange.shade700;
      case 'WARNING':
        return Colors.amber.shade700;
      case 'INFO':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _changeLocation(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LocationSetupScreen()),
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Clear guest data if needed
        UserService.clearGuestData();

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        if (context.mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Wait a moment for snackbar to be visible, then navigate to login
          await Future.delayed(const Duration(milliseconds: 500));

          if (context.mounted) {
            // Navigate to login and clear navigation stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /*
  // Commented out Alert System Diagnostics
  void _showAlertDiagnostics() async {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder(
        future: _getDebugInfo(),
        builder: (context, snapshot) {
          return AlertDialog(
            title: const Text('Alert System Diagnostics'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 Location: ${widget.location}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${widget.latitude.toStringAsFixed(4)}, Lng: ${widget.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current Alert: ${_highestPriorityAlert?.title ?? "✅ None"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('🔌 API Status:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (snapshot.hasData)
                    ...snapshot.data as List<Widget>
                  else
                    const Text('Error loading API status'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  _loadHighestPriorityAlert();
                  Navigator.pop(context);
                },
                child: const Text('Refresh'),
              ),
            ],
          );
        },
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home', style: theme.textTheme.headlineMedium),
            Text(widget.location,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_outlined),
            onPressed: () => _changeLocation(context),
            tooltip: 'Change Location',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline,
                        color: theme.colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Profile', style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined,
                        color: theme.colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Settings', style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const SosButton(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Text(
            "Highest Priority Alert",
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          if (_isLoadingAlert)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_highestPriorityAlert != null)
            DisasterAlertCard(
              title: _highestPriorityAlert!.title,
              level: _highestPriorityAlert!.level,
              description: _highestPriorityAlert!.description,
              levelColor: _getAlertColor(_highestPriorityAlert!.level),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade900.withOpacity(0.3),
                border: Border.all(color: Colors.green.shade700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade400, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Active Alerts',
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'No disaster alerts affecting ${widget.location}',
                          style: TextStyle(
                            color: Colors.green.shade300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Commented out Alert System Diagnostics button
          /*
          ElevatedButton.icon(
            onPressed: _showAlertDiagnostics,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.medical_services_outlined),
            label: const Text(
              'Alert System Diagnostics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          */

          Text(
            "Tools & Resources",
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              HomeGridButton(
                text: 'Alerts',
                icon: Icons.warning_amber_rounded,
                color: theme.colorScheme.primary,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            AlertsScreen(location: widget.location))),
              ),
              HomeGridButton(
                text: 'News Updates',
                icon: Icons.newspaper_rounded,
                color: const Color(0xFFea580c),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          NewsUpdatesScreen(location: widget.location)),
                ),
              ),
              HomeGridButton(
                text: 'Community',
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF0d9488),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommunityScreen()),
                ),
              ),
              HomeGridButton(
                text: 'Emergency Hotlines',
                icon: Icons.phone_in_talk_rounded,
                color: const Color(0xFF1d4ed8),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            HotlinesScreen(location: widget.location))),
              ),
              HomeGridButton(
                text: 'Safety Checklist',
                icon: Icons.checklist_rtl_rounded,
                color: const Color(0xFF15803d),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ChecklistScreen())),
              ),

              // ⭐ THIS IS THE MODIFIED BUTTON
              HomeGridButton(
                text: 'First Aid & Safety',
                icon: Icons.health_and_safety_rounded,
                color: const Color(0xFF7e22ce),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HealthSafetyScreen(
                      location: widget.location,
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                    ),
                  ),
                ),
              ),
              // ⭐ END MODIFICATION
            ],
          ),
        ],
      ),
    );
  }
}
