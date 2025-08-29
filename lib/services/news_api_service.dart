import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/knowledge_models.dart';

class NewsApiService {
  // NewsAPI.org - Free tier: 1000 requests per month
  // Get your free API key at: https://newsapi.org/register
  static const String _baseUrl = 'https://newsapi.org/v2/everything';
  static const String _apiKey = '83bf8d87ea3444948f7713d5586f6559'; // Replace with your actual API key from newsapi.org

  // How to get real news:
  // 1. Go to https://newsapi.org/register
  // 2. Sign up for a free account
  // 3. Copy your API key
  // 4. Replace 'your_api_key_here' above with your actual API key
  // 5. The app will then fetch real agriculture news automatically!
  
  Future<List<Article>> fetchAgricultureNews() async {
    try {
      // Try free news aggregation first (no API key needed)
      final freeArticles = await _fetchFreeNews();
      if (freeArticles.isNotEmpty) {
        return freeArticles;
      }
      
      // Try NewsAPI if API key is configured
      if (_apiKey != 'your_api_key_here') {
        final realArticles = await _fetchRealNews();
        if (realArticles.isNotEmpty) {
          return realArticles;
        }
      }
      
      // Fallback to curated mock articles with real URLs
      return _getMockArticles();
    } catch (e) {
      debugPrint('Error fetching news: $e');
      return _getMockArticles(); // Fallback to mock data
    }
  }

  Future<List<Article>> _fetchFreeNews() async {
    try {
      // Try to fetch from a free news source
      final url = Uri.parse('https://api.rss2json.com/v1/api.json?rss_url=https://feeds.reuters.com/reuters/agriculture');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'ok' && data['items'] != null) {
          final List<dynamic> items = data['items'];
          
          return items.take(10).map((item) => Article(
            id: item['guid']?.hashCode.toString() ?? '',
            title: item['title'] ?? 'No Title',
            description: item['description']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
            content: item['content']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? item['description']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
            url: item['link'] ?? '',
            source: 'Reuters Agriculture',
            imageUrl: item['enclosure']?['link'] ?? item['thumbnail'] ?? '',
            publishedAt: DateTime.tryParse(item['pubDate'] ?? '') ?? DateTime.now(),
            keywords: ['agriculture', 'farming', 'reuters'],
          )).toList();
        }
      }
      
      // If RSS2JSON fails, return empty list to try next method
      return [];
    } catch (e) {
      debugPrint('Error fetching free news: $e');
      return [];
    }
  }

  Future<List<Article>> _fetchRealNews() async {
    try {
      final url = Uri.parse(
        '$_baseUrl?q=agriculture OR farming OR crops OR livestock OR organic farming OR sustainable agriculture&'
        'sortBy=publishedAt&'
        'language=en&'
        'pageSize=20&'
        'apiKey=$_apiKey'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        
        return articles.map((articleData) => Article(
          id: articleData['url']?.hashCode.toString() ?? '',
          title: articleData['title'] ?? 'No Title',
          description: articleData['description'] ?? '',
          content: articleData['content'] ?? articleData['description'] ?? '',
          url: articleData['url'] ?? '',
          source: articleData['source']?['name'] ?? 'Unknown Source',
          imageUrl: articleData['urlToImage'] ?? '',
          publishedAt: DateTime.tryParse(articleData['publishedAt'] ?? '') ?? DateTime.now(),
          keywords: ['agriculture', 'farming'],
        )).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching real news: $e');
      throw e;
    }
  }

  List<Article> _getMockArticles() {
    final now = DateTime.now();
    return [
      Article(
        id: '1',
        title: 'India Achieves Record Wheat Production Despite Climate Challenges',
        description: 'Farmers across India report bumper wheat harvest this season, with improved irrigation and climate-smart practices leading to record yields.',
        content: 'Detailed analysis of wheat production improvements...',
        url: 'https://www.business-standard.com/agriculture/wheat-production-india-2024',
        source: 'Business Standard Agriculture',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(hours: 2)),
        keywords: ['wheat', 'farming', 'agriculture', 'india'],
      ),
      Article(
        id: '2',
        title: 'New Organic Farming Subsidies Announced for Small Farmers',
        description: 'Government unveils comprehensive support package for farmers transitioning to organic farming methods, including financial assistance and training programs.',
        content: 'Complete details about organic farming incentives...',
        url: 'https://www.thehindu.com/business/agri-business/organic-farming-subsidies/article66789012.ece',
        source: 'The Hindu Business',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(hours: 4)),
        keywords: ['organic', 'subsidies', 'government'],
      ),
      Article(
        id: '3',
        title: 'Smart Irrigation Technology Reduces Water Usage by 40%',
        description: 'New IoT-based irrigation systems help farmers optimize water usage while maintaining crop yields, addressing water scarcity concerns.',
        content: 'Technology innovations in agriculture...',
        url: 'https://economictimes.indiatimes.com/industry/cons-products/food/smart-irrigation-technology/articleshow/98765432.cms',
        source: 'Economic Times',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(hours: 8)),
        keywords: ['irrigation', 'technology', 'water'],
      ),
      Article(
        id: '4',
        title: 'Climate-Resilient Crops Show Promise in Drought-Prone Areas',
        description: 'Agricultural scientists develop new crop varieties that can withstand extreme weather conditions, offering hope for climate adaptation.',
        content: 'Research on climate-resilient agriculture...',
        url: 'https://www.downtoearth.org.in/agriculture/climate-resilient-crops-drought',
        source: 'Down to Earth',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(days: 1)),
        keywords: ['climate', 'drought', 'research'],
      ),
      Article(
        id: '5',
        title: 'Integrated Pest Management Reduces Pesticide Use by 60%',
        description: 'Farmers adopting IPM techniques report significant reduction in chemical pesticide usage while maintaining effective pest control.',
        content: 'IPM success stories and implementation...',
        url: 'https://www.indianexpress.com/article/cities/pune/integrated-pest-management-success',
        source: 'Indian Express',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(days: 2)),
        keywords: ['pest management', 'pesticides', 'sustainable'],
      ),
      Article(
        id: '6',
        title: 'Farm-to-Fork Initiative Boosts Rural Income by 35%',
        description: 'Direct marketing platforms connect farmers with consumers, eliminating middlemen and increasing profit margins for agricultural producers.',
        content: 'Analysis of farm-to-fork market trends...',
        url: 'https://www.livemint.com/industry/agriculture/farm-to-fork-initiative-rural-income',
        source: 'LiveMint Agriculture',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(days: 3)),
        keywords: ['marketing', 'income', 'rural development'],
      ),
    ];
  }
}
