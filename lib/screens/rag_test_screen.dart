import 'package:flutter/material.dart';
import '../services/enhanced_ai_service.dart';
import '../utils/app_theme.dart';

class RagTestScreen extends StatefulWidget {
  const RagTestScreen({super.key});

  @override
  State<RagTestScreen> createState() => _RagTestScreenState();
}

class _RagTestScreenState extends State<RagTestScreen> {
  final EnhancedAIService _aiService = EnhancedAIService();
  final TextEditingController _queryController = TextEditingController();
  
  bool _isLoading = false;
  bool _isRagReady = false;
  String _response = '';
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _checkRagStatus();
  }

  Future<void> _checkRagStatus() async {
    final isReady = await _aiService.isRagBackendReady();
    setState(() {
      _isRagReady = isReady;
    });
  }

  Future<void> _testQuery() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
      _searchResults = [];
    });

    try {
      final response = await _aiService.processAgricultureQuery(
        _queryController.text.trim(),
        'en',
      );
      
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchKnowledge() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final results = await _aiService.searchKnowledge(_queryController.text.trim());
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAG Backend Test'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isRagReady ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _checkRagStatus,
            tooltip: _isRagReady ? 'RAG Backend Ready' : 'RAG Backend Not Available',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _isRagReady ? Colors.green[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isRagReady ? Icons.check_circle : Icons.warning,
                      color: _isRagReady ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RAG Backend Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isRagReady ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                          Text(
                            _isRagReady 
                              ? 'Connected and ready for enhanced responses'
                              : 'Not available - using fallback responses',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isRagReady ? Colors.green[600] : Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Query Input
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: 'Enter your agricultural question',
                hintText: 'e.g., What are the best practices for rice cultivation?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testQuery,
                    icon: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.psychology),
                    label: const Text('Ask RAG'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || !_isRagReady ? null : _searchKnowledge,
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Response Section
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Response'),
                        Tab(text: 'Search Results'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Response Tab
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _response.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Ask a question to see the RAG response',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Text(
                                    _response,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ),
                          ),
                          
                          // Search Results Tab
                          _searchResults.isEmpty
                            ? const Center(
                                child: Text(
                                  'Search for knowledge chunks',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.article, size: 16, color: Colors.blue),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Chunk ${index + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (result['similarity'] != null)
                                                Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${(result['similarity'] * 100).toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            result['content'] ?? 'No content',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
