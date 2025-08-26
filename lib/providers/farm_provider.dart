import 'package:flutter/material.dart';
import '../models/farm_models.dart';

class FarmProvider extends ChangeNotifier {
  Farm? _currentFarm;
  bool _isLoading = false;
  String? _error;

  Farm? get currentFarm => _currentFarm;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with sample data
  void initializeSampleFarm() {
    _currentFarm = Farm(
      farmId: 'farm_001',
      farmerName: 'Rajesh Kumar',
      farmerPhoto: 'assets/images/farmer_avatar.png',
      totalAcres: 5.5,
      location: Location(
        latitude: 28.6139,
        longitude: 77.2090,
        address: 'Village: Rampur, Tehsil: Sonipat',
        district: 'Sonipat',
        state: 'Haryana',
      ),
      soilType: 'Loamy Soil',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      crops: [
        Crop(
          cropId: 'crop_001',
          cropName: 'Tomato',
          cropNameHindi: 'Tomato',
          variety: 'Hybrid',
          plantingDate: DateTime.now().subtract(const Duration(days: 45)),
          expectedHarvest: DateTime.now().add(const Duration(days: 75)),
          currentStage: 'flowering',
          areaAcres: 2.0,
          healthStatus: 'healthy',
          cropImageUrl: 'assets/images/tomato.png',
          expectedYield: 8000,
          expenses: [
            Expense(
              expenseId: 'exp_001',
              type: 'seeds',
              amount: 1500,
              date: DateTime.now().subtract(const Duration(days: 45)),
              description: 'Bought tomato seeds',
            ),
            Expense(
              expenseId: 'exp_002',
              type: 'fertilizer',
              amount: 800,
              date: DateTime.now().subtract(const Duration(days: 30)),
              description: 'NPK fertilizer',
            ),
          ],
        ),
        Crop(
          cropId: 'crop_002',
          cropName: 'Wheat',
          cropNameHindi: 'Wheat',
          variety: 'HD-2967',
          plantingDate: DateTime.now().subtract(const Duration(days: 60)),
          expectedHarvest: DateTime.now().add(const Duration(days: 90)),
          currentStage: 'growing',
          areaAcres: 3.0,
          healthStatus: 'attention',
          cropImageUrl: 'assets/images/wheat.png',
          expectedYield: 12000,
          expenses: [
            Expense(
              expenseId: 'exp_003',
              type: 'seeds',
              amount: 2000,
              date: DateTime.now().subtract(const Duration(days: 60)),
              description: 'Wheat seeds',
            ),
          ],
        ),
        Crop(
          cropId: 'crop_003',
          cropName: 'Onion',
          cropNameHindi: 'Onion',
          variety: 'Nasik Red',
          plantingDate: DateTime.now().subtract(const Duration(days: 30)),
          expectedHarvest: DateTime.now().add(const Duration(days: 120)),
          currentStage: 'seedling',
          areaAcres: 0.5,
          healthStatus: 'healthy',
          cropImageUrl: 'assets/images/onion.png',
          expectedYield: 2500,
          expenses: [
            Expense(
              expenseId: 'exp_004',
              type: 'seeds',
              amount: 500,
              date: DateTime.now().subtract(const Duration(days: 30)),
              description: 'प्याज के बीज',
            ),
          ],
        ),
      ],
    );
    notifyListeners();
  }

  void addExpense(String cropId, Expense expense) {
    if (_currentFarm != null) {
      final cropIndex = _currentFarm!.crops.indexWhere((crop) => crop.cropId == cropId);
      if (cropIndex != -1) {
        _currentFarm!.crops[cropIndex].expenses.add(expense);
        notifyListeners();
      }
    }
  }

  void updateCropHealth(String cropId, String healthStatus) {
    if (_currentFarm != null) {
      final cropIndex = _currentFarm!.crops.indexWhere((crop) => crop.cropId == cropId);
      if (cropIndex != -1) {
        final crop = _currentFarm!.crops[cropIndex];
        final updatedCrop = Crop(
          cropId: crop.cropId,
          cropName: crop.cropName,
          cropNameHindi: crop.cropNameHindi,
          variety: crop.variety,
          plantingDate: crop.plantingDate,
          expectedHarvest: crop.expectedHarvest,
          currentStage: crop.currentStage,
          areaAcres: crop.areaAcres,
          healthStatus: healthStatus,
          expenses: crop.expenses,
          cropImageUrl: crop.cropImageUrl,
          expectedYield: crop.expectedYield,
          isActive: crop.isActive,
        );
        _currentFarm!.crops[cropIndex] = updatedCrop;
        notifyListeners();
      }
    }
  }

  double get seasonProgress {
    if (_currentFarm == null || _currentFarm!.crops.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (final crop in _currentFarm!.crops) {
      final totalDays = crop.expectedHarvest.difference(crop.plantingDate).inDays;
      final daysPassed = DateTime.now().difference(crop.plantingDate).inDays;
      final progress = (daysPassed / totalDays).clamp(0.0, 1.0);
      totalProgress += progress;
    }
    return totalProgress / _currentFarm!.crops.length;
  }

  Map<String, double> get expensesByCategory {
    if (_currentFarm == null) return {};
    
    final Map<String, double> categoryExpenses = {};
    for (final crop in _currentFarm!.crops) {
      for (final expense in crop.expenses) {
        categoryExpenses[expense.type] = 
          (categoryExpenses[expense.type] ?? 0) + expense.amount;
      }
    }
    return categoryExpenses;
  }

  double get totalInvestment => _currentFarm?.totalExpenses ?? 0.0;
  
  double get expectedProfit {
    if (_currentFarm == null) return 0.0;
    const double avgPricePerKg = 25.0; // Average selling price
    final expectedRevenue = _currentFarm!.expectedYield * avgPricePerKg;
    return expectedRevenue - totalInvestment;
  }

  List<Crop> get healthyCrops => 
    _currentFarm?.crops.where((crop) => crop.healthStatus == 'healthy').toList() ?? [];
  
  List<Crop> get cropsNeedingAttention => 
    _currentFarm?.crops.where((crop) => crop.healthStatus == 'attention').toList() ?? [];
  
  List<Crop> get criticalCrops => 
    _currentFarm?.crops.where((crop) => crop.healthStatus == 'critical').toList() ?? [];
}
