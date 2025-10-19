import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // Needed for jsonEncode/Decode if storing complex maps

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // --- (Keep existing methods: createUserDocument, saveUserLocation, getUserLocation, hasLocation) ---

  // Create or Update user document on signup/login
  Future<void> createUserDocument({
    required String email,
    String? displayName,
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in to create a document for.');
    }
    try {
      await _firestore.collection('users').doc(currentUserId).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('User document created/updated for: $currentUserId');
    } catch (e) {
      print('Error creating/updating user document: $e');
      throw Exception('Failed to create/update user document: $e');
    }
  }

  // Save user location to Firestore
  Future<void> saveUserLocation({
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in to save location for.');
    }
    try {
      await _firestore.collection('users').doc(currentUserId).set(
        {
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  // Get user location from Firestore
  Future<Map<String, dynamic>?> getUserLocation() async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null &&
            data.containsKey('location') &&
            data.containsKey('latitude') &&
            data.containsKey('longitude')) {
          return {
            'location': data['location'],
            'latitude': data['latitude'],
            'longitude': data['longitude'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting location: $e');
      throw Exception('Failed to get location: $e');
    }
  }

  // Check if user has saved location
  Future<bool> hasLocation() async {
    final location = await getUserLocation();
    return location != null;
  }

  // ⭐ MODIFIED: Save checklist state AND custom items map
  Future<void> saveChecklistData({
    required Map<String, bool> checklistState,
    required Map<String, List<String>>
        customCategories, // Use Map for categories
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in to save checklist data for.');
    }
    try {
      await _firestore.collection('users').doc(currentUserId).set(
        {
          'checklistState': checklistState,
          'customChecklistCategories':
              customCategories, // Save the category map
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error saving checklist data: $e');
      throw Exception('Failed to save checklist data: $e');
    }
  }

  // ⭐ MODIFIED: Get checklist state AND custom items map
  Future<Map<String, dynamic>> getChecklistData() async {
    if (currentUserId == null) {
      throw Exception('No user logged in to get checklist data for.');
    }

    Map<String, bool> checklistState = {};
    Map<String, List<String>> customCategories = {}; // Default to empty map

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          // Load checklist state
          if (data.containsKey('checklistState')) {
            final firestoreMap =
                data['checklistState'] as Map<String, dynamic>? ?? {};
            checklistState = firestoreMap
                .map((key, value) => MapEntry(key, value as bool? ?? false));
          }

          // Load custom categories map
          if (data.containsKey('customChecklistCategories')) {
            final firestoreCategories =
                data['customChecklistCategories'] as Map<String, dynamic>? ??
                    {};
            customCategories = firestoreCategories.map((key, value) {
              final items = List<dynamic>.from(value ?? []);
              return MapEntry(
                  key, items.map((item) => item.toString()).toList());
            });
          }
        }
      }
      return {
        'checklistState': checklistState,
        'customChecklistCategories': customCategories, // Return the map
      };
    } catch (e) {
      print('Error getting checklist data: $e');
      return {
        'checklistState': <String, bool>{},
        'customChecklistCategories':
            <String, List<String>>{}, // Return empty map on error
      };
    }
  }

  // Delete user data (for account deletion)
  Future<void> deleteUserData() async {
    if (currentUserId == null) {
      throw Exception('No user logged in to delete data for.');
    }
    try {
      await _firestore.collection('users').doc(currentUserId).delete();
      print('User document deleted for: $currentUserId');
    } catch (e) {
      print('Error deleting user data: $e');
      throw Exception('Failed to delete user data: $e');
    }
  }
}
