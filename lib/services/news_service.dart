import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NewsService {
  // News source configuration
  final List<Map<String, String>> _newsSources = [
    {
      'name': 'PAGASA Weather',
      'url': 'https://www.pagasa.dost.gov.ph/rss/',
      'category': 'weather',
      'icon': 'weather',
    },
    {
      'name': 'Philippine News Agency',
      'url': 'https://www.pna.gov.ph/articles/1132925/feed',
      'category': 'general',
      'icon': 'news',
    },
    {
      'name': 'GMA News',
      'url': 'https://data.gmanetwork.com/gno/rss/news/feed.xml',
      'category': 'general',
      'icon': 'news',
    },
  ];

  // Fetch news from RSS feeds
  Future<List<NewsArticle>> fetchNews({String? category}) async {
    List<NewsArticle> allNews = [];

    for (var source in _newsSources) {
      // Filter by category if specified
      if (category != null && category != 'all' && source['category'] != category) {
        continue;
      }

      try {
        final articles = await _fetchFromRSS(
          source['url']!,
          source['name']!,
        );
        allNews.addAll(articles);
      } catch (e) {
        print('Error fetching from ${source['name']}: $e');
        // Continue with other sources even if one fails
      }
    }

    // Sort by date (newest first)
    allNews.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

    return allNews;
  }

  // Parse RSS feed
  Future<List<NewsArticle>> _fetchFromRSS(String url, String sourceName) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }

      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      List<NewsArticle> articles = [];

      for (var item in items) {
        try {
          final title = item.findElements('title').first.text;
          final link = item.findElements('link').first.text;
          final description = item.findElements('description').isNotEmpty
              ? item.findElements('description').first.text
              : '';
          final pubDate = item.findElements('pubDate').isNotEmpty
              ? item.findElements('pubDate').first.text
              : '';

          // Parse date
          DateTime publishedDate;
          try {
            publishedDate = _parseRSSDate(pubDate);
          } catch (e) {
            publishedDate = DateTime.now();
          }

          // Extract image if available
          String? imageUrl;
          final mediaContent = item.findElements('media:content');
          if (mediaContent.isNotEmpty) {
            imageUrl = mediaContent.first.getAttribute('url');
          } else {
            final enclosure = item.findElements('enclosure');
            if (enclosure.isNotEmpty) {
              imageUrl = enclosure.first.getAttribute('url');
            }
          }

          articles.add(NewsArticle(
            title: _cleanHtml(title),
            description: _cleanHtml(description),
            url: link,
            imageUrl: imageUrl,
            publishedDate: publishedDate,
            source: sourceName,
          ));
        } catch (e) {
          print('Error parsing article: $e');
          continue;
        }
      }

      return articles;
    } catch (e) {
      print('Error fetching RSS: $e');
      throw Exception('Failed to fetch news: $e');
    }
  }

  // Parse RSS date format (RFC 822)
  DateTime _parseRSSDate(String dateString) {
    try {
      // Remove timezone abbreviations and parse
      final cleanDate = dateString.replaceAll(RegExp(r'\s+[A-Z]{3,4}$'), '');
      return DateTime.parse(cleanDate);
    } catch (e) {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }

  // Clean HTML tags from text
  String _cleanHtml(String htmlString) {
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  // Filter news by keywords (for disaster-specific content)
  List<NewsArticle> filterByKeywords(List<NewsArticle> articles, List<String> keywords) {
    return articles.where((article) {
      final content = '${article.title} ${article.description}'.toLowerCase();
      return keywords.any((keyword) => content.contains(keyword.toLowerCase()));
    }).toList();
  }

  // Get disaster-related keywords
  List<String> getDisasterKeywords() {
    return [
      'typhoon', 'bagyo', 'flood', 'baha', 'earthquake', 'lindol',
      'fire', 'sunog', 'landslide', 'tsunami', 'storm', 'disaster',
      'emergency', 'evacuate', 'pagasa', 'ndrrmc', 'phivolcs',
      'weather', 'warning', 'alert', 'calamity',
    ];
  }
}

// News Article Model
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final DateTime publishedDate;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.publishedDate,
    required this.source,
  });

  // Convert to Map for caching
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'source': source,
    };
  }

  // Create from Map
  factory NewsArticle.fromMap(Map<String, dynamic> map) {
    return NewsArticle(
      title: map['title'],
      description: map['description'],
      url: map['url'],
      imageUrl: map['imageUrl'],
      publishedDate: DateTime.parse(map['publishedDate']),
      source: map['source'],
    );
  }
}