import '../../domain/entities/subscription_response.dart';

class PlanOption {
  final String id;
  final String key;
  final String label;
  final String duration;
  final int months;
  final int discountPercent;
  final bool isBestValue;
  final double pricePerBed;
  final double mrpPerBed;
  final SubscriptionPlanBreakdown? breakdown;
  final int gstPercentage;
  final bool priceIncludesGst;

  const PlanOption({
    required this.id,
    required this.key,
    required this.label,
    required this.duration,
    required this.months,
    required this.discountPercent,
    required this.pricePerBed,
    required this.mrpPerBed,
    this.isBestValue = false,
    this.breakdown,
    required this.gstPercentage,
    required this.priceIncludesGst,
  });

  factory PlanOption.fromEntity(SubscriptionPlan plan) {
    String key = plan.planCode.toLowerCase();
    // Maintain key consistency for special cases if needed
    if (key == 'half_yearly') {
      key = 'half_yearly';
    }
    
    final duration = '${plan.durationMonths} ${plan.durationMonths == 1 ? 'month' : 'months'}';
    
    return PlanOption(
      id: plan.id,
      key: key,
      label: plan.planName,
      duration: duration,
      months: plan.durationMonths,
      discountPercent: plan.discountPercentage,
      pricePerBed: plan.pricePerBed,
      mrpPerBed: plan.mrpPerBed,
      isBestValue: plan.isPopular,
      breakdown: plan.breakdown,
      gstPercentage: plan.gstPercentage,
      priceIncludesGst: plan.priceIncludesGst,
    );
  }
}
