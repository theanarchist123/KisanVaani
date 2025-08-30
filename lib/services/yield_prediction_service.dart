import 'dart:convert';
import 'package:http/http.dart' as http;

class YieldPredictionService {
  static const String baseUrl = 'http://127.0.0.1:5000';
  
  // Test if the ML API server is running
  static Future<bool> isServerRunning() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Server connection error: $e');
      return false;
    }
  }
  
  // Get model information and available features
  static Future<Map<String, dynamic>?> getModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/model-info'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get model info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting model info: $e');
      return null;
    }
  }
  
  // Predict crop yield based on input parameters
  static Future<YieldPredictionResult?> predictYield({
    required String crop,
    required String state,
    required String soilType,
    required String season,
    required double rainfall,
    required double temperature,
    required double landSize,
    double? humidity,
    double? ph,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
  }) async {
    try {
      // Prepare input data
      final inputData = {
        'Crop': crop,
        'State': state,
        'Soil_Type': soilType,
        'Season': season,
        'Rainfall': rainfall,
        'Temperature': temperature,
        'Land_Size': landSize,
        if (humidity != null) 'Humidity': humidity,
        if (ph != null) 'pH': ph,
        if (nitrogen != null) 'Nitrogen': nitrogen,
        if (phosphorus != null) 'Phosphorus': phosphorus,
        if (potassium != null) 'Potassium': potassium,
      };
      
      print('🌾 Sending prediction request: $inputData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(inputData),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          return YieldPredictionResult.fromJson(responseData);
        } else {
          print('Prediction failed: ${responseData['error']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error predicting yield: $e');
      return null;
    }
  }
}

class YieldPredictionResult {
  final double predictedYield;
  final String unit;
  final double confidence;
  final String modelName;
  final double r2Score;
  final double mae;
  final Map<String, dynamic> inputProcessed;
  
  YieldPredictionResult({
    required this.predictedYield,
    required this.unit,
    required this.confidence,
    required this.modelName,
    required this.r2Score,
    required this.mae,
    required this.inputProcessed,
  });
  
  factory YieldPredictionResult.fromJson(Map<String, dynamic> json) {
    return YieldPredictionResult(
      predictedYield: json['prediction']['predicted_yield'].toDouble(),
      unit: json['prediction']['unit'] ?? 'tons/hectare',
      confidence: json['prediction']['confidence'].toDouble(),
      modelName: json['model_info']['model_name'],
      r2Score: json['model_info']['r2_score'].toDouble(),
      mae: json['model_info']['mae'].toDouble(),
      inputProcessed: json['input_processed'],
    );
  }
  
  // Get confidence level as text
  String get confidenceLevel {
    if (confidence >= 0.9) return 'Very High';
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.7) return 'Good';
    if (confidence >= 0.6) return 'Moderate';
    return 'Low';
  }
  
  // Get confidence color
  String get confidenceColor {
    if (confidence >= 0.9) return '#4CAF50'; // Green
    if (confidence >= 0.8) return '#8BC34A'; // Light Green
    if (confidence >= 0.7) return '#FFC107'; // Amber
    if (confidence >= 0.6) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }
}
