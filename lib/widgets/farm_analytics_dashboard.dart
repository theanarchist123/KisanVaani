import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/farm_provider.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';
import '../services/i18n_service.dart';
import '../widgets/i18n_widgets.dart';

class FarmAnalyticsDashboard extends StatelessWidget {
  const FarmAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, child) {
        if (farmProvider.currentFarm == null) {
          return const SizedBox.shrink();
        }

        return LayoutHelpers.safeColumn(
          children: [
            // Analytics Cards Row
            LayoutHelpers.responsiveRow(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    context.t('totalExpenses'),
                    context.formatCurrency(farmProvider.currentFarm!.expectedYield),
                    Icons.trending_up,
                    AppTheme.healthyGreen,
                    '${((farmProvider.seasonProgress) * 100).round()}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    context.t('totalIncome'),
                    context.formatCurrency(farmProvider.totalInvestment),
                    Icons.account_balance_wallet,
                    AppTheme.accentOrange,
                    context.t('profitLoss'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            LayoutHelpers.responsiveRow(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    context.t('profitLoss'),
                    context.formatCurrency(farmProvider.expectedProfit),
                    Icons.monetization_on,
                    farmProvider.expectedProfit > 0 
                      ? AppTheme.healthyGreen 
                      : AppTheme.criticalRed,
                    farmProvider.expectedProfit > 0 
                      ? context.t('profitLoss')
                      : context.t('profitLoss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    context.t('cropHealthOverview'),
                    '${farmProvider.healthyCrops.length}/${farmProvider.currentFarm!.crops.length}',
                    Icons.health_and_safety,
                    _getOverallHealthColor(farmProvider),
                    context.t('healthy'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Expense Breakdown Chart
            _buildExpenseChart(context, farmProvider),
            
            const SizedBox(height: 16),
            
            // Crop Health Overview
            _buildCropHealthOverview(context, farmProvider),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context, FarmProvider farmProvider) {
    final expenses = farmProvider.expensesByCategory;
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<PieChartSectionData> sections = expenses.entries.map((entry) {
      final color = _getExpenseColor(entry.key);
      final total = expenses.values.reduce((a, b) => a + b);
      final percentage = (entry.value / total * 100);
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('expenseAnalysis'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          LayoutHelpers.responsiveRow(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Legend
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: expenses.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: LayoutHelpers.responsiveRow(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getExpenseColor(entry.key),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            context.formatCurrency(entry.value),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropHealthOverview(BuildContext context, FarmProvider farmProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('cropHealthOverview'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // Health Status Bars
          _buildHealthStatusBar(
            context.t('healthy'),
            farmProvider.healthyCrops.length,
            farmProvider.currentFarm!.crops.length,
            AppTheme.healthyGreen,
          ),
          
          const SizedBox(height: 12),
          
          _buildHealthStatusBar(
            context.t('needsAttention'),
            farmProvider.cropsNeedingAttention.length,
            farmProvider.currentFarm!.crops.length,
            AppTheme.attentionOrange,
          ),
          
          const SizedBox(height: 12),
          
          _buildHealthStatusBar(
            context.t('critical'),
            farmProvider.criticalCrops.length,
            farmProvider.currentFarm!.crops.length,
            AppTheme.criticalRed,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusBar(
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? count / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutHelpers.responsiveRow(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count/$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getExpenseColor(String type) {
    switch (type.toLowerCase()) {
      case 'seeds':
        return const Color(0xFF4CAF50);
      case 'fertilizer':
        return const Color(0xFF2196F3);
      case 'pesticide':
        return const Color(0xFFFF9800);
      case 'labor':
        return const Color(0xFF9C27B0);
      case 'equipment':
        return const Color(0xFF607D8B);
      case 'irrigation':
        return const Color(0xFF00BCD4);
      default:
        return Colors.grey;
    }
  }

  Color _getOverallHealthColor(FarmProvider farmProvider) {
    final totalCrops = farmProvider.currentFarm!.crops.length;
    final healthyCrops = farmProvider.healthyCrops.length;
    final criticalCrops = farmProvider.criticalCrops.length;
    
    if (criticalCrops > 0) return AppTheme.criticalRed;
    if (healthyCrops == totalCrops) return AppTheme.healthyGreen;
    return AppTheme.attentionOrange;
  }
}
