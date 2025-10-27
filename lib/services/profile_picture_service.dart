
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfilePictureService {
  static final ProfilePictureService _instance = ProfilePictureService._internal();

  factory ProfilePictureService() {
    return _instance;
  }

  ProfilePictureService._internal();

  // Cloudinary configuration
  final cloudinary = CloudinaryPublic(
    'dvydfnddk',           // Your cloud name
    'profile_pictures',    // Your upload preset name ✅
    cache: false,
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload profile picture to Cloudinary and save URL to Firestore
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('📸 Uploading profile picture for user: ${user.uid}');

      // Create unique public ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'profile_${user.uid}_$timestamp';

      // Upload to Cloudinary
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'profile_pictures',
          publicId: publicId,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final downloadUrl = response.secureUrl;
      print('✅ Upload completed: $downloadUrl');

      // Save URL to Firestore user document
      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': downloadUrl,
        'profilePictureUpdatedAt': FieldValue.serverTimestamp(),
        'cloudinaryPublicId': response.publicId, // Save for deletion later
      }).catchError((e) {
        // If document doesn't exist, create it
        return _firestore.collection('users').doc(user.uid).set({
          'profilePictureUrl': downloadUrl,
          'profilePictureUpdatedAt': FieldValue.serverTimestamp(),
          'cloudinaryPublicId': response.publicId,
        }, SetOptions(merge: true));
      });

      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      rethrow;
    }
  }

  /// Get current user's profile picture URL
  Future<String?> getProfilePictureUrl() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['profilePictureUrl'] as String?;
    } catch (e) {
      print('❌ Error getting profile picture URL: $e');
      return null;
    }
  }

  /// Delete current profile picture
  Future<void> deleteProfilePicture() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('🗑️ Deleting profile picture for user: ${user.uid}');

      // Get current user data
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final cloudinaryPublicId = doc.data()?['cloudinaryPublicId'] as String?;

      // Delete from Cloudinary (optional - requires signed requests)
      if (cloudinaryPublicId != null) {
        try {
          // Note: Deleting from Cloudinary requires the Admin API
          // For now, we'll just remove the reference from Firestore
          print('⚠️ Image removed from app, but still exists in Cloudinary');
        } catch (e) {
          print('⚠️ Could not delete from Cloudinary: $e');
        }
      }

      // Remove URL from Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': FieldValue.delete(),
        'cloudinaryPublicId': FieldValue.delete(),
        'profilePictureUpdatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Profile picture reference deleted');
    } catch (e) {
      print('❌ Error deleting profile picture: $e');
      rethrow;
    }
  }

  /// Stream profile picture URL for real-time updates
  Stream<String?> profilePictureStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return doc.data()?['profilePictureUrl'] as String?;
        })
        .handleError((error) {
          print('⚠️ Profile picture stream error: $error');
          return null;
        });
  }
}