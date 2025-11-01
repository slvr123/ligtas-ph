import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:disaster_awareness_app/services/community_service.dart';
import 'package:disaster_awareness_app/screens/user_service.dart';
import 'package:disaster_awareness_app/services/location_distance_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:disaster_awareness_app/screens/post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityService _communityService = CommunityService();
  final UserService _userService = UserService();
  String _userLocation = 'Loading...';
  double _userLatitude = 12.8797;
  double _userLongitude = 121.7740;
  String _selectedCategory = 'all';
  bool _sortByDistance = true;

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
          _userLatitude = location['latitude'];
          _userLongitude = location['longitude'];
        });
      }
    } catch (e) {
      print('Error loading location: $e');
    }
  }

  void _showCreatePostDialog() async {
    // Check if user is guest
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser?.isAnonymous ?? false) {
      // Guests cannot create posts
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to create posts in the community'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

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
                                        color:
                                            selectedCategory == category['id']
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70),
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
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      await _communityService.createPost(
                        title: titleController.text,
                        description: descriptionController.text,
                        location: _userLocation,
                        latitude: _userLatitude,
                        longitude: _userLongitude,
                        category: selectedCategory,
                      );

                      if (mounted) {
                        Navigator.pop(context); // Close loading dialog
                        Navigator.pop(context); // Close bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.pop(context); // Close loading dialog
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
                    foregroundColor: Colors.white,
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
            icon: Icon(_sortByDistance ? Icons.location_on : Icons.sort),
            onPressed: () {
              setState(() {
                _sortByDistance = !_sortByDistance;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _sortByDistance ? 'Sorted by distance' : 'Sorted by recent',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (FirebaseAuth.instance.currentUser?.isAnonymous ?? false)
            ? null  // Disable for guests
            : _showCreatePostDialog,
        backgroundColor: (FirebaseAuth.instance.currentUser?.isAnonymous ?? false)
            ? Colors.grey  // Grey out for guests
            : const Color(0xFFb91c1c),
        icon: const Icon(Icons.add),
        label: (FirebaseAuth.instance.currentUser?.isAnonymous ?? false)
            ? const Text('Sign in to Post')
            : const Text('New Post'),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == 'all'
                  ? _communityService.getAllPosts()
                  : _communityService.getPostsByCategory(
                      _selectedCategory, _userLocation),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading posts',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.7)),
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
                      ],
                    ),
                  );
                }

                var posts = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'active';
                }).toList();

                // Sort by distance if enabled
                if (_sortByDistance && posts.isNotEmpty) {
                  posts.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;

                    final distA = LocationDistanceService.calculateDistance(
                      _userLatitude,
                      _userLongitude,
                      dataA['latitude'] ?? 0.0,
                      dataA['longitude'] ?? 0.0,
                    );

                    final distB = LocationDistanceService.calculateDistance(
                      _userLatitude,
                      _userLongitude,
                      dataB['latitude'] ?? 0.0,
                      dataB['longitude'] ?? 0.0,
                    );

                    return distA.compareTo(distB);
                  });
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
    final isLiked =
        (data['likedBy'] as List?)?.contains(currentUserId) ?? false;
    final timestamp = data['createdAt'] as Timestamp?;
    final timeAgo =
        timestamp != null ? timeago.format(timestamp.toDate()) : 'Just now';
    final profilePictureUrl = data['profilePictureUrl'] as String? ?? '';
    final commentCount = data['commentCount'] ?? 0; // ⭐ Get comment count

    // Calculate distance
    final distance = LocationDistanceService.calculateDistance(
      _userLatitude,
      _userLongitude,
      data['latitude'] ?? 0.0,
      data['longitude'] ?? 0.0,
    );
    final distanceString = LocationDistanceService.getDistanceString(distance);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1f2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // ⭐ Wrap Card in InkWell to make it tappable
      child: InkWell(
        onTap: () {
          // ⭐ Navigate to PostDetailScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(
                postId: postId,
                postData: data,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            (data['userName'] as String?)
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
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
                                distanceString,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white70,
                    ),
                    onPressed: () async {
                      // Check if user is guest
                      final currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser?.isAnonymous ?? false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sign in to like posts'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      try {
                        await _communityService.toggleLike(postId);
                      } catch (e) {
                        // Extract guest-specific error messages
                        String errorMessage = 'Error: $e';
                        if (e.toString().contains('Guests cannot')) {
                          errorMessage = 'Sign in to like posts';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data['title'] ?? 'Untitled',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
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
              Row(
                children: [
                  Text(
                    '${data['likes'] ?? 0}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  // ⭐ Make comment icon/text tappable
                  InkWell(
                    onTap: () {
                      // ⭐ Navigate to PostDetailScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postId: postId,
                            postData: data,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.comment_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$commentCount',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (currentUserId == data['userId'])
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      onSelected: (value) async {
                        if (value == 'delete') {
                          bool? confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text('Delete Post?'),
                                    content: const Text(
                                        'Are you sure you want to delete this post and all its comments? This cannot be undone.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text('Delete')),
                                    ],
                                  ));
                          if (confirmDelete != true) return;

                          try {
                            await _communityService.deletePost(
                                postId, data['userId']);
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
                            await _communityService.markAsResolved(
                                postId, data['userId']);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Marked as resolved')),
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
                              Icon(Icons.check_circle_outline,
                                  color: Colors.green),
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
