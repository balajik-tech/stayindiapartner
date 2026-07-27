class Hostel {
  final String id;
  final String name;
  final String address;
  final int floors;
  final String hostelType;
  final String? city;
  final String? district;
  final String? village;
  final String? state;
  final String? area;
  final String? pincode;
  final double? lat;
  final double? lng;
  final int? occupiedBeds;
  final int? totalBeds;

  final List<String>? images;
  final String? coverImage;
  final String? contactNumber;
  final String? description;
  final String? propertyTag;
  final String? foodLicense;
  final String? hostelLicense;
  final String? tradeLicense;

  // --- Subscription fields ---
  /// Whether this property currently has an active paid subscription.
  final bool isSubscribed;

  /// The active plan key: 'monthly' | 'quarterly' | 'half_yearly' | 'annual'.
  /// Null when [isSubscribed] is false.
  final String? currentPlanKey;

  /// Start date of the current subscription cycle.
  final DateTime? subscriptionStart;

  /// End date of the current subscription cycle (renewal date).
  final DateTime? subscriptionEnd;

  Hostel({
    required this.id,
    required this.name,
    required this.address,
    required this.floors,
    required this.hostelType,
    this.city,
    this.district,
    this.village,
    this.state,
    this.area,
    this.pincode,
    this.lat,
    this.lng,
    this.occupiedBeds,
    this.totalBeds,
    this.images,
    this.coverImage,
    this.contactNumber,
    this.description,
    this.propertyTag,
    this.foodLicense,
    this.hostelLicense,
    this.tradeLicense,
    this.isSubscribed = false,
    this.currentPlanKey,
    this.subscriptionStart,
    this.subscriptionEnd,
  });
}
