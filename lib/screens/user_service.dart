import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 1. Create or Update user document on signup/login
  Future<void> createUserDocument({
    required String email,
    String? displayName,
  }) async {
    // Use currentUserId check for simplicity, as user must be logged in.
    if (currentUserId == null) {
      throw Exception('No user logged in to create a document for.');
    }

    try {
      await _firestore.collection('users').doc(currentUserId).set({
        // 'uid': currentUserId, // UID is the document ID, so this is optional
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        // Add or update the updatedAt field
        'updatedAt': FieldValue.serverTimestamp(), 
      }, SetOptions(merge: true)); // Use merge: true to avoid overwriting location data

      print('User document created/updated for: $currentUserId');
    } catch (e) {
      print('Error creating/updating user document: $e');
      throw Exception('Failed to create/update user document: $e');
    }
  }

  // 2. Save user location to Firestore
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
      ); // merge: true prevents overwriting other fields
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  // 3. Get user location from Firestore
  Future<Map<String, dynamic>?> getUserLocation() async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        // Safe cast to Map<String, dynamic>
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?; 

        // Null check for safety (though doc.exists implies data is not null)
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
      return null; // No location saved yet or document doesn't exist
    } catch (e) {
      print('Error getting location: $e');
      throw Exception('Failed to get location: $e');
    }
  }

  // 4. Check if user has saved location
  Future<bool> hasLocation() async {
    final location = await getUserLocation();
    return location != null;
  }

  // 5. Delete user data (for account deletion)
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