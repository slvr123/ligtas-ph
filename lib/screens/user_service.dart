import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create user document on signup
  Future<void> createUserDocument({
    required String email,
    String? displayName,
  }) async {
    // This check is slightly different from your new code, but safer.
    // It specifically checks the currently signed-in user after creation.
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found to create a document for.');
    }

    try {
      await _firestore.collection('users').doc(currentUser.uid).set({
        'uid': currentUser.uid, // Storing UID is good practice
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Re-throw with a more specific message for easier debugging
      throw Exception('Failed to create user document: $e');
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
      ); // merge: true prevents overwriting other fields
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  // Get user location from Firestore
  Future<Map<String, dynamic>?> getUserLocation() async {
    if (currentUserId == null) {
      throw Exception('No user logged in to get location for.');
    }

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if location data exists
        if (data.containsKey('location') &&
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
      throw Exception('Failed to get location: $e');
    }
  }

  // Check if user has saved location
  Future<bool> hasLocation() async {
    final location = await getUserLocation();
    return location != null;
  }

  // Delete user data (for account deletion)
  Future<void> deleteUserData() async {
    if (currentUserId == null) {
      throw Exception('No user logged in to delete data for.');
    }

    try {
      await _firestore.collection('users').doc(currentUserId).delete();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }
}
