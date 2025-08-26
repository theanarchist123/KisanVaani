import 'package:flutter/material.dart';
import '../models/farm_models.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _error;

  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherProvider() {
    _initializeSampleWeather();
  }

  void _initializeSampleWeather() {
    _currentWeather = WeatherData(
      temperature: 28.0,
      condition: 'Sunny',
      humidity: 65.0,
      windSpeed: 12.0,
      icon: '☀️',
      date: DateTime.now(),
      forecast: [
        ForecastDay(
          date: DateTime.now().add(const Duration(days: 1)),
          maxTemp: 30.0,
          minTemp: 22.0,
          condition: 'Partly Cloudy',
          icon: '🌤️',
        ),
        ForecastDay(
          date: DateTime.now().add(const Duration(days: 2)),
          maxTemp: 26.0,
          minTemp: 20.0,
          condition: 'Rainy',
          icon: '🌧️',
        ),
        ForecastDay(
          date: DateTime.now().add(const Duration(days: 3)),
          maxTemp: 29.0,
          minTemp: 23.0,
          condition: 'Sunny',
          icon: '☀️',
        ),
        ForecastDay(
          date: DateTime.now().add(const Duration(days: 4)),
          maxTemp: 31.0,
          minTemp: 24.0,
          condition: 'Hot',
          icon: '🌡️',
        ),
        ForecastDay(
          date: DateTime.now().add(const Duration(days: 5)),
          maxTemp: 27.0,
          minTemp: 21.0,
          condition: 'Cloudy',
          icon: '☁️',
        ),
        ForecastDay(
          date: DateTime.now().add(const Duration(days: 6)),
          maxTemp: 25.0,
          minTemp: 19.0,
          condition: 'Rainy',
          icon: '🌧️',
        ),
        ForecastDay(
          date: DateTime.now().add(const Duration(days: 7)),
          maxTemp: 28.0,
          minTemp: 22.0,
          condition: 'Sunny',
          icon: '☀️',
        ),
      ],
    );
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Update with new sample data
      _initializeSampleWeather();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'मौसम की जानकारी प्राप्त करने में त्रुटि';
      _isLoading = false;
      notifyListeners();
    }
  }

  String getWeatherAdvice() {
    if (_currentWeather == null) return '';

    final temp = _currentWeather!.temperature;
    final condition = _currentWeather!.condition.toLowerCase();
    final humidity = _currentWeather!.humidity;

    if (condition.contains('rain')) {
      return 'बारिश हो रही है। खेत में काम न करें और फसल को पानी से बचाएं।';
    } else if (temp > 35) {
      return 'बहुत गर्मी है। दोपहर में सिंचाई न करें और पौधों को छाया दें।';
    } else if (temp < 10) {
      return 'ठंड है। फसल को पाले से बचाएं और गर्म पानी से सिंचाई करें।';
    } else if (humidity > 80) {
      return 'नमी ज्यादा है। फंगल बीमारी से बचने के लिए स्प्रे करें।';
    } else if (condition.contains('sunny') && temp > 25 && temp < 32) {
      return 'मौसम अच्छा है। खेत के काम के लिए उपयुक्त समय है।';
    }

    return 'मौसम सामान्य है। नियमित देखभाल जारी रखें।';
  }

  bool get isFavorableForWork {
    if (_currentWeather == null) return false;
    
    final temp = _currentWeather!.temperature;
    final condition = _currentWeather!.condition.toLowerCase();
    
    return !condition.contains('rain') && 
           !condition.contains('storm') && 
           temp > 15 && 
           temp < 35;
  }

  List<String> get upcomingAlerts {
    final alerts = <String>[];
    
    if (_currentWeather?.forecast != null) {
      for (int i = 0; i < 3; i++) {
        final forecast = _currentWeather!.forecast[i];
        if (forecast.condition.toLowerCase().contains('rain')) {
          final dayName = _getDayName(forecast.date);
          alerts.add('$dayName को बारिश की संभावना');
        }
        if (forecast.maxTemp > 35) {
          final dayName = _getDayName(forecast.date);
          alerts.add('$dayName को तेज गर्मी की चेतावनी');
        }
      }
    }
    
    return alerts;
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    switch (difference) {
      case 0: return 'आज';
      case 1: return 'कल';
      case 2: return 'परसों';
      default: return '${difference + 1} दिन बाद';
    }
  }
}
