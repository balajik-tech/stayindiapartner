import 'package:stayindia_owner/features/profile/domain/entities/subscription_response.dart';

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  final stringValue = value.toString().toLowerCase();
  return stringValue == 'true' || stringValue == '1' || stringValue == 'yes';
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

class SubscriptionPropertyModel extends SubscriptionProperty {
  SubscriptionPropertyModel({
    required super.id,
    required super.name,
    required super.address,
    super.city,
    required super.totalBeds,
  });

  factory SubscriptionPropertyModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPropertyModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] as String?,
      totalBeds: _parseInt(json['totalBeds'] ?? json['totalBedsSnapshot'] ?? 0),
    );
  }
}

class SubscriptionPlanBreakdownModel extends SubscriptionPlanBreakdown {
  SubscriptionPlanBreakdownModel({
    required super.totalBeds,
    required super.taxableAmount,
    required super.mrpTotal,
    required super.discountAmount,
    required super.gstAmount,
    required super.totalAmount,
    super.savingsText,
    required super.perBedPerMonth,
    super.formula,
  });

  factory SubscriptionPlanBreakdownModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanBreakdownModel(
      totalBeds: _parseInt(json['totalBeds']),
      taxableAmount: _parseDouble(json['taxableAmount']),
      mrpTotal: _parseDouble(json['mrpTotal']),
      discountAmount: _parseDouble(json['discountAmount']),
      gstAmount: _parseDouble(json['gstAmount']),
      totalAmount: _parseDouble(json['totalAmount']),
      savingsText: json['savingsText']?.toString(),
      perBedPerMonth: _parseDouble(json['perBedPerMonth']),
      formula: json['formula'] as String?,
    );
  }
}

class SubscriptionPlanModel extends SubscriptionPlan {
  SubscriptionPlanModel({
    required super.id,
    required super.planCode,
    required super.planName,
    required super.durationMonths,
    required super.billingCycle,
    required super.pricePerBed,
    required super.mrpPerBed,
    required super.discountPercentage,
    required super.pricingType,
    required super.gstPercentage,
    required super.priceIncludesGst,
    super.minBeds,
    super.maxBeds,
    required super.isPopular,
    required super.isActive,
    super.breakdown,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['_id'] ?? json['id'] ?? '',
      planCode: json['planCode'] ?? '',
      planName: json['planName'] ?? '',
      durationMonths: _parseInt(json['durationMonths']),
      billingCycle: json['billingCycle'] ?? '',
      pricePerBed: _parseDouble(json['pricePerBed']),
      mrpPerBed: _parseDouble(json['mrpPerBed']),
      discountPercentage: _parseInt(json['discountPercentage']),
      pricingType: json['pricingType'] ?? '',
      gstPercentage: _parseInt(json['gstPercentage']),
      priceIncludesGst: _parseBool(json['priceIncludesGst']),
      minBeds: json['minBeds'] is int ? json['minBeds'] : int.tryParse(json['minBeds']?.toString() ?? ''),
      maxBeds: json['maxBeds'] is int ? json['maxBeds'] : int.tryParse(json['maxBeds']?.toString() ?? ''),
      isPopular: _parseBool(json['isPopular']),
      isActive: _parseBool(json['isActive']),
      breakdown: json['breakdown'] is Map<String, dynamic>
          ? SubscriptionPlanBreakdownModel.fromJson(json['breakdown'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ActiveSubscriptionModel extends ActiveSubscription {
  ActiveSubscriptionModel({
    required super.id,
    required super.property,
    required super.owner,
    super.renewalOf,
    required super.plan,
    required super.planSnapshot,
    required super.subscribedPricePerBed,
    required super.totalBedsSnapshot,
    required super.activeBedsSnapshot,
    required super.discountAmount,
    required super.couponDiscount,
    required super.taxableAmount,
    required super.gstPercentage,
    required super.gstAmount,
    required super.totalAmount,
    required super.status,
    super.razorpayOrderId,
    super.razorpayAmount,
    super.startDate,
    super.endDate,
    super.nextBillingDate,
    required super.autoRenew,
    super.cancelledAt,
    super.cancelledReason,
    super.cancelledBy,
    super.createdAt,
    super.updatedAt,
  });

  factory ActiveSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionModel(
      id: json['_id'] ?? json['id'] ?? '',
      property: json['property']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      renewalOf: json['renewalOf']?.toString(),
      plan: json['plan']?.toString() ?? '',
      planSnapshot: SubscriptionPlanModel.fromJson(json['planSnapshot'] as Map<String, dynamic>),
      subscribedPricePerBed: _parseDouble(json['subscribedPricePerBed']),
      totalBedsSnapshot: _parseInt(json['totalBedsSnapshot']),
      activeBedsSnapshot: _parseInt(json['activeBedsSnapshot']),
      discountAmount: _parseDouble(json['discountAmount']),
      couponDiscount: _parseDouble(json['couponDiscount']),
      taxableAmount: _parseDouble(json['taxableAmount']),
      gstPercentage: _parseInt(json['gstPercentage']),
      gstAmount: _parseDouble(json['gstAmount']),
      totalAmount: _parseDouble(json['totalAmount']),
      status: json['status']?.toString() ?? 'ACTIVE',
      razorpayOrderId: json['razorpayOrderId']?.toString() ?? json['orderId']?.toString(),
      razorpayAmount: _parseInt(json['razorpayAmount']),
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      nextBillingDate: _parseDateTime(json['nextBillingDate']),
      autoRenew: _parseBool(json['autoRenew']),
      cancelledAt: _parseDateTime(json['cancelledAt']),
      cancelledReason: json['cancelledReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

class SubscriptionResponseModel extends SubscriptionResponse {
  SubscriptionResponseModel({
    required super.property,
    super.activeSubscription,
    required super.plans,
  });

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponseModel(
      property: SubscriptionPropertyModel.fromJson(json['property'] as Map<String, dynamic>),
      activeSubscription: json['activeSubscription'] is Map<String, dynamic>
          ? ActiveSubscriptionModel.fromJson(json['activeSubscription'] as Map<String, dynamic>)
          : null,
      plans: (json['plans'] as List<dynamic>?)
              ?.map((item) => SubscriptionPlanModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
