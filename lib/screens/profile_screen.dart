import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Define a function type for the onTap callback
typedef EditCallback = void Function();

class ProfileScreen extends StatelessWidget {
  final String? currentLocation; // 👈 Add this for displaying registered location

  const ProfileScreen({super.key, this.currentLocation});

  // A dummy function to simulate navigation/editing action
  void _editField(BuildContext context, String fieldName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TODO: Navigate to Edit Screen for $fieldName')),
    );
  }

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

        // Fetch all necessary data fields
        final userName = userData['displayName'] ?? 'No Name';
        final homeAddress = userData['homeAddress'] ?? 'No Address';
        final registeredLocation = userData['location'] ?? 'No Location';
        // 2. Fetch the new medical information field
        final medicalInfo = userData['medicalInfo'] ?? 'Blood type, allergies, existing conditions';


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
                  // Display account creation date as M/D/YYYY
                  'Account Created: ${user.metadata.creationTime != null ? '${user.metadata.creationTime!.month}/${user.metadata.creationTime!.day}/${user.metadata.creationTime!.year}' : 'N/A'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 30),

                // --- PERSONAL INFORMATION SECTION ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Personal Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),

                // 3. User Name with Edit Icon
                _buildInfoTile(
                  Icons.badge_outlined, 
                  'User Name', 
                  userName, 
                  theme,
                  isEditable: true, // Enable editing
                  onTap: () => _editField(context, 'User Name'),
                ),
                // 4. Home Address with Edit Icon
                _buildInfoTile(
                  Icons.home_outlined, 
                  'Home Address', 
                  homeAddress, 
                  theme,
                  isEditable: true, // Enable editing
                  onTap: () => _editField(context, 'Home Address'),
                ),
                // Current Registered Location (Not editable, no onTap)
                _buildInfoTile(
                  Icons.location_on_outlined, 
                  'Current Registered Location', 
                  registeredLocation, 
                  theme,
                ),

                // --- MEDICAL INFORMATION SECTION (New) ---
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Medical Information',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // 5. Medical Information Tile with Edit Icon
                _buildInfoTile(
                  Icons.medical_services_outlined, // Appropriate icon for medical info
                  'Medical Information', 
                  medicalInfo, 
                  theme,
                  isEditable: true, // Enable editing
                  onTap: () => _editField(context, 'Medical Information'),
                ),


                // --- EMERGENCY CONTACT SECTION ---
                const SizedBox(height: 30),
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
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  child: ListTile(
                  leading: const Icon(Icons.phone_enabled_outlined),
                  title: const Text('View / Manage Emergency Contacts'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                      // TODO: Navigate to Emergency Contacts Screen
                      _editField(context, 'Emergency Contacts');
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

  // 6. Modified Helper widget: Now accepts an optional onTap and isEditable flag
  Widget _buildInfoTile(
    IconData icon, 
    String label, 
    String value, 
    ThemeData theme, 
    {bool isEditable = false, EditCallback? onTap} // New optional parameters
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: theme.textTheme.bodyMedium),
        // Add the trailing icon only if the tile is editable
        trailing: isEditable
            ? Icon(Icons.edit_outlined, color: theme.colorScheme.primary) // The pencil icon
            : null,
        // Add the onTap handler to the ListTile if provided
        onTap: isEditable ? onTap : null,
      ),
    );
  }
}