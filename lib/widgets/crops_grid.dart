import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm_models.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';
import '../widgets/i18n_widgets.dart';

class CropsGrid extends StatelessWidget {
  const CropsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, child) {
        final farm = farmProvider.currentFarm;
        if (farm == null || farm.crops.isEmpty) {
          return _buildEmptyState(context);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on screen size
            int crossAxisCount = 2;
            double childAspectRatio = 0.75; // Made taller to prevent overflow
            
            if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
              childAspectRatio = 0.8; // Made taller
            }
            if (constraints.maxWidth > 900) {
              crossAxisCount = 4;
              childAspectRatio = 0.85; // Made taller
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: farm.crops.length,
              itemBuilder: (context, index) {
                final crop = farm.crops[index];
                return _buildCropCard(context, crop);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCropCard(BuildContext context, Crop crop) {
    Color healthColor = _getHealthColor(crop.healthStatus);
    
    return GestureDetector(
      onTap: () => _showCropDetails(context, crop),
      child: LayoutHelpers.safeContainer(
        padding: const EdgeInsets.all(8), // Reduced padding from 12 to 8
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: healthColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: healthColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutHelpers.safeColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Status Indicator & Stage
            LayoutHelpers.responsiveRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: healthColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: healthColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 3),
                        LayoutHelpers.safeText(
                          _getHealthStatusEnglish(crop.healthStatus),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: healthColor,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  crop.stageIcon,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            
            const SizedBox(height: 6), // Reduced from 8
            
            // Crop Image Placeholder
            Container(
              width: double.infinity,
              height: 40, // Reduced from 50
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getCropEmoji(crop.cropName),
                  style: const TextStyle(fontSize: 24), // Reduced from 28
                ),
              ),
            ),
            
            const SizedBox(height: 6), // Reduced from 8
            
            // Crop Name
            LayoutHelpers.safeText(
              crop.cropNameHindi,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
            ),
            
            LayoutHelpers.safeText(
              crop.variety,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 1,
            ),
            
            const SizedBox(height: 4), // Reduced from 6
            
            // Growth Stage
            LayoutHelpers.safeText(
              _getStageEnglish(crop.currentStage),
              style: const TextStyle(
                fontSize: 10, // Reduced from 11
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryGreen,
              ),
              maxLines: 1,
            ),
            
            const SizedBox(height: 3), // Reduced from 4
            
            // Days to Harvest
            LayoutHelpers.responsiveRow(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: LayoutHelpers.safeText(
                    '${crop.daysToHarvest} ${context.t('daysLeft')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4), // Reduced from 6
            
            // Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Reduced padding
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: LayoutHelpers.safeText(
                '${crop.areaAcres} ${context.t('acres')}',
                style: const TextStyle(
                  fontSize: 9, // Reduced from 10
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.agriculture,
            size: 64,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 16),
          Text(
            'No Crops Found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add First Crop',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: Text('Add Crop'),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(String healthStatus) {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return AppTheme.healthyGreen;
      case 'attention':
        return AppTheme.attentionOrange;
      case 'critical':
        return AppTheme.criticalRed;
      default:
        return Colors.grey;
    }
  }

  String _getHealthStatusEnglish(String healthStatus) {
    switch (healthStatus.toLowerCase()) {
      case 'healthy':
        return 'Healthy';
      case 'attention':
        return 'Attention';
      case 'critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  String _getStageEnglish(String stage) {
    switch (stage.toLowerCase()) {
      case 'seedling':
        return 'Seedling';
      case 'growing':
        return 'Growing';
      case 'flowering':
        return 'Flowering';
      case 'fruiting':
        return 'Fruiting';
      case 'harvest':
        return 'Harvest';
      default:
        return stage;
    }
  }

  String _getCropEmoji(String cropName) {
    switch (cropName.toLowerCase()) {
      case 'tomato':
        return '🍅';
      case 'wheat':
        return '🌾';
      case 'rice':
        return '🌾';
      case 'onion':
        return '🧅';
      case 'potato':
        return '🥔';
      case 'corn':
        return '🌽';
      default:
        return '🌱';
    }
  }

  void _showCropDetails(BuildContext context, Crop crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    _getCropEmoji(crop.cropName),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropNameHindi,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${crop.variety} • ${crop.areaAcres} एकड़',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getHealthColor(crop.healthStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getHealthStatusEnglish(crop.healthStatus),
                      style: TextStyle(
                        color: _getHealthColor(crop.healthStatus),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Planting Date', 
                      '${crop.plantingDate.day}/${crop.plantingDate.month}/${crop.plantingDate.year}'),
                    
                    _buildDetailRow('Harvest Date', 
                      '${crop.expectedHarvest.day}/${crop.expectedHarvest.month}/${crop.expectedHarvest.year}'),
                    
                    _buildDetailRow('Current Stage', _getStageEnglish(crop.currentStage)),
                    
                    _buildDetailRow('Expected Yield', '${crop.expectedYield} kg'),
                    
                    _buildDetailRow('Total Expenses', '₹${crop.totalExpenses.round()}'),
                    
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Expanded(
                      child: ListView.builder(
                        itemCount: crop.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = crop.expenses[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  expense.typeIcon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.description,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${expense.amount.round()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
