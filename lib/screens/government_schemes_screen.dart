import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/government_scheme_provider.dart';
import '../models/government_scheme_models.dart';
import '../widgets/voice_input_widget.dart';
import '../widgets/scheme_card.dart';
import '../widgets/application_status_card.dart';
import '../utils/app_theme.dart';
import 'scheme_details_screen.dart';
import 'application_form_screen.dart';
import 'document_manager_screen.dart';
import 'subsidy_tracking_screen.dart';
import 'policy_updates_screen.dart';

class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  State<GovernmentSchemesScreen> createState() => _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Government Schemes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Schemes'),
            Tab(text: 'My Applications'),
            Tab(text: 'Documents'),
            Tab(text: 'Benefits'),
            Tab(text: 'Updates'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSchemesTab(),
          _buildApplicationsTab(),
          _buildDocumentsTab(),
          _buildBenefitsTab(),
          _buildUpdatesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showVoiceAssistant,
        backgroundColor: AppTheme.primaryGreen,
        icon: Consumer<GovernmentSchemeProvider>(
          builder: (context, provider, child) {
            return Icon(
              provider.isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
            );
          },
        ),
        label: const Text(
          'Voice Assistant',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSchemesTab() {
    return Consumer<GovernmentSchemeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return _buildErrorWidget(provider.errorMessage!);
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh schemes data
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildSchemeCategories(),
              const SizedBox(height: 20),
              _buildAvailableSchemes(provider.availableSchemes),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplicationsTab() {
    return Consumer<GovernmentSchemeProvider>(
      builder: (context, provider, child) {
        if (provider.userApplications.isEmpty) {
          return _buildEmptyState(
            'No Applications Yet',
            'Start by applying for a government scheme',
            Icons.assignment_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.userApplications.length,
          itemBuilder: (context, index) {
            final application = provider.userApplications[index];
            return ApplicationStatusCard(
              application: application,
              onTap: () => _showApplicationDetails(application),
            );
          },
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    return const DocumentManagerScreen();
  }

  Widget _buildBenefitsTab() {
    return const SubsidyTrackingScreen();
  }

  Widget _buildUpdatesTab() {
    return const PolicyUpdatesScreen();
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Apply for PM-KISAN',
                  Icons.money,
                  () => _quickApply('pm_kisan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Check Status',
                  Icons.track_changes,
                  _showStatusCheck,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeCategories() {
    final categories = [
      {'name': 'Income Support', 'icon': Icons.attach_money, 'count': 3},
      {'name': 'Credit & Loans', 'icon': Icons.credit_card, 'count': 2},
      {'name': 'Insurance', 'icon': Icons.security, 'count': 4},
      {'name': 'Subsidies', 'icon': Icons.local_offer, 'count': 5},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _filterByCategory(category['name'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          color: AppTheme.primaryGreen,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${category['count']} schemes',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableSchemes(List<GovernmentScheme> schemes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Schemes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...schemes.map((scheme) => SchemeCard(
          scheme: scheme,
          onTap: () => _showSchemeDetails(scheme),
          onApply: () => _applyForScheme(scheme),
        )).toList(),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<GovernmentSchemeProvider>().clearError();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showVoiceAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceInputWidget(),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Schemes'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter scheme name or keywords...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _searchSchemes(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon!'),
      ),
    );
  }

  void _showSchemeDetails(GovernmentScheme scheme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchemeDetailsScreen(scheme: scheme),
      ),
    );
  }

  void _applyForScheme(GovernmentScheme scheme) {
    context.read<GovernmentSchemeProvider>().selectScheme(scheme);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicationFormScreen(scheme: scheme),
      ),
    );
  }

  void _quickApply(String schemeId) {
    final provider = context.read<GovernmentSchemeProvider>();
    final scheme = provider.availableSchemes
        .firstWhere((s) => s.id == schemeId);
    _applyForScheme(scheme);
  }

  void _showStatusCheck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Application Status'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter tracking number...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            _checkApplicationStatus(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetails(SchemeApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(application.schemeName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${application.status.name}'),
            Text('Applied: ${application.appliedDate.day}/${application.appliedDate.month}/${application.appliedDate.year}'),
            if (application.trackingNumber != null)
              Text('Tracking: ${application.trackingNumber}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _filterByCategory(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtering by category: $category'),
      ),
    );
  }

  void _searchSchemes(String query) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $query'),
      ),
    );
  }

  void _checkApplicationStatus(String trackingNumber) {
    context.read<GovernmentSchemeProvider>()
        .updateApplicationStatus(trackingNumber);
  }
}
