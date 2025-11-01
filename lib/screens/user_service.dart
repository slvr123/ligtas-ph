import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if current user is a guest
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;
  
  // In-memory storage for guest data (lost on app restart/logout)
  static Map<String, dynamic>? _guestLocation;
  static Map<String, bool>? _guestChecklistState;
  static Map<String, List<String>>? _guestCustomCategories;

  // Clear all guest data (called on logout)
  static void clearGuestData() {
    _guestLocation = null;
    _guestChecklistState = null;
    _guestCustomCategories = null;
    print('🗑️ Guest data cleared');
  }

  // Create or Update user document on signup/login
  // Guests should not call this
  Future<void> createUserDocument({
    required String email,
    String? displayName,
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in to create a document for.');
    }
    
    if (isGuest) {
      print('⚠️ Guest users cannot create user documents');
      return; // Silently return for guests
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

  // Save user location to Firestore (or memory for guests)
  Future<void> saveUserLocation({
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in to save location for.');
    }
    
    // If guest, save to memory instead of Firestore
    if (isGuest) {
      print('💾 Saving guest location to memory (temporary)');
      _guestLocation = {
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      };
      print('✅ Guest location saved temporarily');
      return;
    }
    
    // For registered users, save to Firestore
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
      print('✅ Location saved to Firestore');
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  // Get user location from Firestore (or memory for guests)
  Future<Map<String, dynamic>?> getUserLocation() async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }
    
    // If guest, return from memory
    if (isGuest) {
      print('📍 Getting guest location from memory');
      return _guestLocation;
    }
    
    // For registered users, get from Firestore
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
    if (isGuest) {
      return _guestLocation != null;
    }
    
    final location = await getUserLocation();
    return location != null;
  }

  // Save checklist data
  // For guests: save to memory; For registered: save to Firestore
  Future<void> saveChecklistData({
    required Map<String, bool> checklistState,
    required Map<String, List<String>> customCategories,
  }) async {
    if (currentUserId == null) {
      throw Exception('No user logged in to save checklist data for.');
    }
    
    // If guest, save to memory
    if (isGuest) {
      print('💾 Saving guest checklist to memory (temporary)');
      _guestChecklistState = Map.from(checklistState);
      _guestCustomCategories = Map.from(customCategories);
      print('✅ Guest checklist saved temporarily');
      return;
    }
    
    // For registered users, save to Firestore
    try {
      print("UserService: Attempting UPDATE for checklist data...");
      await _firestore.collection('users').doc(currentUserId).update(
        {
          'checklistState': checklistState,
          'customChecklistCategories': customCategories,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      print("UserService: Successfully UPDATED checklist data.");
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        print("UserService: UPDATE failed (not-found), attempting SET instead.");
        try {
          await _firestore.collection('users').doc(currentUserId).set(
              {
                'checklistState': checklistState,
                'customChecklistCategories': customCategories,
                'updatedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true));
          print("UserService: Successfully SET checklist data after update failed.");
        } catch (e2) {
          print('UserService: Error saving checklist data with SET fallback: $e2');
          throw Exception('Failed to save checklist data: $e2');
        }
      } else {
        print('UserService: Error UPDATING checklist data: $e');
        throw Exception('Failed to save checklist data: $e');
      }
    }
  }

  // Get checklist data
  // For guests: return from memory; For registered: return from Firestore
  Future<Map<String, dynamic>> getChecklistData() async {
    if (currentUserId == null) {
      throw Exception('No user logged in to get checklist data for.');
    }

    // If guest, return from memory
    if (isGuest) {
      print('📋 Getting guest checklist from memory');
      return {
        'checklistState': _guestChecklistState ?? <String, bool>{},
        'customChecklistCategories': _guestCustomCategories ?? <String, List<String>>{},
      };
    }

    // For registered users, get from Firestore
    Map<String, bool> checklistState = {};
    Map<String, List<String>> customCategories = {};

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          if (data.containsKey('checklistState')) {
            final firestoreMap =
                data['checklistState'] as Map<String, dynamic>? ?? {};
            checklistState = firestoreMap
                .map((key, value) => MapEntry(key, value as bool? ?? false));
          }
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
        'customChecklistCategories': customCategories,
      };
    } catch (e) {
      print('Error getting checklist data: $e');
      return {
        'checklistState': <String, bool>{},
        'customChecklistCategories': <String, List<String>>{},
      };
    }
  }

  // Delete user data (for account deletion)
  // Guests should not have data to delete
  Future<void> deleteUserData() async {
    if (currentUserId == null) {
      throw Exception('No user logged in to delete data for.');
    }
    
    if (isGuest) {
      print('⚠️ Guest users have no stored data to delete');
      return;
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