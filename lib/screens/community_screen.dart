import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:disaster_awareness_app/services/community_service.dart';
import 'package:disaster_awareness_app/screens/user_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityService _communityService = CommunityService();
  final UserService _userService = UserService();
  String _userLocation = 'Loading...';
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'All', 'icon': Icons.grid_view},
    {'id': 'flood', 'name': 'Flood', 'icon': Icons.water},
    {'id': 'fire', 'name': 'Fire', 'icon': Icons.local_fire_department},
    {'id': 'earthquake', 'name': 'Earthquake', 'icon': Icons.emergency},
    {'id': 'typhoon', 'name': 'Typhoon', 'icon': Icons.air},
    {'id': 'other', 'name': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final location = await _userService.getUserLocation();
      if (mounted && location != null) {
        setState(() {
          _userLocation = location['location'];
        });
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'other';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1f2937),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFb91c1c),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.post_add, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Create Community Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selection
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories
                            .where((cat) => cat['id'] != 'all')
                            .map((category) => ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category['icon'],
                                        size: 16,
                                        color: selectedCategory == category['id']
                                            ? Colors.white
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(category['name']),
                                    ],
                                  ),
                                  selected: selectedCategory == category['id'],
                                  onSelected: (selected) {
                                    setModalState(() {
                                      selectedCategory = category['id'];
                                    });
                                  },
                                  selectedColor: const Color(0xFFb91c1c),
                                  backgroundColor: const Color(0xFF374151),
                                  labelStyle: TextStyle(
                                    color: selectedCategory == category['id']
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 24),

                      // Title Field
                      const Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g., Flooding on Main Street',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF374151),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description Field
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Describe the situation in detail...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF374151),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Location Display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                    ),
                                  ),
                                  Text(
                                    _userLocation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Button
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      final location = await _userService.getUserLocation();
                      
                      await _communityService.createPost(
                        title: titleController.text,
                        description: descriptionController.text,
                        location: location?['location'] ?? _userLocation,
                        latitude: location?['latitude'] ?? 0.0,
                        longitude: location?['longitude'] ?? 0.0,
                        category: selectedCategory,
                      );

                      if (mounted) {
                        Navigator.pop(context); // Close loading
                        Navigator.pop(context); // Close modal
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFb91c1c),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Post to Community',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Showing posts near $_userLocation')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFFb91c1c),
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      children: [
                        Icon(
                          category['icon'],
                          size: 16,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(category['name']),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category['id'];
                      });
                    },
                    selectedColor: const Color(0xFFb91c1c),
                    backgroundColor: const Color(0xFF374151),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ),

          // Posts List
// In the StreamBuilder section of your build method, update this part:

// Posts List
Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: _selectedCategory == 'all'
        ? _communityService.getAllPosts()
        : _communityService.getPostsByCategory(_selectedCategory, _userLocation),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading posts',
                style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 8),
              Text(
                '${snapshot.error}',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to report!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
      }

      // ✅ FILTER OUT DELETED/RESOLVED POSTS LOCALLY
      final posts = snapshot.data!.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['status'] == 'active';
      }).toList();

      if (posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.forum_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No active posts',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final data = post.data() as Map<String, dynamic>;
            return _buildPostCard(post.id, data);
          },
        ),
      );
    },
  ),
),
        ],
      ),
    );
  }

  Widget _buildPostCard(String postId, Map<String, dynamic> data) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = (data['likedBy'] as List?)?.contains(currentUserId) ?? false;
    final timestamp = data['createdAt'] as Timestamp?;
    final timeAgo = timestamp != null
        ? timeago.format(timestamp.toDate())
        : 'Just now';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1f2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - FIXED OVERFLOW
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFb91c1c),
                  child: Text(
                    (data['userName'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['userName'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              data['location'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(data['category']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data['category']?.toUpperCase() ?? 'OTHER',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              data['title'] ?? 'Untitled',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              data['description'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white70,
                  ),
                  onPressed: () async {
                    try {
                      await _communityService.toggleLike(postId);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
                Text(
                  '${data['likes'] ?? 0}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  '${data['commentCount'] ?? 0}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                if (currentUserId == data['userId'])
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        try {
                          await _communityService.deletePost(postId, data['userId']);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Post deleted')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      } else if (value == 'resolve') {
                        try {
                          await _communityService.markAsResolved(postId, data['userId']);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Marked as resolved')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'resolve',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Mark as Resolved'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Post'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'flood':
        return Colors.blue.shade700;
      case 'fire':
        return Colors.red.shade700;
      case 'earthquake':
        return Colors.orange.shade700;
      case 'typhoon':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
