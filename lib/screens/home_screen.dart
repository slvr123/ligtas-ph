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
import 'location_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  final String location;
  final double latitude;
  final double longitude;
  

  const HomeScreen({
    super.key,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  void _changeLocation(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LocationSetupScreen()),
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog
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
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();
        
        // Ensure we return to the root route so AuthWrapper rebuilds to LoginPage
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out')),
          );
        }
        
      } catch (e) {
        // Show error if logout fails
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home', style: theme.textTheme.headlineMedium),
            Text(location, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location_outlined),
            onPressed: () => _changeLocation(context),
            tooltip: 'Change Location',
          ),
          // Logout button with menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text('Profile', style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Padding for SOS button
        children: [
          Text(
            "Highest Priority Alert",
            style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          DisasterAlertCard(
            title: 'Typhoon Signal No. 3',
            level: 'SEVERE',
            description: 'Typhoon "Karding" is directly affecting $location. Expect destructive winds and intense rainfall. Evacuate if in a low-lying area.',
            levelColor: theme.colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            "Tools & Resources",
            style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
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
                color: theme.colorScheme.primary, // Red for high importance
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AlertsScreen(location: location))),
              ),
              HomeGridButton(
                text: 'Emergency Hotlines',
                icon: Icons.phone_in_talk_rounded,
                color: const Color(0xFF1d4ed8), // Blue for communication
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotlinesScreen(location: location))),
              ),
              HomeGridButton(
                text: 'Safety Checklist',
                icon: Icons.checklist_rtl_rounded,
                color: const Color(0xFF15803d), // Green for preparedness
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChecklistScreen())),
              ),
              HomeGridButton(
                text: 'First Aid & Safety',
                icon: Icons.health_and_safety_rounded,
                color: const Color(0xFF7e22ce), // Purple for health
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthSafetyScreen())),
              ),
              HomeGridButton(
                text: 'News Updates',
                icon: Icons.newspaper_rounded,
                color: const Color(0xFFea580c), // Orange for information
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsUpdatesScreen())),
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
            ],
          ),
        ],
      ),
    );
  }
}