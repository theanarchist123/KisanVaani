import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/farm_profile_header.dart';
import '../widgets/crops_grid.dart';
import '../widgets/farm_analytics_dashboard.dart';
import '../widgets/field_management_section.dart';
import '../widgets/quick_action_buttons.dart';
import '../utils/app_theme.dart';

class FarmFeaturesScreen extends StatefulWidget {
  const FarmFeaturesScreen({super.key});

  @override
  State<FarmFeaturesScreen> createState() => _FarmFeaturesScreenState();
}

class _FarmFeaturesScreenState extends State<FarmFeaturesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FarmProvider, WeatherProvider>(
      builder: (context, farmProvider, weatherProvider, child) {
        if (farmProvider.currentFarm == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await weatherProvider.refreshWeather();
            // Add farm data refresh logic here
          },
          color: AppTheme.primaryGreen,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farm Profile Header Card
                  const FarmProfileHeader(),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Action Buttons
                  const QuickActionButtons(),
                  
                  const SizedBox(height: 20),
                  
                  // My Crops Section
                  _buildSectionHeader('My Crops', Icons.agriculture),
                  const SizedBox(height: 12),
                  const CropsGrid(),
                  
                  const SizedBox(height: 24),
                  
                  // Farm Analytics Dashboard
                  _buildSectionHeader('Farm Analytics', Icons.analytics),
                  const SizedBox(height: 12),
                  const FarmAnalyticsDashboard(),
                  
                  const SizedBox(height: 24),
                  
                  // Field Management Section
                  _buildSectionHeader('Field Management', Icons.settings),
                  const SizedBox(height: 12),
                  const FieldManagementSection(),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
