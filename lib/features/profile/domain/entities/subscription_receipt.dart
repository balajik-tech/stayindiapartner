class SubscriptionReceiptProperty {
  final String id;
  final String name;
  final String? uniqueId;
  final String? address;
  final String? city;
  final String? state;

  SubscriptionReceiptProperty({
    required this.id,
    required this.name,
    this.uniqueId,
    this.address,
    this.city,
    this.state,
  });

  factory SubscriptionReceiptProperty.fromJson(Map<String, dynamic> json) {
    return SubscriptionReceiptProperty(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Property',
      uniqueId: json['uniqueId']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
    );
  }
}

class SubscriptionReceiptPlan {
  final String planCode;
  final String planName;
  final String billingCycle;
  final int durationMonths;
  final double pricePerBed;

  SubscriptionReceiptPlan({
    required this.planCode,
    required this.planName,
    required this.billingCycle,
    required this.durationMonths,
    required this.pricePerBed,
  });

  factory SubscriptionReceiptPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionReceiptPlan(
      planCode: json['planCode']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      billingCycle: json['billingCycle']?.toString() ?? '',
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
      pricePerBed: (json['pricePerBed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SubscriptionReceiptSubscription {
  final String id;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalBeds;
  final SubscriptionReceiptPlan? plan;

  SubscriptionReceiptSubscription({
    required this.id,
    required this.status,
    this.startDate,
    this.endDate,
    required this.totalBeds,
    this.plan,
  });

  factory SubscriptionReceiptSubscription.fromJson(Map<String, dynamic> json) {
    return SubscriptionReceiptSubscription(
      id: json['_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      totalBeds: (json['totalBeds'] as num?)?.toInt() ?? 0,
      plan: json['plan'] is Map<String, dynamic>
          ? SubscriptionReceiptPlan.fromJson(json['plan'])
          : null,
    );
  }
}

class SubscriptionReceiptInvoice {
  final String id;
  final String invoiceNumber;
  final DateTime? invoiceDate;
  final String? documentType;
  final String status;
  final String? invoicePdf;

  SubscriptionReceiptInvoice({
    required this.id,
    required this.invoiceNumber,
    this.invoiceDate,
    this.documentType,
    required this.status,
    this.invoicePdf,
  });

  factory SubscriptionReceiptInvoice.fromJson(Map<String, dynamic> json) {
    return SubscriptionReceiptInvoice(
      id: json['_id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      invoiceDate: json['invoiceDate'] != null ? DateTime.tryParse(json['invoiceDate']) : null,
      documentType: json['documentType']?.toString(),
      status: json['status']?.toString() ?? '',
      invoicePdf: json['invoicePdf']?.toString(),
    );
  }
}

class SubscriptionReceiptBreakdown {
  final double taxableAmount;
  final int gstPercentage;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double gstAmount;
  final double totalAmount;

  SubscriptionReceiptBreakdown({
    required this.taxableAmount,
    required this.gstPercentage,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.gstAmount,
    required this.totalAmount,
  });

  factory SubscriptionReceiptBreakdown.fromJson(Map<String, dynamic> json) {
    return SubscriptionReceiptBreakdown(
      taxableAmount: (json['taxableAmount'] as num?)?.toDouble() ?? 0.0,
      gstPercentage: (json['gstPercentage'] as num?)?.toInt() ?? 0,
      cgstAmount: (json['cgstAmount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgstAmount'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (json['igstAmount'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SubscriptionReceipt {
  final String receiptId;
  final String paymentId;
  final String receiptNumber;
  final DateTime? receiptDate;
  final double amount;
  final String paymentMethod;
  final String paymentReference;
  final String transactionId;
  final String paymentStatus;
  final String? receiptUrl;
  final String? downloadUrl;
  final SubscriptionReceiptBreakdown? breakdown;
  final SubscriptionReceiptProperty? property;
  final SubscriptionReceiptSubscription? subscription;
  final SubscriptionReceiptInvoice? invoice;

  SubscriptionReceipt({
    required this.receiptId,
    required this.paymentId,
    required this.receiptNumber,
    this.receiptDate,
    required this.amount,
    required this.paymentMethod,
    required this.paymentReference,
    required this.transactionId,
    required this.paymentStatus,
    this.receiptUrl,
    this.downloadUrl,
    this.breakdown,
    this.property,
    this.subscription,
    this.invoice,
  });

  factory SubscriptionReceipt.fromJson(Map<String, dynamic> json) {
    return SubscriptionReceipt(
      receiptId: json['receiptId']?.toString() ?? '',
      paymentId: json['paymentId']?.toString() ?? '',
      receiptNumber: json['receiptNumber']?.toString() ?? '',
      receiptDate: json['receiptDate'] != null ? DateTime.tryParse(json['receiptDate']) : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentReference: json['paymentReference']?.toString() ?? '',
      transactionId: json['transactionId']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      receiptUrl: json['receiptUrl']?.toString(),
      downloadUrl: json['downloadUrl']?.toString(),
      breakdown: json['breakdown'] is Map<String, dynamic>
          ? SubscriptionReceiptBreakdown.fromJson(json['breakdown'])
          : null,
      property: json['property'] is Map<String, dynamic>
          ? SubscriptionReceiptProperty.fromJson(json['property'])
          : null,
      subscription: json['subscription'] is Map<String, dynamic>
          ? SubscriptionReceiptSubscription.fromJson(json['subscription'])
          : null,
      invoice: json['invoice'] is Map<String, dynamic>
          ? SubscriptionReceiptInvoice.fromJson(json['invoice'])
          : null,
    );
  }
}
