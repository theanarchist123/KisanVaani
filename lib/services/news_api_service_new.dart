import 'package:flutter/foundation.dart';
import '../models/knowledge_models.dart';

class NewsApiService {
  Future<List<Article>> fetchAgricultureNews() async {
    try {
      // For demo purposes, return mock articles with real-like content
      // In production, this would call actual news APIs
      return _getMockArticles();
    } catch (e) {
      debugPrint('Error fetching news: $e');
      return _getMockArticles(); // Fallback to mock data
    }
  }

  List<Article> _getMockArticles() {
    final now = DateTime.now();
    return [
      Article(
        id: '1',
        title: 'Kharif Crop Sowing Guidelines for 2025',
        description: 'Agricultural experts recommend optimal sowing practices for this season. Key focus areas include soil preparation, seed selection, and water management strategies.',
        content: 'Detailed guidelines for successful Kharif crop cultivation...',
        url: 'https://example.com/kharif-guidelines',
        source: 'Agricultural Ministry',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(hours: 2)),
        keywords: ['kharif', 'farming', 'agriculture'],
      ),
      Article(
        id: '2',
        title: 'New Pest Management Techniques Show 40% Better Results',
        description: 'Recent studies reveal innovative integrated pest management approaches that significantly reduce crop damage while maintaining environmental safety.',
        content: 'Research findings on advanced pest control methods...',
        url: 'https://example.com/pest-management',
        source: 'Agricultural Research Institute',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(hours: 6)),
        keywords: ['pest', 'management', 'agriculture'],
      ),
      Article(
        id: '3',
        title: 'Government Announces New Subsidy Scheme for Organic Farmers',
        description: 'The agriculture ministry unveiled a comprehensive support package for farmers transitioning to organic farming methods.',
        content: 'Details about the new government subsidy program...',
        url: 'https://example.com/organic-subsidy',
        source: 'Government Portal',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(hours: 12)),
        keywords: ['subsidy', 'organic', 'government'],
      ),
      Article(
        id: '4',
        title: 'Climate-Smart Agriculture: Adapting to Weather Changes',
        description: 'Farmers are implementing climate-resilient techniques to cope with unpredictable weather patterns and ensure stable yields.',
        content: 'Comprehensive guide on climate-smart farming practices...',
        url: 'https://example.com/climate-smart',
        source: 'Climate Research Center',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(days: 1)),
        keywords: ['climate', 'agriculture', 'adaptation'],
      ),
      Article(
        id: '5',
        title: 'Digital Agriculture: AI Tools for Modern Farming',
        description: 'Artificial intelligence and machine learning technologies are revolutionizing traditional farming practices across the country.',
        content: 'Overview of AI applications in agriculture...',
        url: 'https://example.com/digital-agriculture',
        source: 'Technology News',
        imageUrl: '',
        publishedAt: now.subtract(const Duration(days: 2)),
        keywords: ['technology', 'AI', 'digital farming'],
      ),
    ];
  }
}
