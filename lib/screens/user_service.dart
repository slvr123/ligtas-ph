import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save user location to Firestore
  Future<void> saveUserLocation({
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    try {
      await _firestore.collection('users').doc(currentUserId).set({
        'email': _auth.currentUser?.email,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true prevents overwriting other fields
      
      print('Location saved successfully for user: $currentUserId');
    } catch (e) {
      print('Error saving location: $e');
      throw Exception('Failed to save location: $e');
    }
  }

  // Get user location from Firestore
  Future<Map<String, dynamic>?> getUserLocation() async {
    if (currentUserId == null) {
      // Return null or throw a less severe error if the calling code handles it
      return null;
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
      
      return null; // No location saved yet
    } catch (e) {
      print('Error getting location: $e');
      // Re-throwing as a more user-friendly Exception is generally a good practice
      throw Exception('Failed to get location: $e');
    }
  }
  
  // 🆕 NEW METHOD: Get all profile data from Firestore for the Profile Screen
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) {
      return null;
    }

    try {
      DocumentSnapshot doc = await _firestore.collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        // Return the entire document data map
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      throw Exception("Failed to fetch user profile: $e");
    }
  }

  // Create user document on signup
  Future<void> createUserDocument({
    required String email,
    String? displayName,
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    try {
      await _firestore.collection('users').doc(currentUserId).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('User document created for: $currentUserId');
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user document: $e');
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
      throw Exception('No user logged in');
    }

    try {
      await _firestore.collection('users').doc(currentUserId).delete();
      print('User data deleted for: $currentUserId');
    } catch (e) {
      print('Error deleting user data: $e');
      throw Exception('Failed to delete user data: $e');
    }
  }
}