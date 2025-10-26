import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef EditCallback = void Function();

class ProfileScreen extends StatelessWidget {
  final String? currentLocation;

  const ProfileScreen({super.key, this.currentLocation});

  // Edit User Name Dialog
  void _editUserName(BuildContext context, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: const Text('Edit User Name'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name cannot be empty')),
                    );
                    return;
                  }
                  
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .update({'displayName': controller.text.trim()});
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Edit Home Address Dialog
  void _editHomeAddress(BuildContext context, String currentAddress) {
    final TextEditingController controller = TextEditingController(text: currentAddress == 'No Address' ? '' : currentAddress);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: const Text('Edit Home Address'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Home Address',
                border: OutlineInputBorder(),
                hintText: 'Enter your complete address',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.words,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address cannot be empty')),
                    );
                    return;
                  }
                  
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .update({'homeAddress': controller.text.trim()});
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Edit Medical Information Dialog
  void _editMedicalInfo(BuildContext context, String currentMedicalInfo) {
    // Parse current medical info if it exists
    Map<String, dynamic> medicalData = {};
    if (currentMedicalInfo != 'Blood type, allergies, existing conditions') {
      // Try to parse existing data (assuming it's stored as a map in Firestore)
      // For now, we'll start fresh
    }

    String? selectedBloodType = medicalData['bloodType'];
    final TextEditingController allergiesController = TextEditingController(
      text: medicalData['allergies'] ?? '',
    );
    final TextEditingController conditionsController = TextEditingController(
      text: medicalData['existingConditions'] ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                title: const Text('Edit Medical Information'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Blood Type Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedBloodType,
                        decoration: const InputDecoration(
                          labelText: 'Blood Type',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Select Blood Type'),
                        items: const [
                          DropdownMenuItem(value: 'A+', child: Text('A+')),
                          DropdownMenuItem(value: 'A-', child: Text('A-')),
                          DropdownMenuItem(value: 'B+', child: Text('B+')),
                          DropdownMenuItem(value: 'B-', child: Text('B-')),
                          DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                          DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                          DropdownMenuItem(value: 'O+', child: Text('O+')),
                          DropdownMenuItem(value: 'O-', child: Text('O-')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedBloodType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Allergies Field
                      TextField(
                        controller: allergiesController,
                        decoration: const InputDecoration(
                          labelText: 'Allergies',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Peanuts, Penicillin',
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      
                      // Existing Conditions Field
                      TextField(
                        controller: conditionsController,
                        decoration: const InputDecoration(
                          labelText: 'Existing Conditions',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Diabetes, Hypertension',
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedBloodType == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a blood type')),
                        );
                        return;
                      }
                      
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        final medicalInfoData = {
                          'bloodType': selectedBloodType,
                          'allergies': allergiesController.text.trim(),
                          'existingConditions': conditionsController.text.trim(),
                        };
                        
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .update({'medicalInfo': medicalInfoData});
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medical information updated successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Navigate to Emergency Contacts Screen
  void _openEmergencyContacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmergencyContactsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
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
        final medicalInfo = userData['medicalInfo'];
        
        String medicalInfoDisplay = 'Blood type, allergies, existing conditions';
        if (medicalInfo != null && medicalInfo is Map) {
          final bloodType = medicalInfo['bloodType'] ?? '';
          final allergies = medicalInfo['allergies'] ?? '';
          final conditions = medicalInfo['existingConditions'] ?? '';
          
          if (bloodType.isNotEmpty) {
            medicalInfoDisplay = 'Blood Type: $bloodType';
            if (allergies.isNotEmpty || conditions.isNotEmpty) {
              medicalInfoDisplay += ' | ';
              if (allergies.isNotEmpty) medicalInfoDisplay += 'Allergies: ${allergies.split('\n').first}';
              if (conditions.isNotEmpty && allergies.isNotEmpty) medicalInfoDisplay += ', ';
              if (conditions.isNotEmpty) medicalInfoDisplay += 'Conditions: ${conditions.split('\n').first}';
            }
          }
        }

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

                // PERSONAL INFORMATION SECTION
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Personal Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),

                _buildInfoTile(
                  Icons.badge_outlined, 
                  'User Name', 
                  userName, 
                  theme,
                  isEditable: true,
                  onTap: () => _editUserName(context, userName),
                ),
                _buildInfoTile(
                  Icons.home_outlined, 
                  'Home Address', 
                  homeAddress, 
                  theme,
                  isEditable: true,
                  onTap: () => _editHomeAddress(context, homeAddress),
                ),
                _buildInfoTile(
                  Icons.location_on_outlined, 
                  'Current Registered Location', 
                  registeredLocation, 
                  theme,
                ),

                // MEDICAL INFORMATION SECTION
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Medical Information',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  Icons.medical_services_outlined,
                  'Medical Information', 
                  medicalInfoDisplay, 
                  theme,
                  isEditable: true,
                  onTap: () => _editMedicalInfo(context, medicalInfoDisplay),
                ),

                // EMERGENCY CONTACT SECTION
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
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  child: ListTile(
                    leading: const Icon(Icons.phone_enabled_outlined),
                    title: const Text('View / Manage Emergency Contacts'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => _openEmergencyContacts(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(
    IconData icon, 
    String label, 
    String value, 
    ThemeData theme, 
    {bool isEditable = false, EditCallback? onTap}
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: theme.textTheme.bodyMedium),
        trailing: isEditable
            ? Icon(Icons.edit_outlined, color: theme.colorScheme.primary)
            : null,
        onTap: isEditable ? onTap : null,
      ),
    );
  }
}

// EMERGENCY CONTACTS SCREEN
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  void _addContact() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: const Text('Add Emergency Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    hintText: '09XX-XXX-XXXX or +63',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-]')),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  // Basic Philippine phone number validation
                  final phone = phoneController.text.trim();
                  if (!_isValidPhilippinePhone(phone)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid Philippine phone number')),
                    );
                    return;
                  }

                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('emergencyContacts')
                        .add({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editContact(String contactId, String currentName, String currentPhone) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    final TextEditingController phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            title: const Text('Edit Emergency Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    hintText: '09XX-XXX-XXXX or +63',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-]')),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final phone = phoneController.text.trim();
                  if (!_isValidPhilippinePhone(phone)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid Philippine phone number')),
                    );
                    return;
                  }

                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('emergencyContacts')
                        .doc(contactId)
                        .update({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteContact(String contactId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: const Text('Are you sure you want to delete this emergency contact?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('emergencyContacts')
                      .doc(contactId)
                      .delete();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidPhilippinePhone(String phone) {
    // Remove spaces and dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    
    // Check for valid Philippine phone formats
    // +639XXXXXXXXX (13 chars) or 09XXXXXXXXX (11 chars)
    if (cleanPhone.startsWith('+63')) {
      return cleanPhone.length == 13 && RegExp(r'^\+639\d{9}$').hasMatch(cleanPhone);
    } else if (cleanPhone.startsWith('09')) {
      return cleanPhone.length == 11 && RegExp(r'^09\d{9}$').hasMatch(cleanPhone);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('emergencyContacts')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contacts_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No emergency contacts yet',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first contact'),
                ],
              ),
            );
          }

          final contacts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final contactData = contact.data() as Map<String, dynamic>;
              final name = contactData['name'] ?? '';
              final phone = contactData['phone'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: theme.colorScheme.primary),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(phone),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editContact(contact.id, name, phone);
                      } else if (value == 'delete') {
                        _deleteContact(contact.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}