class Farm {
  final String farmId;
  final String farmerName;
  final String farmerPhoto;
  final double totalAcres;
  final List<Crop> crops;
  final Location location;
  final String soilType;
  final DateTime createdAt;

  Farm({
    required this.farmId,
    required this.farmerName,
    required this.farmerPhoto,
    required this.totalAcres,
    required this.crops,
    required this.location,
    required this.soilType,
    required this.createdAt,
  });

  int get activeCropsCount => crops.where((crop) => crop.isActive).length;
  
  double get totalExpenses => crops.fold(0, (sum, crop) => 
    sum + crop.expenses.fold(0, (expSum, expense) => expSum + expense.amount));
  
  double get expectedYield => crops.fold(0, (sum, crop) => sum + crop.expectedYield);

  Map<String, dynamic> toJson() => {
    'farmId': farmId,
    'farmerName': farmerName,
    'farmerPhoto': farmerPhoto,
    'totalAcres': totalAcres,
    'crops': crops.map((crop) => crop.toJson()).toList(),
    'location': location.toJson(),
    'soilType': soilType,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
    farmId: json['farmId'],
    farmerName: json['farmerName'],
    farmerPhoto: json['farmerPhoto'],
    totalAcres: json['totalAcres'].toDouble(),
    crops: (json['crops'] as List).map((crop) => Crop.fromJson(crop)).toList(),
    location: Location.fromJson(json['location']),
    soilType: json['soilType'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class Crop {
  final String cropId;
  final String cropName;
  final String cropNameHindi;
  final String variety;
  final DateTime plantingDate;
  final DateTime expectedHarvest;
  final String currentStage;
  final double areaAcres;
  final String healthStatus;
  final List<Expense> expenses;
  final String cropImageUrl;
  final double expectedYield;
  final bool isActive;

  Crop({
    required this.cropId,
    required this.cropName,
    required this.cropNameHindi,
    required this.variety,
    required this.plantingDate,
    required this.expectedHarvest,
    required this.currentStage,
    required this.areaAcres,
    required this.healthStatus,
    required this.expenses,
    required this.cropImageUrl,
    required this.expectedYield,
    this.isActive = true,
  });

  int get daysToHarvest => expectedHarvest.difference(DateTime.now()).inDays;
  
  double get totalExpenses => expenses.fold(0, (sum, expense) => sum + expense.amount);
  
  double get healthScore {
    switch (healthStatus.toLowerCase()) {
      case 'healthy': return 0.9;
      case 'attention': return 0.6;
      case 'critical': return 0.3;
      default: return 0.5;
    }
  }

  String get stageIcon {
    switch (currentStage.toLowerCase()) {
      case 'seedling': return '🌱';
      case 'growing': return '🌿';
      case 'flowering': return '🌸';
      case 'fruiting': return '🍅';
      case 'harvest': return '🌾';
      default: return '🌱';
    }
  }

  Map<String, dynamic> toJson() => {
    'cropId': cropId,
    'cropName': cropName,
    'cropNameHindi': cropNameHindi,
    'variety': variety,
    'plantingDate': plantingDate.toIso8601String(),
    'expectedHarvest': expectedHarvest.toIso8601String(),
    'currentStage': currentStage,
    'areaAcres': areaAcres,
    'healthStatus': healthStatus,
    'expenses': expenses.map((expense) => expense.toJson()).toList(),
    'cropImageUrl': cropImageUrl,
    'expectedYield': expectedYield,
    'isActive': isActive,
  };

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    cropId: json['cropId'],
    cropName: json['cropName'],
    cropNameHindi: json['cropNameHindi'],
    variety: json['variety'],
    plantingDate: DateTime.parse(json['plantingDate']),
    expectedHarvest: DateTime.parse(json['expectedHarvest']),
    currentStage: json['currentStage'],
    areaAcres: json['areaAcres'].toDouble(),
    healthStatus: json['healthStatus'],
    expenses: (json['expenses'] as List).map((expense) => Expense.fromJson(expense)).toList(),
    cropImageUrl: json['cropImageUrl'],
    expectedYield: json['expectedYield'].toDouble(),
    isActive: json['isActive'] ?? true,
  );
}

class Expense {
  final String expenseId;
  final String type;
  final double amount;
  final DateTime date;
  final String description;
  final String? voiceNoteUrl;
  final String? receiptImageUrl;

  Expense({
    required this.expenseId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.voiceNoteUrl,
    this.receiptImageUrl,
  });

  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'seeds': return '🌱';
      case 'fertilizer': return '🧪';
      case 'pesticide': return '🐛';
      case 'labor': return '👨‍🌾';
      case 'equipment': return '🚜';
      case 'irrigation': return '💧';
      default: return '💰';
    }
  }

  Map<String, dynamic> toJson() => {
    'expenseId': expenseId,
    'type': type,
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
    'voiceNoteUrl': voiceNoteUrl,
    'receiptImageUrl': receiptImageUrl,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    expenseId: json['expenseId'],
    type: json['type'],
    amount: json['amount'].toDouble(),
    date: DateTime.parse(json['date']),
    description: json['description'],
    voiceNoteUrl: json['voiceNoteUrl'],
    receiptImageUrl: json['receiptImageUrl'],
  );
}

class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String district;
  final String state;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.district,
    required this.state,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'district': district,
    'state': state,
  };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: json['latitude'].toDouble(),
    longitude: json['longitude'].toDouble(),
    address: json['address'],
    district: json['district'],
    state: json['state'],
  );
}

class WeatherData {
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final String icon;
  final DateTime date;
  final List<ForecastDay> forecast;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.date,
    required this.forecast,
  });

  String get conditionIcon {
    switch (condition.toLowerCase()) {
      case 'sunny': return '☀️';
      case 'cloudy': return '☁️';
      case 'rainy': return '🌧️';
      case 'stormy': return '⛈️';
      default: return '🌤️';
    }
  }
}

class ForecastDay {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String icon;

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.icon,
  });
}
