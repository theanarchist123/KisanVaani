import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/yield_prediction_service.dart';
import '../providers/farm_provider.dart';

class YieldPredictionScreen extends StatefulWidget {
  const YieldPredictionScreen({super.key});

  @override
  State<YieldPredictionScreen> createState() => _YieldPredictionScreenState();
}

class _YieldPredictionScreenState extends State<YieldPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _serverConnected = false;
  YieldPredictionResult? _predictionResult;
  
  // Form controllers
  final _rainfallController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _landSizeController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  
  // Selected values
  String _selectedCrop = 'Wheat';
  String _selectedState = 'Punjab';
  String _selectedSoilType = 'Alluvial';
  String _selectedSeason = 'Rabi';
  
  // Available options
  final List<String> _crops = [
    'Wheat', 'Rice', 'Maize', 'Cotton', 'Sugarcane', 'Potato', 'Onion', 'Tomato',
    'Soybean', 'Mustard', 'Groundnut', 'Sunflower', 'Barley', 'Gram', 'Moong'
  ];
  
  final List<String> _states = [
    'Punjab', 'Haryana', 'Uttar Pradesh', 'Rajasthan', 'Madhya Pradesh',
    'Maharashtra', 'Gujarat', 'Karnataka', 'Andhra Pradesh', 'Tamil Nadu',
    'West Bengal', 'Bihar', 'Odisha', 'Telangana', 'Kerala'
  ];
  
  final List<String> _soilTypes = [
    'Alluvial', 'Black', 'Red', 'Laterite', 'Desert', 'Mountain', 'Clayey', 'Sandy', 'Loamy'
  ];
  
  final List<String> _seasons = ['Rabi', 'Kharif', 'Zaid'];

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
    _initializeFromFarmData();
  }

  void _initializeFromFarmData() {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm != null) {
      _landSizeController.text = farmProvider.currentFarm!.totalAcres.toString();
    }
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await YieldPredictionService.isServerRunning();
    setState(() {
      _serverConnected = isConnected;
    });
    
    if (!isConnected) {
      _showServerErrorDialog();
    }
  }

  void _showServerErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Server Not Connected'),
          ],
        ),
        content: const Text(
          'ML prediction server is not running. Please start the Flask server first:\n\n'
          '1. Navigate to flask_api folder\n'
          '2. Run start_server.bat\n'
          '3. Wait for server to start\n'
          '4. Try again',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkServerConnection();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _predictYield() async {
    if (!_formKey.currentState!.validate() || !_serverConnected) {
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = null;
    });

    try {
      final result = await YieldPredictionService.predictYield(
        crop: _selectedCrop,
        state: _selectedState,
        soilType: _selectedSoilType,
        season: _selectedSeason,
        rainfall: double.parse(_rainfallController.text),
        temperature: double.parse(_temperatureController.text),
        landSize: double.parse(_landSizeController.text),
        humidity: _humidityController.text.isNotEmpty 
            ? double.tryParse(_humidityController.text) : null,
        ph: _phController.text.isNotEmpty 
            ? double.tryParse(_phController.text) : null,
        nitrogen: _nitrogenController.text.isNotEmpty 
            ? double.tryParse(_nitrogenController.text) : null,
        phosphorus: _phosphorusController.text.isNotEmpty 
            ? double.tryParse(_phosphorusController.text) : null,
        potassium: _potassiumController.text.isNotEmpty 
            ? double.tryParse(_potassiumController.text) : null,
      );

      setState(() {
        _predictionResult = result;
        _isLoading = false;
      });

      if (result == null) {
        _showErrorSnackBar('Failed to get prediction. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Yield Prediction'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Server Status Card
              Card(
                color: _serverConnected ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _serverConnected ? Icons.check_circle : Icons.error,
                        color: _serverConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _serverConnected 
                            ? 'ML Server Connected' 
                            : 'ML Server Disconnected',
                        style: TextStyle(
                          color: _serverConnected ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (!_serverConnected)
                        TextButton(
                          onPressed: _checkServerConnection,
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Crop Information Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crop Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Crop Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCrop,
                        decoration: const InputDecoration(
                          labelText: 'Crop Type',
                          prefixIcon: Icon(Icons.grass),
                        ),
                        items: _crops.map((crop) => DropdownMenuItem(
                          value: crop,
                          child: Text(crop),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedCrop = value!),
                        validator: (value) => value == null ? 'Please select a crop' : null,
                      ),
                      const SizedBox(height: 16),

                      // State Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedState,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: _states.map((state) => DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedState = value!),
                        validator: (value) => value == null ? 'Please select a state' : null,
                      ),
                      const SizedBox(height: 16),

                      // Soil Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSoilType,
                        decoration: const InputDecoration(
                          labelText: 'Soil Type',
                          prefixIcon: Icon(Icons.terrain),
                        ),
                        items: _soilTypes.map((soil) => DropdownMenuItem(
                          value: soil,
                          child: Text(soil),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedSoilType = value!),
                        validator: (value) => value == null ? 'Please select soil type' : null,
                      ),
                      const SizedBox(height: 16),

                      // Season Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSeason,
                        decoration: const InputDecoration(
                          labelText: 'Growing Season',
                          prefixIcon: Icon(Icons.wb_sunny),
                        ),
                        items: _seasons.map((season) => DropdownMenuItem(
                          value: season,
                          child: Text(season),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedSeason = value!),
                        validator: (value) => value == null ? 'Please select season' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Environmental Conditions Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Environmental Conditions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Required fields
                      TextFormField(
                        controller: _rainfallController,
                        decoration: const InputDecoration(
                          labelText: 'Rainfall (mm) *',
                          prefixIcon: Icon(Icons.water_drop),
                          suffixText: 'mm',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter rainfall amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _temperatureController,
                        decoration: const InputDecoration(
                          labelText: 'Temperature (°C) *',
                          prefixIcon: Icon(Icons.thermostat),
                          suffixText: '°C',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter temperature';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _landSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Land Size (hectares) *',
                          prefixIcon: Icon(Icons.landscape),
                          suffixText: 'ha',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter land size';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Optional Parameters Section
              Card(
                child: ExpansionTile(
                  title: Text(
                    'Optional Parameters',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Add more details for better accuracy'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _humidityController,
                            decoration: const InputDecoration(
                              labelText: 'Humidity (%)',
                              prefixIcon: Icon(Icons.opacity),
                              suffixText: '%',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _phController,
                            decoration: const InputDecoration(
                              labelText: 'Soil pH',
                              prefixIcon: Icon(Icons.science),
                              hintText: '6.0 - 8.0',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _nitrogenController,
                            decoration: const InputDecoration(
                              labelText: 'Nitrogen Content (kg/ha)',
                              prefixIcon: Icon(Icons.eco),
                              suffixText: 'kg/ha',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _phosphorusController,
                            decoration: const InputDecoration(
                              labelText: 'Phosphorus Content (kg/ha)',
                              prefixIcon: Icon(Icons.eco),
                              suffixText: 'kg/ha',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _potassiumController,
                            decoration: const InputDecoration(
                              labelText: 'Potassium Content (kg/ha)',
                              prefixIcon: Icon(Icons.eco),
                              suffixText: 'kg/ha',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Predict Button
              ElevatedButton.icon(
                onPressed: _serverConnected && !_isLoading ? _predictYield : null,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology),
                label: Text(_isLoading ? 'Predicting...' : 'Predict Yield'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Prediction Result
              if (_predictionResult != null) _buildPredictionResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionResult() {
    final result = _predictionResult!;
    
    return Card(
      elevation: 8,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green[700], size: 32),
                const SizedBox(width: 12),
                Text(
                  'Yield Prediction',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main Prediction
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Predicted Yield',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.predictedYield.toStringAsFixed(2)} ${result.unit}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(result.confidence * 100).toInt()}% Confidence',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Model Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Model Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Algorithm:', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        result.modelName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Accuracy (R²):', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        '${(result.r2Score * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Average Error:', style: TextStyle(color: Colors.grey[600])),
                      Text(
                        '±${result.mae.toStringAsFixed(1)} ${result.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _predictionResult = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Prediction'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // You can add functionality to save or share the result
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prediction saved to your farm records'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Result'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rainfallController.dispose();
    _temperatureController.dispose();
    _landSizeController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    super.dispose();
  }
}
