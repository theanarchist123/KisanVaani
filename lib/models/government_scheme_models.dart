class GovernmentScheme {
  final String id;
  final String name;
  final String nameHindi;
  final String description;
  final String descriptionHindi;
  final String category;
  final List<String> eligibilityCriteria;
  final List<FormField> requiredFields;
  final String benefitAmount;
  final String applicationDeadline;
  final String officialUrl;
  final bool isActive;
  final DateTime lastUpdated;

  GovernmentScheme({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.description,
    required this.descriptionHindi,
    required this.category,
    required this.eligibilityCriteria,
    required this.requiredFields,
    required this.benefitAmount,
    required this.applicationDeadline,
    required this.officialUrl,
    this.isActive = true,
    required this.lastUpdated,
  });

  factory GovernmentScheme.fromJson(Map<String, dynamic> json) {
    return GovernmentScheme(
      id: json['id'],
      name: json['name'],
      nameHindi: json['nameHindi'],
      description: json['description'],
      descriptionHindi: json['descriptionHindi'],
      category: json['category'],
      eligibilityCriteria: List<String>.from(json['eligibilityCriteria']),
      requiredFields: (json['requiredFields'] as List)
          .map((field) => FormField.fromJson(field))
          .toList(),
      benefitAmount: json['benefitAmount'],
      applicationDeadline: json['applicationDeadline'],
      officialUrl: json['officialUrl'],
      isActive: json['isActive'] ?? true,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameHindi': nameHindi,
      'description': description,
      'descriptionHindi': descriptionHindi,
      'category': category,
      'eligibilityCriteria': eligibilityCriteria,
      'requiredFields': requiredFields.map((field) => field.toJson()).toList(),
      'benefitAmount': benefitAmount,
      'applicationDeadline': applicationDeadline,
      'officialUrl': officialUrl,
      'isActive': isActive,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class FormField {
  final String id;
  final String label;
  final String labelHindi;
  final FormFieldType type;
  final bool isRequired;
  final String? placeholder;
  final List<String>? options;
  final String? validationPattern;
  final String? errorMessage;

  FormField({
    required this.id,
    required this.label,
    required this.labelHindi,
    required this.type,
    this.isRequired = true,
    this.placeholder,
    this.options,
    this.validationPattern,
    this.errorMessage,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'],
      label: json['label'],
      labelHindi: json['labelHindi'],
      type: FormFieldType.values[json['type']],
      isRequired: json['isRequired'] ?? true,
      placeholder: json['placeholder'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      validationPattern: json['validationPattern'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'labelHindi': labelHindi,
      'type': type.index,
      'isRequired': isRequired,
      'placeholder': placeholder,
      'options': options,
      'validationPattern': validationPattern,
      'errorMessage': errorMessage,
    };
  }
}

enum FormFieldType {
  text,
  number,
  email,
  phone,
  aadhaar,
  pan,
  dropdown,
  date,
  address,
  bankAccount,
  ifsc,
  landSize,
  cropType,
}

class SchemeApplication {
  final String id;
  final String schemeId;
  final String schemeName;
  final Map<String, dynamic> formData;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final DateTime? lastUpdated;
  final String? trackingNumber;
  final String? rejectionReason;
  final String? documentPath;
  final List<StatusUpdate> statusUpdates;

  SchemeApplication({
    required this.id,
    required this.schemeId,
    required this.schemeName,
    required this.formData,
    required this.status,
    required this.appliedDate,
    this.lastUpdated,
    this.trackingNumber,
    this.rejectionReason,
    this.documentPath,
    this.statusUpdates = const [],
  });

  factory SchemeApplication.fromJson(Map<String, dynamic> json) {
    return SchemeApplication(
      id: json['id'],
      schemeId: json['schemeId'],
      schemeName: json['schemeName'],
      formData: Map<String, dynamic>.from(json['formData']),
      status: ApplicationStatus.values[json['status']],
      appliedDate: DateTime.parse(json['appliedDate']),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated']) 
          : null,
      trackingNumber: json['trackingNumber'],
      rejectionReason: json['rejectionReason'],
      documentPath: json['documentPath'],
      statusUpdates: (json['statusUpdates'] as List?)
          ?.map((update) => StatusUpdate.fromJson(update))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schemeId': schemeId,
      'schemeName': schemeName,
      'formData': formData,
      'status': status.index,
      'appliedDate': appliedDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'trackingNumber': trackingNumber,
      'rejectionReason': rejectionReason,
      'documentPath': documentPath,
      'statusUpdates': statusUpdates.map((update) => update.toJson()).toList(),
    };
  }
}

enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  documentsPending,
  paymentProcessing,
  completed,
}

class StatusUpdate {
  final String status;
  final String message;
  final String messageHindi;
  final DateTime timestamp;

  StatusUpdate({
    required this.status,
    required this.message,
    required this.messageHindi,
    required this.timestamp,
  });

  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      status: json['status'],
      message: json['message'],
      messageHindi: json['messageHindi'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'messageHindi': messageHindi,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class SubsidyBenefit {
  final String id;
  final String title;
  final String titleHindi;
  final String amount;
  final String status;
  final DateTime date;
  final String? transactionId;
  final String category;

  SubsidyBenefit({
    required this.id,
    required this.title,
    required this.titleHindi,
    required this.amount,
    required this.status,
    required this.date,
    this.transactionId,
    required this.category,
  });

  factory SubsidyBenefit.fromJson(Map<String, dynamic> json) {
    return SubsidyBenefit(
      id: json['id'],
      title: json['title'],
      titleHindi: json['titleHindi'],
      amount: json['amount'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      transactionId: json['transactionId'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleHindi': titleHindi,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
      'transactionId': transactionId,
      'category': category,
    };
  }
}

class PolicyUpdate {
  final String id;
  final String title;
  final String titleHindi;
  final String content;
  final String contentHindi;
  final String category;
  final DateTime publishedDate;
  final String sourceUrl;
  final bool isImportant;

  PolicyUpdate({
    required this.id,
    required this.title,
    required this.titleHindi,
    required this.content,
    required this.contentHindi,
    required this.category,
    required this.publishedDate,
    required this.sourceUrl,
    this.isImportant = false,
  });

  factory PolicyUpdate.fromJson(Map<String, dynamic> json) {
    return PolicyUpdate(
      id: json['id'],
      title: json['title'],
      titleHindi: json['titleHindi'],
      content: json['content'],
      contentHindi: json['contentHindi'],
      category: json['category'],
      publishedDate: DateTime.parse(json['publishedDate']),
      sourceUrl: json['sourceUrl'],
      isImportant: json['isImportant'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleHindi': titleHindi,
      'content': content,
      'contentHindi': contentHindi,
      'category': category,
      'publishedDate': publishedDate.toIso8601String(),
      'sourceUrl': sourceUrl,
      'isImportant': isImportant,
    };
  }
}
