import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_awareness_app/services/community_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const PostDetailScreen({
    super.key,
    required this.postId,
    required this.postData,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return; // Don't submit empty comments
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    try {
      await _communityService.addComment(
        postId: widget.postId,
        comment: text,
      );
      _commentController.clear(); // Clear text field on success
      // Scroll to bottom after a short delay
      Timer(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    // Optional: Show confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment?'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete != true) {
      return;
    }

    try {
      await _communityService.deleteComment(widget.postId, commentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error deleting comment: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Safe data access with defaults
    final String title = widget.postData['title'] ?? 'No Title';
    final String description = widget.postData['description'] ?? '';
    final String userName = widget.postData['userName'] ?? 'Anonymous';
    final String profilePictureUrl = widget.postData['profilePictureUrl'] ?? '';
    final Timestamp timestamp = widget.postData['createdAt'] ?? Timestamp.now();
    final String timeAgo = timeago.format(timestamp.toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Original Post Content ---
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFb91c1c),
                        backgroundImage: profilePictureUrl.isNotEmpty
                            ? CachedNetworkImageProvider(profilePictureUrl)
                            : null,
                        child: (profilePictureUrl.isEmpty)
                            ? Text(
                                userName.isNotEmpty
                                    ? userName.substring(0, 1).toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              timeAgo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontSize: 16, height: 1.5),
                  ),
                  const Divider(height: 32, thickness: 1),

                  // --- Comments Section ---
                  Text(
                    'Comments',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: _communityService.getComments(widget.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Be the first to comment!'),
                          ),
                        );
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment =
                              comments[index].data() as Map<String, dynamic>;
                          final commentId = comments[index].id;
                          final commentText =
                              comment['comment'] ?? ''; // Use 'comment' key
                          final commentUser =
                              comment['userName'] ?? 'Anonymous';
                          final commentUserId = comment['userId'];
                          final commentProfilePic =
                              comment['profilePictureUrl'] ?? '';
                          final commentTimestamp =
                              comment['createdAt'] as Timestamp?;
                          final commentTimeAgo = commentTimestamp != null
                              ? timeago.format(commentTimestamp.toDate())
                              : 'just now';

                          // Check if the current user owns this comment
                          final bool isOwner =
                              _currentUser?.uid == commentUserId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: theme.cardColor.withOpacity(0.5),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF374151),
                                backgroundImage: commentProfilePic.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        commentProfilePic)
                                    : null,
                                child: (commentProfilePic.isEmpty)
                                    ? Text(
                                        commentUser.isNotEmpty
                                            ? commentUser
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : 'A',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      )
                                    : null,
                              ),
                              title: Text(commentUser,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: theme.colorScheme.primary
                                          .withAlpha(200))),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(commentText,
                                      style: const TextStyle(
                                          fontSize: 15, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(commentTimeAgo,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                              trailing: isOwner
                                  ? IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: Colors.red.shade300, size: 20),
                                      tooltip: 'Delete Comment',
                                      onPressed: () =>
                                          _deleteComment(commentId),
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- Add Comment Input ---
          const Divider(height: 1, thickness: 1),
          Container(
            // Handle keyboard visibility
            padding: EdgeInsets.only(
              left: 16.0,
              right: 8.0,
              top: 8.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
            ),
            color: theme.scaffoldBackgroundColor, // Match scaffold
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      fillColor: theme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null, // Allows multiline
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send_rounded,
                      color: theme.colorScheme.primary),
                  onPressed: _submitComment,
                  tooltip: 'Post Comment',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
