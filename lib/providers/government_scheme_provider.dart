import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/government_scheme_models.dart' as models;
import '../services/pdf_service.dart';
import '../services/notification_service.dart';
import '../services/government_api_service.dart';

class GovernmentSchemeProvider extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final PdfService _pdfService = PdfService();
  final NotificationService _notificationService = NotificationService();
  final GovernmentApiService _apiService = GovernmentApiService();

  // Voice Recognition
  bool _isListening = false;
  String _voiceInput = '';
  
  // Schemes and Applications
  List<models.GovernmentScheme> _availableSchemes = [];
  List<models.SchemeApplication> _userApplications = [];
  List<models.SubsidyBenefit> _subsidyBenefits = [];
  List<models.PolicyUpdate> _policyUpdates = [];
  
  // Form state
  models.GovernmentScheme? _selectedScheme;
  final Map<String, dynamic> _currentFormData = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Voice intent parsing
  String _lastParsedIntent = '';
  Map<String, String> _extractedDetails = {};

  // Getters
  bool get isListening => _isListening;
  String get voiceInput => _voiceInput;
  List<models.GovernmentScheme> get availableSchemes => _availableSchemes;
  List<models.SchemeApplication> get userApplications => _userApplications;
  List<models.SubsidyBenefit> get subsidyBenefits => _subsidyBenefits;
  List<models.PolicyUpdate> get policyUpdates => _policyUpdates;
  models.GovernmentScheme? get selectedScheme => _selectedScheme;
  Map<String, dynamic> get currentFormData => _currentFormData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get lastParsedIntent => _lastParsedIntent;
  Map<String, String> get extractedDetails => _extractedDetails;

  GovernmentSchemeProvider() {
    _initializeSchemes();
    _initializeSpeech();
    _loadStoredData();
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize();
  }

  Future<void> _initializeSchemes() async {
    _setLoading(true);
    try {
      _availableSchemes = await _loadDefaultSchemes();
      await _loadPolicyUpdates();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load schemes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load applications
    final applicationsJson = prefs.getString('user_applications');
    if (applicationsJson != null) {
      final List<dynamic> applicationsList = json.decode(applicationsJson);
      _userApplications = applicationsList
          .map((app) => models.SchemeApplication.fromJson(app))
          .toList();
    }

    // Load subsidy benefits
    final benefitsJson = prefs.getString('subsidy_benefits');
    if (benefitsJson != null) {
      final List<dynamic> benefitsList = json.decode(benefitsJson);
      _subsidyBenefits = benefitsList
          .map((benefit) => models.SubsidyBenefit.fromJson(benefit))
          .toList();
    }

    notifyListeners();
  }

  Future<void> _saveStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save applications
    final applicationsJson = json.encode(
      _userApplications.map((app) => app.toJson()).toList()
    );
    await prefs.setString('user_applications', applicationsJson);

    // Save subsidy benefits
    final benefitsJson = json.encode(
      _subsidyBenefits.map((benefit) => benefit.toJson()).toList()
    );
    await prefs.setString('subsidy_benefits', benefitsJson);
  }

  // Voice to Form Filling
  Future<void> startVoiceInput() async {
    if (!_speechToText.isAvailable) return;

    _isListening = true;
    _voiceInput = '';
    notifyListeners();

    await _speechToText.listen(
      onResult: (result) {
        _voiceInput = result.recognizedWords;
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'hi-IN', // Default to Hindi
    );
  }

  Future<void> stopVoiceInput() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
      
      if (_voiceInput.isNotEmpty) {
        await _parseVoiceIntent(_voiceInput);
      }
      
      notifyListeners();
    }
  }

  Future<void> _parseVoiceIntent(String input) async {
    _setLoading(true);
    
    try {
      // Simple intent parsing - can be enhanced with ML models
      final intentResult = await _analyzeIntent(input);
      _lastParsedIntent = intentResult['intent'] ?? '';
      _extractedDetails = Map<String, String>.from(intentResult['details'] ?? {});
      
      // Auto-fill form based on extracted details
      if (_selectedScheme != null) {
        await _autoFillForm();
      }
      
    } catch (e) {
      _setError('Failed to parse voice input: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> _analyzeIntent(String input) async {
    // Enhanced intent parsing
    final lowerInput = input.toLowerCase();
    
    Map<String, dynamic> result = {
      'intent': '',
      'details': <String, String>{},
    };

    // Intent detection
    if (lowerInput.contains('pm kisan') || lowerInput.contains('पीएम किसान')) {
      result['intent'] = 'pm_kisan_application';
    } else if (lowerInput.contains('fertilizer') || lowerInput.contains('खाद')) {
      result['intent'] = 'fertilizer_subsidy';
    } else if (lowerInput.contains('kisan credit') || lowerInput.contains('किसान क्रेडिट')) {
      result['intent'] = 'kisan_credit_card';
    } else if (lowerInput.contains('status') || lowerInput.contains('स्थिति')) {
      result['intent'] = 'check_status';
    }

    // Extract details using regex patterns
    result['details'] = _extractDetailsFromText(input);
    
    return result;
  }

  Map<String, String> _extractDetailsFromText(String text) {
    Map<String, String> details = {};
    
    // Extract Aadhaar numbers
    RegExp aadhaarPattern = RegExp(r'\b\d{4}\s*\d{4}\s*\d{4}\b');
    final aadhaarMatch = aadhaarPattern.firstMatch(text);
    if (aadhaarMatch != null) {
      details['aadhaar'] = aadhaarMatch.group(0)!.replaceAll(' ', '');
    }

    // Extract mobile numbers
    RegExp mobilePattern = RegExp(r'\b[6-9]\d{9}\b');
    final mobileMatch = mobilePattern.firstMatch(text);
    if (mobileMatch != null) {
      details['mobile'] = mobileMatch.group(0)!;
    }

    // Extract names (basic pattern)
    RegExp namePattern = RegExp(r'(?:name|नाम)\s+(?:is|है)?\s+([A-Za-z\u0900-\u097F\s]+)', 
        caseSensitive: false);
    final nameMatch = namePattern.firstMatch(text);
    if (nameMatch != null) {
      details['name'] = nameMatch.group(1)!.trim();
    }

    // Extract land size
    RegExp landPattern = RegExp(r'(\d+(?:\.\d+)?)\s*(?:acre|एकड़|hectare|हेक्टेयर)', 
        caseSensitive: false);
    final landMatch = landPattern.firstMatch(text);
    if (landMatch != null) {
      details['landSize'] = landMatch.group(1)!;
    }

    return details;
  }

  Future<void> _autoFillForm() async {
    if (_selectedScheme == null) return;

    for (final field in _selectedScheme!.requiredFields) {
      String? value = _extractedDetails[field.id];
      
      if (value != null) {
        _currentFormData[field.id] = value;
      }
    }
    
    notifyListeners();
  }

  // Scheme selection and form management
  void selectScheme(models.GovernmentScheme scheme) {
    _selectedScheme = scheme;
    _currentFormData.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void updateFormField(String fieldId, dynamic value) {
    _currentFormData[fieldId] = value;
    notifyListeners();
  }

  Future<void> submitApplication() async {
    if (_selectedScheme == null) return;

    _setLoading(true);
    
    try {
      // Validate form
      final validation = _validateForm();
      if (!validation['isValid']) {
        _setError(validation['message']);
        return;
      }

      // Create application
      final application = models.SchemeApplication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        schemeId: _selectedScheme!.id,
        schemeName: _selectedScheme!.name,
        formData: Map<String, dynamic>.from(_currentFormData),
        status: models.ApplicationStatus.submitted,
        appliedDate: DateTime.now(),
        trackingNumber: _generateTrackingNumber(),
        statusUpdates: [
          models.StatusUpdate(
            status: 'submitted',
            message: 'Application submitted successfully',
            messageHindi: 'आवेदन सफलतापूर्वक जमा किया गया',
            timestamp: DateTime.now(),
          ),
        ],
      );

      // Generate PDF
      final pdfPath = await _pdfService.generateApplicationPdf(
        application, 
        _selectedScheme!
      );
      
      // Update application with PDF path
      final updatedApplication = models.SchemeApplication(
        id: application.id,
        schemeId: application.schemeId,
        schemeName: application.schemeName,
        formData: application.formData,
        status: application.status,
        appliedDate: application.appliedDate,
        trackingNumber: application.trackingNumber,
        documentPath: pdfPath,
        statusUpdates: application.statusUpdates,
      );

      _userApplications.add(updatedApplication);
      await _saveStoredData();

      // Send notification
      await _notificationService.showNotification(
        'Application Submitted',
        'Your ${_selectedScheme!.name} application has been submitted.',
      );

      // Clear form
      _selectedScheme = null;
      _currentFormData.clear();
      
    } catch (e) {
      _setError('Failed to submit application: $e');
    } finally {
      _setLoading(false);
    }
  }

  Map<String, dynamic> _validateForm() {
    if (_selectedScheme == null) {
      return {'isValid': false, 'message': 'No scheme selected'};
    }

    for (final field in _selectedScheme!.requiredFields) {
      if (field.isRequired && 
          (!_currentFormData.containsKey(field.id) || 
           _currentFormData[field.id]?.toString().isEmpty == true)) {
        return {
          'isValid': false, 
          'message': 'Please fill required field: ${field.label}'
        };
      }
    }

    return {'isValid': true};
  }

  String _generateTrackingNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'KV${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  // Document Management
  Future<List<models.SchemeApplication>> searchApplications(String query) async {
    if (query.isEmpty) return _userApplications;

    return _userApplications.where((app) {
      return app.schemeName.toLowerCase().contains(query.toLowerCase()) ||
             app.trackingNumber?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }

  Future<void> deleteApplication(String applicationId) async {
    _userApplications.removeWhere((app) => app.id == applicationId);
    await _saveStoredData();
    notifyListeners();
  }

  // Subsidy & Benefit Tracking
  Future<void> checkSubsidyStatus() async {
    _setLoading(true);
    
    try {
      final benefits = await _apiService.fetchSubsidyBenefits();
      _subsidyBenefits = benefits;
      await _saveStoredData();
    } catch (e) {
      _setError('Failed to fetch subsidy status: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateApplicationStatus(String applicationId) async {
    _setLoading(true);
    
    try {
      final status = await _apiService.getApplicationStatus(applicationId);
      
      final appIndex = _userApplications.indexWhere((app) => app.id == applicationId);
      if (appIndex != -1) {
        _userApplications[appIndex] = status;
        await _saveStoredData();
        
        // Send notification for status update
        await _notificationService.showNotification(
          'Application Update',
          'Status updated for ${status.schemeName}',
        );
      }
    } catch (e) {
      _setError('Failed to update application status: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Policy Updates Feed
  Future<void> _loadPolicyUpdates() async {
    try {
      _policyUpdates = await _apiService.fetchPolicyUpdates();
      
      // Notify for important updates
      for (final update in _policyUpdates.where((u) => u.isImportant)) {
        await _notificationService.showNotification(
          'Important Policy Update',
          update.title,
        );
      }
      
    } catch (e) {
      print('Failed to load policy updates: $e');
    }
  }

  Future<void> refreshPolicyUpdates() async {
    await _loadPolicyUpdates();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Default schemes data
  Future<List<models.GovernmentScheme>> _loadDefaultSchemes() async {
    return [
      models.GovernmentScheme(
        id: 'pm_kisan',
        name: 'PM-KISAN Samman Nidhi',
        nameHindi: 'पीएम-किसान सम्मान निधि',
        description: 'Income support scheme providing ₹6,000 per year to farmers',
        descriptionHindi: 'किसानों को प्रति वर्ष ₹6,000 की आय सहायता योजना',
        category: 'Income Support',
        eligibilityCriteria: [
          'Small and marginal farmers',
          'Land ownership up to 2 hectares',
          'Valid Aadhaar card',
          'Bank account linked with Aadhaar'
        ],
        requiredFields: [
          models.FormField(
            id: 'name',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            type: models.FormFieldType.text,
          ),
          models.FormField(
            id: 'aadhaar',
            label: 'Aadhaar Number',
            labelHindi: 'आधार संख्या',
            type: models.FormFieldType.aadhaar,
          ),
          models.FormField(
            id: 'mobile',
            label: 'Mobile Number',
            labelHindi: 'मोबाइल नंबर',
            type: models.FormFieldType.phone,
          ),
          models.FormField(
            id: 'landSize',
            label: 'Land Size (Acres)',
            labelHindi: 'भूमि का आकार (एकड़)',
            type: models.FormFieldType.landSize,
          ),
          models.FormField(
            id: 'bankAccount',
            label: 'Bank Account Number',
            labelHindi: 'बैंक खाता संख्या',
            type: models.FormFieldType.bankAccount,
          ),
          models.FormField(
            id: 'ifsc',
            label: 'IFSC Code',
            labelHindi: 'आईएफएससी कोड',
            type: models.FormFieldType.ifsc,
          ),
        ],
        benefitAmount: '₹6,000 per year',
        applicationDeadline: 'No deadline',
        officialUrl: 'https://pmkisan.gov.in/',
        lastUpdated: DateTime.now(),
      ),
      models.GovernmentScheme(
        id: 'kisan_credit_card',
        name: 'Kisan Credit Card',
        nameHindi: 'किसान क्रेडिट कार्ड',
        description: 'Credit facility for agricultural and allied activities',
        descriptionHindi: 'कृषि और संबद्ध गतिविधियों के लिए ऋण सुविधा',
        category: 'Credit',
        eligibilityCriteria: [
          'Farmers with cultivable land',
          'Share croppers and tenant farmers',
          'Self Help Group members',
          'Joint Liability Group members'
        ],
        requiredFields: [
          models.FormField(
            id: 'name',
            label: 'Full Name',
            labelHindi: 'पूरा नाम',
            type: models.FormFieldType.text,
          ),
          models.FormField(
            id: 'aadhaar',
            label: 'Aadhaar Number',
            labelHindi: 'आधार संख्या',
            type: models.FormFieldType.aadhaar,
          ),
          models.FormField(
            id: 'pan',
            label: 'PAN Number',
            labelHindi: 'पैन संख्या',
            type: models.FormFieldType.pan,
          ),
          models.FormField(
            id: 'landSize',
            label: 'Total Land Area',
            labelHindi: 'कुल भूमि क्षेत्र',
            type: models.FormFieldType.landSize,
          ),
          models.FormField(
            id: 'cropType',
            label: 'Primary Crop',
            labelHindi: 'मुख्य फसल',
            type: models.FormFieldType.cropType,
            options: ['Rice', 'Wheat', 'Cotton', 'Sugarcane', 'Other'],
          ),
        ],
        benefitAmount: 'Up to ₹3 lakhs',
        applicationDeadline: 'No deadline',
        officialUrl: 'https://www.nabard.org/content1.aspx?id=570',
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }
}
