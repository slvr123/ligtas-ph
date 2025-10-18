import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final String? currentLocation; // 👈 Add this for displaying registered location

  const ProfileScreen({super.key, this.currentLocation});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User profile not found"));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        final userName = userData['displayName'] ?? 'No Name'; 
        final homeAddress = userData['homeAddress'] ?? 'No Address'; 
        final registeredLocation = userData['location'] ?? 'No Location';

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile', style: theme.textTheme.headlineMedium),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person_rounded, size: 70, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 20),

                Text(user.email!, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Account Created: ${user.metadata.creationTime != null ? '${user.metadata.creationTime!.month}/${user.metadata.creationTime!.day}/${user.metadata.creationTime!.year}' : 'N/A'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Personal Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),

                _buildInfoTile(Icons.badge_outlined, 'User Name', userName, theme),
                _buildInfoTile(Icons.home_outlined, 'Home Address', homeAddress, theme),
                _buildInfoTile(Icons.location_on_outlined, 'Current Registered Location', registeredLocation, theme),

                //emergency contact
                const SizedBox(height: 30), // Spacing before the new section
                
                Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Emergency Contact List',
                     style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  child: ListTile(
                  leading: const Icon(Icons.phone_enabled_outlined),
                  title: const Text('View / Manage Emergency Contacts'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                      // TODO: Navigate to Emergency Contacts Screen
                      // e.g., Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyContactsScreen()));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔧 Helper widget for displaying profile info neatly
  Widget _buildInfoTile(IconData icon, String label, String value, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
