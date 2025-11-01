import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GuestService {
  static const String _guestSessionsCollection = 'guest_sessions';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enableGuestMode({
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && !currentUser.isAnonymous) {
      await _auth.signOut();
    }

    final credential = await _auth.signInAnonymously();
    final guestUid = credential.user!.uid;

    await _firestore.collection(_guestSessionsCollection).doc(guestUid).set({
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  Future<bool> isGuestMode() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      return false;
    }

    final snapshot = await _firestore
        .collection(_guestSessionsCollection)
        .doc(user.uid)
        .get();

    return snapshot.exists && (snapshot.data()?['isActive'] ?? false) == true;
  }

  Future<Map<String, dynamic>?> getGuestLocation() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      return null;
    }

    final snapshot = await _firestore
        .collection(_guestSessionsCollection)
        .doc(user.uid)
        .get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    final location = data['location'] as String?;
    final latitude = data['latitude'] as num?;
    final longitude = data['longitude'] as num?;

    if (location == null || latitude == null || longitude == null) {
      return null;
    }

    await _firestore
        .collection(_guestSessionsCollection)
        .doc(user.uid)
        .update({'lastActiveAt': FieldValue.serverTimestamp()});

    return {
      'location': location,
      'latitude': latitude.toDouble(),
      'longitude': longitude.toDouble(),
    };
  }

  Future<void> updateGuestLocation({
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      return;
    }

    await _firestore.collection(_guestSessionsCollection).doc(user.uid).update({
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> disableGuestMode() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      return;
    }

    await _firestore
        .collection(_guestSessionsCollection)
        .doc(user.uid)
        .update({'isActive': false});

    await _auth.signOut();
  }

  String? getGuestUserId() {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      return user.uid;
    }
    return null;
  }
}
