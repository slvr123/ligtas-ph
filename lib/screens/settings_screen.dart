import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:disaster_awareness_app/screens/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _alertNotifications = true;
  bool _newsNotifications = true;
  bool _communityNotifications = true;
  bool _locationTracking = true;
  String _alertTone = 'Loud Chime';
  String _userLocation = 'Loading...';
  final UserService _userService = UserService();

  final List<String> _alertTones = [
    'Loud Chime',
    'Soft Bell',
    'Alarm Sound',
    'Emergency Siren',
    'Silent',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final location = await _userService.getUserLocation();
      if (location != null && mounted) {
        setState(() {
          _userLocation = location['location'];
        });
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  void _showAlertToneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1f2937),
        title: const Text(
          'Select Alert Tone',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _alertTones
                .map(
                  (tone) => RadioListTile<String>(
                    title: Text(
                      tone,
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: tone,
                    groupValue: _alertTone,
                    fillColor: MaterialStateProperty.all(const Color(0xFFb91c1c)),
                    onChanged: (value) {
                      setState(() {
                        _alertTone = value!;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Alert tone changed to: $value'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showUpdateLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1f2937),
        title: const Text(
          'Update Location',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Current location: $_userLocation\n\nTo change your location, please navigate to the Location Setup screen from your profile.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showQuietHoursDialog() {
    TimeOfDay startTime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 7, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1f2937),
        title: const Text(
          'Quiet Hours',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Start Time',
                style: TextStyle(color: Colors.white70),
              ),
              subtitle: Text(
                startTime.format(context),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.edit, color: Colors.white70),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: startTime,
                );
                if (picked != null) {
                  startTime = picked;
                }
              },
            ),
            ListTile(
              title: const Text(
                'End Time',
                style: TextStyle(color: Colors.white70),
              ),
              subtitle: Text(
                endTime.format(context),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.edit, color: Colors.white70),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: endTime,
                );
                if (picked != null) {
                  endTime = picked;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save quiet hours to SharedPreferences or Firebase
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Quiet hours set: ${startTime.format(context)} - ${endTime.format(context)}'),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFFb91c1c))),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1f2937),
          title: const Text(
            'Change Password',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Current Password',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF374151),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: _obscureNewPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF374151),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Confirm New Password',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF374151),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  // Re-authenticate user
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // Change password
                  await user.updatePassword(newPasswordController.text);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Change', style: TextStyle(color: Color(0xFFb91c1c))),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1f2937),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                // Delete user from Firebase
                await user.delete();

                if (mounted) {
                  Navigator.pop(context);
                  // Navigate to login screen
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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

          SwitchListTile(
            title: const Text('News Updates'),
            subtitle: const Text('Get notified about new disaster-related news.'),
            secondary: const Icon(Icons.newspaper_outlined),
            value: _newsNotifications,
            onChanged: (bool value) {
              setState(() {
                _newsNotifications = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Community Updates'),
            subtitle: const Text('Receive notifications from community posts.'),
            secondary: const Icon(Icons.people_outline),
            value: _communityNotifications,
            onChanged: (bool value) {
              setState(() {
                _communityNotifications = value;
              });
            },
          ),

          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text('Alert Tone'),
            subtitle: Text(_alertTone),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _showAlertToneDialog,
          ),

          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Quiet Hours'),
            subtitle: const Text('Set time range for silent notifications'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _showQuietHoursDialog,
          ),



          // ------------------------------------
          // LOCATION SETTINGS
          // ------------------------------------
          Text(
            'Location',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Current Location'),
            subtitle: Text(_userLocation),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _showUpdateLocationDialog,
          ),

          SwitchListTile(
            title: const Text('Background Location Tracking'),
            subtitle: const Text('Required for localized alerts and safety features.'),
            secondary: const Icon(Icons.gps_fixed_outlined),
            value: _locationTracking,
            onChanged: (bool value) {
              setState(() {
                _locationTracking = value;
              });
            },
          ),

          const SizedBox(height: 30),

          // ------------------------------------
          // ACCOUNT SETTINGS
          // ------------------------------------
          Text(
            'Account',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _showChangePasswordDialog,
          ),

          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Permanently delete your account and data'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _showDeleteAccountDialog,
          ),


        ],
      ),
    );
  }
}