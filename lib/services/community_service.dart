import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

  // Create a new community post
  Future<String> createPost({
    required String title,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    String? category,
    String? imageUrl,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Get user's name and profile picture from users collection
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final userName = userDoc.data()?['displayName'] ??
          userDoc.data()?['name'] ??
          'Anonymous';
      final profilePictureUrl =
          userDoc.data()?['profilePictureUrl']; // ✅ Get profile picture URL

      final docRef = await _firestore.collection('community_posts').add({
        'title': title,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'category': category ?? 'general',
        'imageUrl': imageUrl,
        'userId': currentUserId,
        'userName': userName,
        'userEmail': currentUserEmail,
        'profilePictureUrl': profilePictureUrl, // ✅ Store profile picture URL
        'likes': 0,
        'likedBy': [],
        'commentCount': 0, // Starts at 0
        'status': 'active', // active, resolved, flagged
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  // Get posts for a specific location (city-based)
  Stream<QuerySnapshot> getPostsByLocation(String location) {
    String city = location.split(',')[0].trim();

    return _firestore
        .collection('community_posts')
        .where('location', isGreaterThanOrEqualTo: city)
        .where('location', isLessThanOrEqualTo: '$city\uf8ff')
        .where('status', isEqualTo: 'active')
        .orderBy('location')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Get all posts
  Stream<QuerySnapshot> getAllPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Get posts by category
  Stream<QuerySnapshot> getPostsByCategory(String category, String location) {
    return _firestore
        .collection('community_posts')
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots();
  }

  // Like/Unlike a post
  Future<void> toggleLike(String postId) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      final postRef = _firestore.collection('community_posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final data = postDoc.data()!;
      final List<dynamic> likedBy = data['likedBy'] ?? [];

      if (likedBy.contains(currentUserId)) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Failed to like post: $e');
    }
  }

  // ⭐ MODIFIED: Add a comment using a transaction
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Get user's name and profile picture
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final userName = userDoc.data()?['displayName'] ??
          userDoc.data()?['name'] ??
          'Anonymous';
      final profilePictureUrl = userDoc.data()?['profilePictureUrl'];

      final postRef = _firestore.collection('community_posts').doc(postId);
      final commentRef =
          postRef.collection('comments').doc(); // New comment doc

      // Run as a transaction to ensure count updates
      await _firestore.runTransaction((transaction) async {
        // 1. Add the new comment
        transaction.set(commentRef, {
          'userId': currentUserId,
          'userName': userName,
          'profilePictureUrl': profilePictureUrl,
          'comment': comment, // Use 'comment' key
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Increment the commentCount on the main post
        transaction.update(postRef, {
          'commentCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  // Get comments for a post
  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false) // Show oldest first
        .snapshots();
  }

  // ⭐ NEW: Delete a comment using a transaction
  Future<void> deleteComment(String postId, String commentId) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final postRef = _firestore.collection('community_posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    // Note: Your Firestore rules will handle security (check if user is owner)

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Delete the comment
        transaction.delete(commentRef);
        // 2. Decrement the commentCount
        transaction.update(postRef, {
          'commentCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error deleting comment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Delete a post (only by owner)
  Future<void> deletePost(String postId, String postUserId) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    if (currentUserId != postUserId) {
      throw Exception('You can only delete your own posts');
    }

    try {
      // Note: This does not delete subcollections. For full deletion,
      // you'd need a Cloud Function. Marking as 'deleted' is safer.
      await _firestore.collection('community_posts').doc(postId).update({
        'status': 'deleted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }

  // Mark post as resolved
  Future<void> markAsResolved(String postId, String postUserId) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    if (currentUserId != postUserId) {
      throw Exception('You can only resolve your own posts');
    }

    try {
      await _firestore.collection('community_posts').doc(postId).update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking as resolved: $e');
      throw Exception('Failed to mark as resolved: $e');
    }
  }

  // Report a post
  Future<void> reportPost({
    required String postId,
    required String reason,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    try {
      await _firestore.collection('post_reports').add({
        'postId': postId,
        'reportedBy': currentUserId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error reporting post: $e');
      throw Exception('Failed to report post: $e');
    }
  }

  // Get user's own posts
  Stream<QuerySnapshot> getUserPosts() {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    return _firestore
        .collection('community_posts')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
