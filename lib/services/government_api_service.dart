import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/government_scheme_models.dart';

class GovernmentApiService {
  static const String baseUrl = 'https://api.example.gov.in'; // Mock API endpoint
  static const String apiKey = 'your_api_key_here';

  // Mock data for demonstration
  Future<List<SubsidyBenefit>> fetchSubsidyBenefits() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Return mock data
    return [
      SubsidyBenefit(
        id: '1',
        title: 'PM-KISAN Installment',
        titleHindi: 'पीएम-किसान किस्त',
        amount: '2000',
        status: 'Credited',
        date: DateTime.now().subtract(const Duration(days: 30)),
        transactionId: 'TXN123456789',
        category: 'Income Support',
      ),
      SubsidyBenefit(
        id: '2',
        title: 'Fertilizer Subsidy',
        titleHindi: 'उर्वरक सब्सिडी',
        amount: '1500',
        status: 'Processing',
        date: DateTime.now().subtract(const Duration(days: 15)),
        category: 'Input Subsidy',
      ),
      SubsidyBenefit(
        id: '3',
        title: 'Crop Insurance Claim',
        titleHindi: 'फसल बीमा दावा',
        amount: '5000',
        status: 'Approved',
        date: DateTime.now().subtract(const Duration(days: 60)),
        transactionId: 'INS987654321',
        category: 'Insurance',
      ),
    ];
  }

  Future<SchemeApplication> getApplicationStatus(String applicationId) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock status update
    final random = Random();
    final statuses = [
      ApplicationStatus.submitted,
      ApplicationStatus.underReview,
      ApplicationStatus.documentsPending,
      ApplicationStatus.approved,
    ];

    final newStatus = statuses[random.nextInt(statuses.length)];
    
    return SchemeApplication(
      id: applicationId,
      schemeId: 'pm_kisan',
      schemeName: 'PM-KISAN Samman Nidhi',
      formData: {},
      status: newStatus,
      appliedDate: DateTime.now().subtract(const Duration(days: 10)),
      lastUpdated: DateTime.now(),
      trackingNumber: 'KV${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      statusUpdates: [
        StatusUpdate(
          status: 'submitted',
          message: 'Application submitted successfully',
          messageHindi: 'आवेदन सफलतापूर्वक जमा किया गया',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
        ),
        StatusUpdate(
          status: newStatus.name,
          message: _getStatusMessage(newStatus),
          messageHindi: _getStatusMessageHindi(newStatus),
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<List<PolicyUpdate>> fetchPolicyUpdates() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return [
      PolicyUpdate(
        id: '1',
        title: 'New Crop Insurance Guidelines',
        titleHindi: 'नई फसल बीमा दिशानिर्देश',
        content: 'Updated guidelines for crop insurance claims and coverage',
        contentHindi: 'फसल बीमा दावों और कवरेज के लिए अद्यतन दिशानिर्देश',
        category: 'Insurance',
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        sourceUrl: 'https://pmfby.gov.in',
        isImportant: true,
      ),
      PolicyUpdate(
        id: '2',
        title: 'Fertilizer Subsidy Rate Update',
        titleHindi: 'उर्वरक सब्सिडी दर अपडेट',
        content: 'Revised subsidy rates for various fertilizers',
        contentHindi: 'विभिन्न उर्वरकों के लिए संशोधित सब्सिडी दरें',
        category: 'Subsidy',
        publishedDate: DateTime.now().subtract(const Duration(days: 5)),
        sourceUrl: 'https://fert.nic.in',
        isImportant: false,
      ),
      PolicyUpdate(
        id: '3',
        title: 'Kisan Rail Service Expansion',
        titleHindi: 'किसान रेल सेवा विस्तार',
        content: 'New routes added to Kisan Rail for better connectivity',
        contentHindi: 'बेहतर कनेक्टिविटी के लिए किसान रेल में नए रूट जोड़े गए',
        category: 'Transportation',
        publishedDate: DateTime.now().subtract(const Duration(days: 7)),
        sourceUrl: 'https://indianrailways.gov.in',
        isImportant: false,
      ),
    ];
  }

  Future<bool> submitApplication(
    String schemeId, 
    Map<String, dynamic> formData
  ) async {
    try {
      // In a real implementation, this would send data to the government API
      final response = await http.post(
        Uri.parse('$baseUrl/schemes/$schemeId/apply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(formData),
      );

      return response.statusCode == 200;
    } catch (e) {
      // For now, simulate successful submission
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }
  }

  Future<Map<String, dynamic>> checkEligibility(
    String schemeId, 
    Map<String, dynamic> userProfile
  ) async {
    // Mock eligibility check
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    final isEligible = random.nextBool();

    return {
      'eligible': isEligible,
      'reasons': isEligible 
        ? ['All eligibility criteria met']
        : ['Land size exceeds limit', 'Income above threshold'],
      'score': random.nextInt(100),
    };
  }

  Future<List<GovernmentScheme>> searchSchemes(String query) async {
    // Mock search functionality
    await Future.delayed(const Duration(milliseconds: 500));

    // This would typically search through available schemes
    // For now, return empty list as schemes are loaded locally
    return [];
  }

  Future<void> registerForUpdates(String phoneNumber, List<String> categories) async {
    // Mock registration for SMS/WhatsApp updates
    await Future.delayed(const Duration(seconds: 1));
    
    print('Registered $phoneNumber for updates in categories: $categories');
  }

  Future<List<String>> getRequiredDocuments(String schemeId) async {
    // Mock document requirements
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<String, List<String>> schemeDocuments = {
      'pm_kisan': [
        'Aadhaar Card',
        'Bank Account Details',
        'Land Records',
        'Mobile Number',
      ],
      'kisan_credit_card': [
        'Aadhaar Card',
        'PAN Card',
        'Land Records',
        'Income Certificate',
        'Bank Statement',
      ],
      'crop_insurance': [
        'Aadhaar Card',
        'Land Records',
        'Crop Details',
        'Bank Account Details',
      ],
    };

    return schemeDocuments[schemeId] ?? [];
  }

  Future<double> calculateBenefit(
    String schemeId, 
    Map<String, dynamic> userData
  ) async {
    // Mock benefit calculation
    await Future.delayed(const Duration(milliseconds: 500));

    switch (schemeId) {
      case 'pm_kisan':
        return 6000.0; // Fixed amount
      case 'kisan_credit_card':
        final landSize = double.tryParse(userData['landSize']?.toString() ?? '0') ?? 0;
        return landSize * 150000; // ₹1.5 lakh per hectare
      case 'fertilizer_subsidy':
        final landSize = double.tryParse(userData['landSize']?.toString() ?? '0') ?? 0;
        return landSize * 2000; // ₹2000 per hectare
      default:
        return 0.0;
    }
  }

  String _getStatusMessage(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'Application submitted successfully';
      case ApplicationStatus.underReview:
        return 'Application is under review';
      case ApplicationStatus.documentsPending:
        return 'Additional documents required';
      case ApplicationStatus.approved:
        return 'Application approved';
      case ApplicationStatus.rejected:
        return 'Application rejected';
      case ApplicationStatus.paymentProcessing:
        return 'Payment is being processed';
      case ApplicationStatus.completed:
        return 'Application completed successfully';
      default:
        return 'Status updated';
    }
  }

  String _getStatusMessageHindi(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'आवेदन सफलतापूर्वक जमा किया गया';
      case ApplicationStatus.underReview:
        return 'आवेदन की समीक्षा की जा रही है';
      case ApplicationStatus.documentsPending:
        return 'अतिरिक्त दस्तावेज आवश्यक';
      case ApplicationStatus.approved:
        return 'आवेदन स्वीकृत';
      case ApplicationStatus.rejected:
        return 'आवेदन अस्वीकृत';
      case ApplicationStatus.paymentProcessing:
        return 'भुगतान प्रक्रिया में है';
      case ApplicationStatus.completed:
        return 'आवेदन सफलतापूर्वक पूर्ण';
      default:
        return 'स्थिति अपडेट की गई';
    }
  }

  // Web scraping simulation for policy updates
  Future<List<PolicyUpdate>> scrapeGovernmentWebsites() async {
    // In a real implementation, this would scrape government websites
    // For now, return mock data
    await Future.delayed(const Duration(seconds: 3));

    return [
      PolicyUpdate(
        id: 'scraped_1',
        title: 'Latest Agricultural Policy Changes',
        titleHindi: 'नवीनतम कृषि नीति परिवर्तन',
        content: 'New policies announced for agricultural development',
        contentHindi: 'कृषि विकास के लिए नई नीतियों की घोषणा',
        category: 'Policy',
        publishedDate: DateTime.now(),
        sourceUrl: 'https://agricoop.gov.in',
        isImportant: true,
      ),
    ];
  }
}
