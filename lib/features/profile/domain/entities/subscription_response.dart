class SubscriptionProperty {
  final String id;
  final String name;
  final String address;
  final String? city;
  final int totalBeds;

  SubscriptionProperty({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    required this.totalBeds,
  });
}

class SubscriptionPlanBreakdown {
  final int totalBeds;
  final double taxableAmount;
  final double mrpTotal;
  final double discountAmount;
  final double gstAmount;
  final double totalAmount;
  final String? savingsText;
  final double perBedPerMonth;
  final String? formula;

  SubscriptionPlanBreakdown({
    required this.totalBeds,
    required this.taxableAmount,
    required this.mrpTotal,
    required this.discountAmount,
    required this.gstAmount,
    required this.totalAmount,
    this.savingsText,
    required this.perBedPerMonth,
    this.formula,
  });
}

class SubscriptionPlan {
  final String id;
  final String planCode;
  final String planName;
  final int durationMonths;
  final String billingCycle;
  final double pricePerBed;
  final double mrpPerBed;
  final int discountPercentage;
  final String pricingType;
  final int gstPercentage;
  final bool priceIncludesGst;
  final int? minBeds;
  final int? maxBeds;
  final bool isPopular;
  final bool isActive;
  final SubscriptionPlanBreakdown? breakdown;

  SubscriptionPlan({
    required this.id,
    required this.planCode,
    required this.planName,
    required this.durationMonths,
    required this.billingCycle,
    required this.pricePerBed,
    required this.mrpPerBed,
    required this.discountPercentage,
    required this.pricingType,
    required this.gstPercentage,
    required this.priceIncludesGst,
    this.minBeds,
    this.maxBeds,
    required this.isPopular,
    required this.isActive,
    this.breakdown,
  });
}

class ActiveSubscription {
  final String id;
  final String property;
  final String owner;
  final String? renewalOf;
  final String? propertyName;
  final String plan;
  final SubscriptionPlan planSnapshot;
  final double subscribedPricePerBed;
  final int totalBedsSnapshot;
  final int activeBedsSnapshot;
  final double discountAmount;
  final double couponDiscount;
  final double taxableAmount;
  final int gstPercentage;
  final double gstAmount;
  final double totalAmount;
  final String status;
  final String? razorpayOrderId;
  final int? razorpayAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? daysRemaining;
  final DateTime? nextBillingDate;
  final bool autoRenew;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final String? cancelledBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ActiveSubscription({
    required this.id,
    required this.property,
    required this.owner,
    this.renewalOf,
    this.propertyName,
    required this.plan,
    required this.planSnapshot,
    required this.subscribedPricePerBed,
    required this.totalBedsSnapshot,
    required this.activeBedsSnapshot,
    required this.discountAmount,
    required this.couponDiscount,
    required this.taxableAmount,
    required this.gstPercentage,
    required this.gstAmount,
    required this.totalAmount,
    required this.status,
    this.razorpayOrderId,
    this.razorpayAmount,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    this.nextBillingDate,
    required this.autoRenew,
    this.cancelledAt,
    this.cancelledReason,
    this.cancelledBy,
    this.createdAt,
    this.updatedAt,
  });
}

class SubscriptionResponse {
  final SubscriptionProperty property;
  final ActiveSubscription? activeSubscription;
  final List<SubscriptionPlan> plans;

  SubscriptionResponse({
    required this.property,
    this.activeSubscription,
    required this.plans,
  });
}
