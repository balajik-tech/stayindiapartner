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
  final List<dynamic>? amenities;
  final List<String>? houseRules;
  final List<dynamic>? foodMenu;
  final int? amenitiesCount;
  final int? rulesCount;
  final int? pendingItemsCount;

  final List<String>? images;
  final String? coverImage;
  final String? contactNumber;
  final String? description;
  final String? propertyTag;
  final String? foodLicense;
  final String? hostelLicense;
  final String? tradeLicense;
  final DateTime? createdAt;

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
    this.amenities,
    this.houseRules,
    this.foodMenu,
    this.amenitiesCount,
    this.rulesCount,
    this.pendingItemsCount,
    this.images,
    this.coverImage,
    this.contactNumber,
    this.description,
    this.propertyTag,
    this.foodLicense,
    this.hostelLicense,
    this.tradeLicense,
    this.createdAt,
  });
}
