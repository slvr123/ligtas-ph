import 'package:flutter/material.dart';
import 'package:disaster_awareness_app/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsUpdatesScreen extends StatefulWidget {
  final String location;

  const NewsUpdatesScreen({
    super.key,
    required this.location,
  });

  @override
  State<NewsUpdatesScreen> createState() => _NewsUpdatesScreenState();
}

class _NewsUpdatesScreenState extends State<NewsUpdatesScreen> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _filteredArticles = [];
  bool _isLoading = true;
  String _error = '';
  String _selectedFilter = 'all';

  // Disaster categories with keywords - FOR TITLE ONLY
  final Map<String, List<String>> _disasterCategories = {
    'all': ['typhoon', 'bagyo', 'storm', 'earthquake', 'lindol', 'flood', 'baha', 
            'fire', 'sunog', 'volcano', 'bulkan', 'landslide', 'guho', 'tsunami',
            'disaster', 'sakuna', 'emergency', 'kalamidad', 'evacuate', 'likas',
            'warning', 'babala', 'alert', 'signal', 'weather'],
    'storm': ['typhoon', 'bagyo', 'storm', 'signal', 'habagat', 'amihan', 'wind', 'hangin'],
    'earthquake': ['earthquake', 'lindol', 'tremor', 'aftershock', 'magnitude', 'seismic'],
    'flood': ['flood', 'baha', 'inundation', 'overflow', 'rain', 'ulan'],
    'fire': ['fire', 'sunog', 'blaze', 'flames'],
    'volcano': ['volcano', 'bulkan', 'eruption', 'lava', 'ash', 'mayon', 'taal', 'pinatubo'],
  };

  final List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'name': 'All Disasters', 'icon': Icons.warning_amber_rounded, 'color': Colors.red},
    {'id': 'storm', 'name': 'Storms', 'icon': Icons.air, 'color': Colors.purple},
    {'id': 'earthquake', 'name': 'Earthquakes', 'icon': Icons.emergency, 'color': Colors.orange},
    {'id': 'flood', 'name': 'Floods', 'icon': Icons.water, 'color': Colors.blue},
    {'id': 'fire', 'name': 'Fires', 'icon': Icons.local_fire_department, 'color': Colors.deepOrange},
    {'id': 'volcano', 'name': 'Volcanoes', 'icon': Icons.terrain, 'color': Colors.brown},
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final articles = await _newsService.fetchNews();
      
      if (mounted) {
        setState(() {
          _allArticles = articles;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    final keywords = _disasterCategories[_selectedFilter] ?? _disasterCategories['all']!;
    
    // ✅ IMPROVED: Filter by TITLE only (more accurate)
    _filteredArticles = _allArticles.where((article) {
      final title = article.title.toLowerCase();
      
      // Check if title contains any disaster keywords
      return keywords.any((keyword) => title.contains(keyword.toLowerCase()));
    }).toList();

    // ✅ ENHANCED: Multi-level location prioritization
    if (widget.location.isNotEmpty) {
      final locationParts = widget.location.split(',').map((e) => e.trim().toLowerCase()).toList();
      final city = locationParts.isNotEmpty ? locationParts[0] : '';
      final province = locationParts.length > 1 ? locationParts[1] : '';
      
      // Metro Manila cities
      final metroManilaCities = [
        'manila', 'quezon city', 'makati', 'pasay', 'taguig', 'mandaluyong',
        'pasig', 'marikina', 'caloocan', 'valenzuela', 'malabon', 'navotas',
        'muntinlupa', 'parañaque', 'las piñas', 'san juan', 'pateros'
      ];
      
      final isMetroManila = province.contains('metro manila') || metroManilaCities.contains(city);
      
      // Sort by location relevance
      _filteredArticles.sort((a, b) {
        final aContent = '${a.title} ${a.description}'.toLowerCase();
        final bContent = '${b.title} ${b.description}'.toLowerCase();
        
        // Level 1: Exact city match
        final aHasCity = aContent.contains(city);
        final bHasCity = bContent.contains(city);
        
        if (aHasCity && !bHasCity) return -1;
        if (!aHasCity && bHasCity) return 1;
        
        // Level 2: Province match
        final aHasProvince = province.isNotEmpty && aContent.contains(province);
        final bHasProvince = province.isNotEmpty && bContent.contains(province);
        
        if (aHasProvince && !bHasProvince) return -1;
        if (!aHasProvince && bHasProvince) return 1;
        
        // Level 3: Metro Manila cities
        if (isMetroManila) {
          final aHasMetroCity = metroManilaCities.any((c) => aContent.contains(c));
          final bHasMetroCity = metroManilaCities.any((c) => bContent.contains(c));
          
          if (aHasMetroCity && !bHasMetroCity) return -1;
          if (!aHasMetroCity && bHasMetroCity) return 1;
        }
        
        // Level 4: Nearby regions
        final nearbyKeywords = _getNearbyRegionKeywords(city, province);
        final aHasNearby = nearbyKeywords.any((k) => aContent.contains(k));
        final bHasNearby = nearbyKeywords.any((k) => bContent.contains(k));
        
        if (aHasNearby && !bHasNearby) return -1;
        if (!aHasNearby && bHasNearby) return 1;
        
        // Level 5: Sort by date (newest first)
        return b.publishedDate.compareTo(a.publishedDate);
      });
    }
  }
  
  List<String> _getNearbyRegionKeywords(String city, String province) {
    final Map<String, List<String>> nearbyRegions = {
      'manila': ['ncr', 'luzon', 'metro manila', 'rizal', 'cavite', 'laguna'],
      'quezon city': ['ncr', 'luzon', 'metro manila', 'rizal'],
      'makati': ['ncr', 'luzon', 'metro manila', 'taguig', 'pasay'],
      'muntinlupa': ['ncr', 'luzon', 'metro manila', 'laguna', 'cavite'],
      'cebu': ['cebu', 'visayas', 'central visayas', 'mactan', 'mandaue'],
      'davao': ['davao', 'mindanao', 'southern mindanao'],
      'cagayan de oro': ['northern mindanao', 'misamis oriental', 'mindanao'],
    };
    
    return nearbyRegions[city.toLowerCase()] ?? [province.toLowerCase()];
  }

  String _getDisasterType(NewsArticle article) {
    final title = article.title.toLowerCase();
    
    if (_disasterCategories['storm']!.any((k) => title.contains(k))) return 'Storm';
    if (_disasterCategories['earthquake']!.any((k) => title.contains(k))) return 'Earthquake';
    if (_disasterCategories['flood']!.any((k) => title.contains(k))) return 'Flood';
    if (_disasterCategories['fire']!.any((k) => title.contains(k))) return 'Fire';
    if (_disasterCategories['volcano']!.any((k) => title.contains(k))) return 'Volcano';
    
    return 'Disaster';
  }

  Color _getDisasterColor(String type) {
    switch (type.toLowerCase()) {
      case 'storm': return Colors.purple.shade700;
      case 'earthquake': return Colors.orange.shade700;
      case 'flood': return Colors.blue.shade700;
      case 'fire': return Colors.deepOrange.shade700;
      case 'volcano': return Colors.brown.shade700;
      default: return Colors.red.shade700;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open article')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('News Updates'),
            Text(
              widget.location,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      children: [
                        Icon(
                          filter['icon'],
                          size: 16,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Text(filter['name']),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter['id'];
                        _applyFilter();
                      });
                    },
                    selectedColor: const Color(0xFFea580c),
                    backgroundColor: const Color(0xFF374151),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading news...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load news',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadNews,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFea580c),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No news available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'disaster'
                  ? 'No disaster-related news at the moment'
                  : 'Check back later for updates',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredArticles.length,
        itemBuilder: (context, index) {
          final article = _filteredArticles[index];
          return _buildNewsCard(article);
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    // ✅ FIXED: Show actual date instead of "a moment ago"
    final publishedDate = article.publishedDate;
    final now = DateTime.now();
    final difference = now.difference(publishedDate);
    
    String dateDisplay;
    
    if (difference.inDays == 0) {
      // Today - show time
      final hour = publishedDate.hour.toString().padLeft(2, '0');
      final minute = publishedDate.minute.toString().padLeft(2, '0');
      dateDisplay = 'Today at $hour:$minute';
    } else if (difference.inDays == 1) {
      // Yesterday
      dateDisplay = 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week - show days ago
      dateDisplay = '${difference.inDays} days ago';
    } else {
      // Older - show actual date
      final month = _getMonthName(publishedDate.month);
      dateDisplay = '$month ${publishedDate.day}, ${publishedDate.year}';
    }
    
    final disasterType = _getDisasterType(article);
    final disasterColor = _getDisasterColor(disasterType);
    
    // Check if local news
    final locationKeywords = widget.location.split(',').map((e) => e.trim().toLowerCase()).toList();
    final isLocalNews = locationKeywords.any((keyword) => 
      article.title.toLowerCase().contains(keyword) || 
      article.description.toLowerCase().contains(keyword)
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1f2937),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLocalNews 
            ? BorderSide(color: Colors.yellow.shade700, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _launchUrl(article.url),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (if available)
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      article.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: const Color(0xFF374151),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.white38,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: const Color(0xFF374151),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                    // Location badge on image
                    if (isLocalNews)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade700,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'YOUR AREA',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source, Disaster Type, and Date
                  Row(
                    children: [
                      // Disaster Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: disasterColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          disasterType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Source Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSourceColor(article.source),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.source,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // ✅ NEW: Show actual date instead of "a moment ago"
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (article.description.isNotEmpty)
                    Text(
                      article.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Read More Button
                  Row(
                    children: [
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _launchUrl(article.url),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Read Full Article'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFea580c),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper function to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Color _getSourceColor(String source) {
    final sourceLower = source.toLowerCase();
    if (sourceLower.contains('pagasa')) {
      return Colors.blue.shade700;
    } else if (sourceLower.contains('gma')) {
      return Colors.orange.shade700;
    } else if (sourceLower.contains('pna') || sourceLower.contains('philippine news')) {
      return Colors.green.shade700;
    } else if (sourceLower.contains('rappler')) {
      return Colors.red.shade700;
    } else if (sourceLower.contains('inquirer')) {
      return Colors.indigo.shade700;
    } else if (sourceLower.contains('abs') || sourceLower.contains('cbn')) {
      return Colors.cyan.shade700;
    }
    return Colors.grey.shade700;
  }
}